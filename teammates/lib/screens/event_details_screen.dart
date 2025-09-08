import 'package:flutter/material.dart';
import 'package:teammates/main.dart';
import 'package:teammates/screens/attendance_screen.dart';
import 'package:teammates/services/error_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EventDetailsScreen extends StatefulWidget {
  final String eventId;
  const EventDetailsScreen({super.key, required this.eventId});

  @override
  State<EventDetailsScreen> createState() => _EventDetailsScreenState();
}

class _EventDetailsScreenState extends State<EventDetailsScreen> {
  late Future<Map<String, dynamic>> _detailsFuture;
  final TextEditingController _cancelReasonController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _detailsFuture = _fetchDetails();
  }

  Future<void> _launchMaps(double? lat, double? lng) async {
    if (lat == null || lng == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Brak współrzędnych dla tego wydarzenia.')),
        );
      }
      return;
    }
    final Uri url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$lat,$lng');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nie można otworzyć mapy.')),
        );
      }
    }
  }

  Future<Map<String, dynamic>> _fetchDetails() async {
    try {
      final eventRes = await supabase
          .from('events')
          .select()
          .eq('id', widget.eventId)
          .single();

      final organizerId = eventRes['organizer_id'];
      String organizerName = 'Anonimowy'; // Default name
      if (organizerId != null) {
        try {
          final List<dynamic> profileResList = await supabase.rpc(
            'get_profile_with_email',
            params: {'p_user_id': organizerId},
          );
          
          if (profileResList.isNotEmpty) {
            final profileRes = profileResList.first as Map<String, dynamic>;
            final Map<String, dynamic>? userMetadata = profileRes['user_metadata'] as Map<String, dynamic>?;

            if (userMetadata != null) {
              organizerName = userMetadata['full_name'] ?? userMetadata['email'] ?? 'Anonimowy';
            } else {
              organizerName = 'Anonimowy'; // Fallback if user_metadata is null
            }
          }
        } catch (e) {
          print('Could not fetch organizer profile with email: $e');
        }
      }

      final participantsRes = await supabase
          .from('event_participants')
          .select('user_id')
          .eq('event_id', widget.eventId);

      final currentUser = supabase.auth.currentUser;
      bool isUserSignedUp = false;
      bool isOrganizer = false;
      if (currentUser != null) {
        isOrganizer = currentUser.id == eventRes['organizer_id'];
        final userSignUpRes = await supabase
            .from('event_participants')
            .select()
            .eq('event_id', widget.eventId)
            .eq('user_id', currentUser.id);
        isUserSignedUp = userSignUpRes.isNotEmpty;
      }

      return {
        'event': eventRes,
        'participants': participantsRes,
        'isUserSignedUp': isUserSignedUp,
        'isOrganizer': isOrganizer,
        'organizerName': organizerName,
      };
    } catch (error) {
      ErrorService.logError(
        eventId: widget.eventId,
        errorMessage: error.toString(),
        operationType: 'fetch_event_details',
      );
      // Re-throw the error to be caught by the FutureBuilder
      throw Exception('Failed to load event details: $error');
    }
  }

  Future<void> _signUp() async {
    try {
      await supabase.from('event_participants').insert({
        'event_id': widget.eventId,
        'user_id': supabase.auth.currentUser!.id,
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Zapisano na wydarzenie!')));
      setState(() {
        _detailsFuture = _fetchDetails(); // Refresh details
      });
    } catch (error) {
      ErrorService.logError(
        eventId: widget.eventId,
        errorMessage: error.toString(),
        operationType: 'signup',
        eventData: {'user_id': supabase.auth.currentUser?.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Błąd podczas zapisywania: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  Future<void> _signOut() async {
    try {
      await supabase
          .from('event_participants')
          .delete()
          .eq('event_id', widget.eventId)
          .eq('user_id', supabase.auth.currentUser!.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Wypisano z wydarzenia')));
      setState(() {
        _detailsFuture = _fetchDetails(); // Refresh details
      });
    } catch (error) {
      ErrorService.logError(
        eventId: widget.eventId,
        errorMessage: error.toString(),
        operationType: 'signout',
        eventData: {'user_id': supabase.auth.currentUser?.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Błąd podczas wypisywania: ${error.toString()}'),
          backgroundColor: Theme.of(context).colorScheme.error));
    }
  }

  @override
  void dispose() {
    _cancelReasonController.dispose();
    super.dispose();
  }

  Future<void> _showCancelEventDialog(String eventId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Anuluj wydarzenie'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                const Text('Czy na pewno chcesz anulować to wydarzenie?'),
                const SizedBox(height: 16),
                TextField(
                  controller: _cancelReasonController,
                  decoration: const InputDecoration(
                    labelText: 'Powód anulowania (opcjonalnie)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Anuluj'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Potwierdź'),
              onPressed: () {
                _cancelEvent(eventId, _cancelReasonController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _cancelEvent(String eventId, String? reason) async {
    try {
      // Delete the event
      await supabase.from('events').delete().eq('id', eventId);

      // TODO: Implement notification to participants about cancellation with reason

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Wydarzenie zostało anulowane!')),
      );
      Navigator.of(
        context,
      ).pop(); // Go back to previous screen after cancellation
    } catch (error) {
      ErrorService.logError(
        eventId: eventId,
        errorMessage: error.toString(),
        operationType: 'cancel_event',
        eventData: {'reason': reason},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Błąd podczas anulowania wydarzenia: ${error.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Szczegóły wydarzenia')),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _detailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Nie udało się załadować szczegółów wydarzenia.'),
            );
          }

          final data = snapshot.data!;
          final event = data['event'];
          final participants = data['participants'] as List;
          final isUserSignedUp = data['isUserSignedUp'] as bool;
          final isOrganizer = data['isOrganizer'] as bool;
          final organizerName = data['organizerName'] as String;

          int currentParticipants = participants.length;
          if (isOrganizer && !isUserSignedUp) {
            currentParticipants++; // Organizer is implicitly a participant
          }

          final eventTime = DateTime.parse(event['event_time']);
          final bool canSignUp =
              currentParticipants < event['max_participants'];
          final bool isEventFinished = eventTime.isBefore(DateTime.now());

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['name'],
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Chip(label: Text(event['category'])),
                const SizedBox(height: 16),
                Text(
                  'KIEDY: ${eventTime.day}.${eventTime.month}.${eventTime.year} o ${eventTime.hour}:${eventTime.minute.toString().padLeft(2, '0')}',
                ),
                const SizedBox(height: 8),
                InkWell(
                  onTap: () => _launchMaps(event['location_lat'], event['location_lng']),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on_outlined, color: Colors.blue, size: 18),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'GDZIE: ${event['location_text'] ?? 'Brak lokalizacji'}',
                          style: const TextStyle(decoration: TextDecoration.underline, color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'ORGANIZATOR: $organizerName',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  event['description'] ?? 'Brak opisu.',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                Text(
                  'ZAPISANI: ${currentParticipants} / ${event['max_participants']}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // Lista uczestników zostanie dodana w przyszłości
                const SizedBox(height: 24),
                if (isOrganizer)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _showCancelEventDialog(event['id']),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD91B24),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Anuluj wydarzenie'),
                    ),
                  )
                else if (isUserSignedUp)
                  ElevatedButton(
                    onPressed: _signOut,
                    child: const Text('Wypisz się'),
                  )
                else if (canSignUp)
                  ElevatedButton(
                    onPressed: _signUp,
                    child: const Text('Zapisz się'),
                  )
                else
                  const ElevatedButton(
                    onPressed: null,
                    child: Text('Brak miejsc'),
                  ),
                if (isOrganizer && isEventFinished)
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => AttendanceScreen(eventId: event['id']),
                          ),
                        );
                      },
                      child: const Text('Zarządzaj obecnością'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

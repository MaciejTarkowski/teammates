import 'package:flutter/material.dart';
import 'package:teammates/main.dart';

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

  Future<Map<String, dynamic>> _fetchDetails() async {
    final eventRes = await supabase
        .from('events')
        .select()
        .eq('id', widget.eventId)
        .single();
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
    };
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
      logErrorToBackend(
        eventId: widget.eventId,
        errorMessage: error.toString(),
        operationType: 'signup',
        eventData: {'user_id': supabase.auth.currentUser?.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd podczas zapisywania: ${error.toString()}'), backgroundColor: Theme.of(context).colorScheme.error));
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
      logErrorToBackend(
        eventId: widget.eventId,
        errorMessage: error.toString(),
        operationType: 'signout',
        eventData: {'user_id': supabase.auth.currentUser?.id},
      );
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Błąd podczas wypisywania: ${error.toString()}'), backgroundColor: Theme.of(context).colorScheme.error));
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
      logErrorToBackend(
        eventId: eventId,
        errorMessage: error.toString(),
        operationType: 'cancel_event',
        eventData: {'reason': reason},
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd podczas anulowania wydarzenia: ${error.toString()}'), backgroundColor: Theme.of(context).colorScheme.error),
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

          int currentParticipants = participants.length;
          if (isOrganizer && !isUserSignedUp) {
            currentParticipants++; // Organizer is implicitly a participant
          }

          final eventTime = DateTime.parse(event['event_time']);
          final bool canSignUp =
              currentParticipants < event['max_participants'];

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
                Text('GDZIE: ${event['location_text'] ?? 'Brak lokalizacji'}'),
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
                // TODO: Zastąpić listą nazw użytkowników, gdy tabela 'profiles' będzie dostępna
                Text(
                  participants
                      .map((p) => (p['user_id'] as String).substring(0, 8))
                      .join(', '),
                ),
                const SizedBox(height: 24),
                if (isOrganizer)
                  ElevatedButton(
                    onPressed: () => _showCancelEventDialog(event['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                    ),
                    child: const Text('Anuluj wydarzenie'),
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
              ],
            ),
          );
        },
      ),
    );
  }
}

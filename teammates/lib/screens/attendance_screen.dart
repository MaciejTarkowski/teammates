import 'package:flutter/material.dart';
import 'package:teammates/main.dart';
import 'package:teammates/widgets/custom_button_style.dart';
import 'package:teammates/widgets/custom_button_style.dart';

class AttendanceScreen extends StatefulWidget {
  final String eventId;

  const AttendanceScreen({super.key, required this.eventId});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  late Future<List<Map<String, dynamic>>> _participantsFuture;
  final Map<String, String> _markedAttendance = {};

  @override
  void initState() {
    super.initState();
    _participantsFuture = _fetchParticipants();
  }

  Future<List<Map<String, dynamic>>> _fetchParticipants() async {
    // 1. Fetch event details to get organizer ID
    final eventRes = await supabase
        .from('events')
        .select('organizer_id')
        .eq('id', widget.eventId)
        .single();
    final organizerId = eventRes['organizer_id'];

    // 2. Fetch all attendance records for the event
    final attendanceRes = await supabase
        .from('event_attendance')
        .select('user_id, status')
        .eq('event_id', widget.eventId);

    // Store marked attendance and collect user IDs
    final List<String> userIds = [];
    for (var record in (attendanceRes as List)) {
      final userId = record['user_id'] as String;
      _markedAttendance[userId] = record['status'];
      // Exclude the organizer from the list to be displayed
      if (userId != organizerId) {
        userIds.add(userId);
      }
    }

    // If there are no participants other than the organizer, return empty list
    if (userIds.isEmpty) {
      return [];
    }

    // 3. Fetch profiles for all participants (excluding the organizer)
    final profilesRes = await supabase
        .from('profiles')
        .select('id, username, avatar_url') // Fetch necessary fields
        .inFilter('id', userIds);

    // The result from profilesRes is the list of participants to display
    return (profilesRes as List).map((p) => p as Map<String, dynamic>).toList();
  }

  Future<void> _markAttendance(String userId, String status) async {
    try {
      // Use upsert to handle both inserting new attendance and updating existing ones.
      await supabase.from('event_attendance').upsert({
        'event_id': widget.eventId,
        'user_id': userId,
        'status': status,
      }, onConflict: 'event_id, user_id');

      setState(() {
        _markedAttendance[userId] = status;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Oznaczono obecność: $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.redAccent),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Zarządzaj obecnością'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _participantsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Brak zapisanych uczestników do oznaczenia.'));
          }

          final participants = snapshot.data!;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final userId = participant['id']; // Correct: from 'profiles' table
              final userName = participant['username'] ?? 'Anonimowy'; // Correct: from 'profiles' table
              final alreadyMarkedStatus = _markedAttendance[userId];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: (participant['avatar_url'] != null &&
                                    participant['avatar_url'].isNotEmpty)
                                ? NetworkImage(participant['avatar_url'])
                                : null,
                            child: (participant['avatar_url'] == null ||
                                    participant['avatar_url'].isEmpty)
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Text(userName,
                              style: Theme.of(context).textTheme.titleMedium),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (alreadyMarkedStatus != null && alreadyMarkedStatus != 'signed_up')
                        Text('Oznaczono: $alreadyMarkedStatus',
                            style: const TextStyle(
                                color: Colors.green, fontWeight: FontWeight.bold))
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                                onPressed: () =>
                                    _markAttendance(userId, 'attended'),
                                child: const Text('Obecny')),
                            ElevatedButton(
                                onPressed: () =>
                                    _markAttendance(userId, 'unjustified_absence'),
                                child: const Text('Nieobecny')),
                            ElevatedButton(
                                onPressed: () =>
                                    _markAttendance(userId, 'justified_absence'),
                                style: getCustomButtonStyle(),
                                child: const Text('Uspraw.')),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
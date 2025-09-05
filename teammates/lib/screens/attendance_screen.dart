import 'package:flutter/material.dart';
import 'package:teammates/main.dart';

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
    // Fetch event details to get organizer ID
    final eventRes = await supabase
        .from('events')
        .select('organizer_id')
        .eq('id', widget.eventId)
        .single();
    final organizerId = eventRes['organizer_id'];

    // Fetch participants with their profiles using the new RPC function
    final profilesRes = await supabase.rpc(
      'get_event_participants_with_profiles',
      params: {'p_event_id': widget.eventId},
    );

    // Filter out the organizer
    final filteredParticipants = (profilesRes as List)
        .map((p) => p as Map<String, dynamic>)
        .where((p) => p['id'] != organizerId) // Exclude organizer
        .toList();

    // Fetch already marked attendance
    final attendanceRes = await supabase
        .from('event_attendance')
        .select('user_id, status')
        .eq('event_id', widget.eventId);

    for (var record in (attendanceRes as List)) {
      _markedAttendance[record['user_id']] = record['status'];
    }

    return filteredParticipants;
  }

  Future<void> _markAttendance(String userId, String status) async {
    try {
      await supabase.from('event_attendance').insert({
        'event_id': widget.eventId,
        'user_id': userId,
        'status': status,
      });
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
            return const Center(child: Text('Brak zapisanych uczestników.'));
          }

          final participants = snapshot.data!;

          return ListView.builder(
            itemCount: participants.length,
            itemBuilder: (context, index) {
              final participant = participants[index];
              final userId = participant['id'];
              final userName = participant['user_metadata']?['full_name'] ?? participant['user_metadata']?['email'] ?? 'Anonimowy';
              final alreadyMarkedStatus = _markedAttendance[userId];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 16),
                      if (alreadyMarkedStatus != null)
                        Text('Oznaczono: $alreadyMarkedStatus', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(onPressed: () => _markAttendance(userId, 'attended'), child: const Text('Obecny')),
                            ElevatedButton(onPressed: () => _markAttendance(userId, 'unjustified_absence'), child: const Text('Nieobecny')),
                            ElevatedButton(onPressed: () => _markAttendance(userId, 'justified_absence'), child: const Text('Uspraw.')),
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
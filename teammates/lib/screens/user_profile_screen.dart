import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:teammates/screens/event_details_screen.dart'; // Added import

class UserProfileScreen extends StatefulWidget {
  final String userId;

  const UserProfileScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  late Future<Map<String, dynamic>> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final profileResponse = await Supabase.instance.client
        .rpc('get_profile', params: {'p_user_id': widget.userId});

    if (profileResponse.isEmpty) {
      throw 'Nie znaleziono profilu.';
    }

    final lastEventResponse = await Supabase.instance.client
        .rpc('get_last_joined_event', params: {'user_id_param': widget.userId});

    return {
      'profile': profileResponse[0],
      'last_event': lastEventResponse.isNotEmpty ? lastEventResponse[0] : null,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil użytkownika'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('Nie znaleziono danych.'));
          }

          final profileData = snapshot.data!['profile'];
          final lastEventData = snapshot.data!['last_event'];

          final username = profileData['username'] ?? 'Brak nazwy';
          final reputation = profileData['reputation_score'] ?? 0;
          final avatarUrl = profileData['avatar_url'];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey.shade300,
                      child: avatarUrl != null && avatarUrl.isNotEmpty
                          ? ClipOval(child: Image.network(avatarUrl, fit: BoxFit.cover))
                          : const Icon(Icons.person, size: 40, color: Colors.white),
                    ),
                    const SizedBox(width: 20),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Reputacja: $reputation',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                const Divider(),
                const SizedBox(height: 10),
                const Text(
                  'Ostatnie wydarzenie',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                lastEventData != null
                    ? ListTile(
                        leading: const Icon(Icons.event),
                        title: Text(lastEventData['name']),
                        subtitle: Text(
                          DateFormat('d MMMM yyyy, HH:mm').format(
                            DateTime.parse(lastEventData['event_time']),
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => EventDetailsScreen(eventId: lastEventData['id']),
                            ),
                          );
                        },
                      )
                    : const Text('Użytkownik nie dołączył do żadnego wydarzenia.'),
              ],
            ),
          );
        },
      ),
    );
  }
}


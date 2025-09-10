import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';
import 'package:teammates/screens/event_details_screen.dart'; // Added import

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _lastEventData;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      
      // Fetch profile data
      final profileResponse = await Supabase.instance.client
          .rpc('get_profile', params: {'p_user_id': userId});
      
      print('Supabase profile response: $profileResponse');

      if (profileResponse.isNotEmpty && profileResponse[0]['username'] != null) {
        _profileData = profileResponse[0];
      } else {
        // Try to create or update a profile if it doesn't exist or username is null.
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
            final updates = {
                'id': user.id,
                'username': user.email!.split('@')[0],
                // Preserve existing reputation and avatar if they exist
                'reputation_score': profileResponse.isNotEmpty ? profileResponse[0]['reputation_score'] : 10,
                'avatar_url': profileResponse.isNotEmpty ? profileResponse[0]['avatar_url'] : null,
            };
            await Supabase.instance.client.from('profiles').upsert(updates);
            
            // Re-fetch after upserting
            final newProfileResponse = await Supabase.instance.client
                .rpc('get_profile', params: {'p_user_id': userId});

            if (newProfileResponse.isNotEmpty) {
                _profileData = newProfileResponse[0];
            } else {
                throw 'Profil nie został znaleziony nawet po próbie utworzenia.';
            }
        } else {
            throw 'Użytkownik niezalogowany.';
        }
      }

      // Fetch last joined event
      final lastEventResponse = await Supabase.instance.client
          .rpc('get_last_joined_event', params: {'user_id_param': userId});

      if (lastEventResponse.isNotEmpty) {
        _lastEventData = lastEventResponse[0];
      }

    } catch (e) {
      setState(() {
        _error = 'Nie udało się załadować profilu: $e';
        print(_error); // Also print error to console
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _signOut() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(child: Text(_error!, style: const TextStyle(color: Colors.red)));
    }
    if (_profileData == null) {
      return const Center(child: Text('Nie znaleziono danych profilu.'));
    }
    return _buildProfileView();
  }

  Widget _buildProfileView() {
    final username = _profileData!['username'] ?? 'Brak nazwy';
    final reputation = _profileData!['reputation_score'] ?? 0;
    final avatarUrl = _profileData!['avatar_url'];

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
          _lastEventData != null
              ? ListTile(
                  leading: const Icon(Icons.event),
                  title: Text(_lastEventData!['name']),
                  subtitle: Text(
                    DateFormat('d MMMM yyyy, HH:mm').format(
                      DateTime.parse(_lastEventData!['event_time']),
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(eventId: _lastEventData!['id']),
                      ),
                    );
                  },
                )
              : const Text('Nie dołączyłeś do żadnego wydarzenia.'),
          const Spacer(),
          Center(
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Wyloguj'),
              onPressed: _signOut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

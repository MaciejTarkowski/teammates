import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teammates/screens/create_event_screen.dart';
import 'package:teammates/screens/home_screen.dart';
import 'package:teammates/screens/my_events_screen.dart';
import 'package:teammates/screens/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final StreamSubscription<AuthState> _authStateSubscription;
  final GlobalKey<MyEventsScreenState> _myEventsKey = GlobalKey();
  final GlobalKey<ProfileScreenState> _profileKey = GlobalKey();

  late final List<Widget> _widgetOptions = <Widget>[
    const HomeScreen(),
    MyEventsScreen(key: _myEventsKey),
    ProfileScreen(key: _profileKey),
  ];

  static const List<String> _widgetTitles = <String>[
    'Nadchodzące wydarzenia',
    'Moje wydarzenia',
    'Mój Profil'
  ];

  @override
  void initState() {
    super.initState();
    _authStateSubscription =
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      if (event == AuthChangeEvent.signedOut) {
        if (mounted) {
          Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
        }
      }
    });
  }

  @override
  void dispose() {
    _authStateSubscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) { // My Events tab
      _myEventsKey.currentState?.fetchAndGroupEvents();
    } else if (index == 2) { // Profile tab
      _profileKey.currentState?.fetchProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_widgetTitles[_selectedIndex]),
        automaticallyImplyLeading: false, // Removes back button
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Wydarzenia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Moje wydarzenia',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // To ensure all items are visible
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          ).then((_) {
            _myEventsKey.currentState?.fetchAndGroupEvents();
          });
        },
        backgroundColor: const Color(0xFFD91B24),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:teammates/screens/create_event_screen.dart';
import 'package:teammates/screens/event_details_screen.dart';
import 'package:teammates/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://jkzvbapuraymkkzzdygl.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImprenZiYXB1cmF5bWtrenpkeWdsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTY5ODUxOTAsImV4cCI6MjA3MjU2MTE5MH0.I5ol5fauM-MkMbURTGairwdvIEEuZ9kdkjPB35ULbFo',
  );

  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TeamMates',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.dark,
          primary: Color(0xFFD91B24),
          onPrimary: Colors.white,
          secondary: Color(0xFF761F21),
          onSecondary: Colors.white,
          error: Colors.redAccent,
          onError: Colors.white,
          background: Color(0xFF1C1C1C),
          onBackground: Colors.white,
          surface: Color(0xFF050505),
          onSurface: Colors.white,
        ),
        // Ustawienie domyślnej czcionki dla całej aplikacji
        fontFamily: 'Georgia',
        // Zastosowanie kolorów do istniejącego motywu tekstu
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: Colors.white,
              displayColor: Colors.white,
            ),
      ),
      home: const SplashScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<List<Map<String, dynamic>>>? _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = _getEvents();
  }

  Future<List<Map<String, dynamic>>> _getEvents() async {
    final data = await supabase.from('events').select().order('event_time', ascending: true);
    return data;
  }

  void _refreshEvents() {
    setState(() {
      _eventsFuture = _getEvents();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nadchodzące wydarzenia'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
            },
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _eventsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Błąd: ${snapshot.error}'));
          }
          final events = snapshot.data!;
          if (events.isEmpty) {
            return const Center(child: Text('Brak nadchodzących wydarzeń.'));
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              final eventTime = DateTime.parse(event['event_time']);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                color: Theme.of(context).colorScheme.surface,
                child: ListTile(
                  title: Text(event['name'] ?? 'Brak nazwy'),
                  subtitle: Text('${event['category']} \n${eventTime.day}.${eventTime.month}.${eventTime.year} o ${eventTime.hour}:${eventTime.minute.toString().padLeft(2, '0')}'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EventDetailsScreen(eventId: event['id']),
                      ),
                    );
                    _refreshEvents();
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const CreateEventScreen()),
          );
          _refreshEvents();
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
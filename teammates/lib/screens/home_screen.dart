import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teammates/main.dart';
import 'package:teammates/screens/event_details_screen.dart';
import 'package:teammates/services/error_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Future<List<Map<String, dynamic>>>? _eventsFuture;
  final _searchController = TextEditingController();
  String? _selectedCategory;
  Position? _currentPosition;
  double? _selectedRadius;

  final _categories = [
    'piłka nożna',
    'koszykówka',
    'tenis',
    'wyprawa motocyklowa',
  ];
  final _radii = {1: '1 km', 2: '2 km', 5: '5 km', 10: '10 km', 20: '20 km'};

  @override
  void initState() {
    super.initState();
    _initializeData();
    _searchController.addListener(() {
      setState(() {
        _eventsFuture = _getEvents();
      });
    });
  }

  Future<void> _initializeData() async {
    await _getCurrentLocation();
    if (mounted) {
      setState(() {
        _eventsFuture = _getEvents();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void refreshEvents() {
    setState(() {
      _eventsFuture = _getEvents();
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Brak uprawnień do lokalizacji'),
                backgroundColor: Colors.redAccent,
              ),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Uprawnienia do lokalizacji zostały trwale odrzucone',
              ),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
      });
    } catch (e) {
      ErrorService.logError(errorMessage: e.toString(), operationType: 'getCurrentLocation-main');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd pobierania lokalizacji: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getEvents() async {
    List<Map<String, dynamic>> events = [];

    try {
      debugPrint('Current Position: $_currentPosition');
      debugPrint('Selected Radius: $_selectedRadius');

      double effectiveRadiusKm =
          _selectedRadius ?? 100.0; // Domyślny promień 100km dla 'Dowolny'

      if (_currentPosition != null) {
        final rpcParams = {
          'user_lat': _currentPosition!.latitude,
          'user_lng': _currentPosition!.longitude,
          'radius_km': effectiveRadiusKm,
        };
        debugPrint('RPC Params: $rpcParams');
        events = await supabase.rpc('get_events_in_radius', params: rpcParams);
        debugPrint('Events from RPC: $events');
      } else {
        events = await supabase
            .from('events')
            .select()
            .order('event_time', ascending: true);
        debugPrint('Events from fallback: $events');
      }

      if (_searchController.text.isNotEmpty) {
        events = events.where((event) {
          final name = event['name']?.toString().toLowerCase() ?? '';
          return name.contains(_searchController.text.toLowerCase());
        }).toList();
      }

      if (_selectedCategory != null) {
        events = events.where((event) {
          return event['category'] == _selectedCategory;
        }).toList();
      }
    } catch (e) {
      ErrorService.logError(errorMessage: e.toString(), operationType: 'getEvents');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd ładowania wydarzeń: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      debugPrint('Error loading events: $e');
      return [];
    }

    return events;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Szukaj po nazwie...',
                  suffixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedCategory,
                      isExpanded: true,
                      hint: const Text('Filtruj po kategorii'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Wszystkie kategorie'),
                        ),
                        ..._categories.map(
                          (cat) =>
                              DropdownMenuItem(value: cat, child: Text(cat)),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategory = value;
                          _eventsFuture = _getEvents();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<double>(
                      value: _selectedRadius,
                      isExpanded: true,
                      hint: const Text('Promień'),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('Dowolny'),
                        ),
                        ..._radii.keys.map(
                          (radius) => DropdownMenuItem(
                            value: radius.toDouble(),
                            child: Text(_radii[radius]!),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRadius = value;
                          _eventsFuture = _getEvents();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<Map<String, dynamic>>>(
            future: _eventsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Błąd: ${snapshot.error}'));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text('Brak wydarzeń spełniających kryteria.'),
                );
              }

              final events = snapshot.data!;

              return ListView.builder(
                itemCount: events.length,
                itemBuilder: (context, index) {
                  final event = events[index];
                  final eventTime = DateTime.parse(event['event_time']);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      title: Text(event['name'] ?? 'Brak nazwy'),
                      subtitle: Text(
                        '${event['category']} \n${eventTime.day}.${eventTime.month}.${eventTime.year} o ${eventTime.hour}:${eventTime.minute.toString().padLeft(2, '0')}',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                EventDetailsScreen(eventId: event['id']),
                          ),
                        );
                        refreshEvents();
                      },
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
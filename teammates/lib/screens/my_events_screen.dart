import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teammates/main.dart';
import 'package:teammates/screens/event_details_screen.dart';

class MyEventsScreen extends StatefulWidget {
  const MyEventsScreen({super.key});

  @override
  State<MyEventsScreen> createState() => _MyEventsScreenState();
}

class _MyEventsScreenState extends State<MyEventsScreen> {
  bool _isLoading = true;
  String? _error;
  Map<DateTime, List<Map<String, dynamic>>> _groupedEvents = {};
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchAndGroupEvents();
  }

  Future<void> _fetchAndGroupEvents() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _error = "Not logged in";
        });
        return;
      }

      final response = await supabase.rpc('get_my_events');
      final events = (response as List).map((e) => e as Map<String, dynamic>).toList();

      final Map<DateTime, List<Map<String, dynamic>>> grouped = {};
      for (var event in events) {
        final eventTime = DateTime.parse(event['event_time']);
        final day = DateTime(eventTime.year, eventTime.month, eventTime.day);
        if (grouped[day] == null) {
          grouped[day] = [];
        }
        grouped[day]!.add(event);
      }

      setState(() {
        _groupedEvents = grouped;
        _selectedDate = grouped.keys.isNotEmpty ? grouped.keys.first : null;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = "Failed to load events: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : Column(
                  children: [
                    _buildCalendarView(),
                    Expanded(
                      child: _buildEventList(),
                    ),
                  ],
                ),
    );
  }

  Widget _buildCalendarView() {
    final sortedDays = _groupedEvents.keys.toList()..sort();

    if (sortedDays.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: sortedDays.length,
        itemBuilder: (context, index) {
          final day = sortedDays[index];
          final isSelected = day == _selectedDate;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedDate = day;
              });
            },
            child: Container(
              width: 60,
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? Colors.white : Colors.grey,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E('pl_PL').format(day), // Dzień tygodnia
                    style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    day.day.toString(),
                    style: TextStyle(fontSize: 20, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEventList() {
    final eventsForSelectedDay = _selectedDate != null ? _groupedEvents[_selectedDate] : [];

    if (eventsForSelectedDay == null || eventsForSelectedDay.isEmpty) {
      return const Center(child: Text('Brak wydarzeń tego dnia.'));
    }

    return ListView.builder(
      itemCount: eventsForSelectedDay.length,
      itemBuilder: (context, index) {
        final event = eventsForSelectedDay[index];
        final eventTime = DateTime.parse(event['event_time']);
        final isOrganizer = event['user_role'] == 'organizer';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          color: isOrganizer ? Theme.of(context).colorScheme.secondary : Theme.of(context).colorScheme.surface,
          child: ListTile(
            title: Text(event['name'] ?? 'Brak nazwy'),
            subtitle: Text(
              '${event['category']} o ${DateFormat.Hm('pl_PL').format(eventTime)}',
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => EventDetailsScreen(eventId: event['id']),
                ),
              );
              _fetchAndGroupEvents(); // Refresh data after returning
            },
          ),
        );
      },
    );
  }
}
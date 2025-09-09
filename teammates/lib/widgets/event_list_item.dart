import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teammates/screens/event_details_screen.dart';

class EventListItem extends StatelessWidget {
  final Map<String, dynamic> event;
  final VoidCallback onRefresh; // Callback to refresh the list

  const EventListItem({super.key, required this.event, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final eventTime = DateTime.parse(event['event_time']);
    final distanceInMeters = (event['distance_meters'] as num?)?.toDouble();

    String distanceText = '';
    if (distanceInMeters != null) {
      if (distanceInMeters < 1000) {
        distanceText = '${distanceInMeters.toStringAsFixed(0)} m od Ciebie';
      } else {
        final distanceInKm = distanceInMeters / 1000;
        distanceText = '${distanceInKm.toStringAsFixed(1)} km od Ciebie';
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 8,
      ),
      child: ListTile(
        title: Text(event['name'] ?? 'Brak nazwy'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(event['category'] ?? 'Brak kategorii'),
            const SizedBox(height: 4),
            Text(DateFormat('d MMMM yyyy, HH:mm').format(eventTime)),
            if (event['status'] == 'held')
              const Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: Text(
                  'Wydarzenie odbyło się',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (distanceText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  distanceText,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EventDetailsScreen(eventId: event['id']),
            ),
          );
          onRefresh(); // Call the refresh callback when returning from details
        },
      ),
    );
  }
}

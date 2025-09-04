import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teammates/main.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _eventTime;
  int _maxParticipants = 10;
  String _category = 'piłka nożna';
  bool _isLoading = false;
  Position? _currentPosition;
  Location? _geocodedLocation;

  final _categories = ['piłka nożna', 'koszykówka', 'tenis', 'wyprawa motocyklowa'];

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
    );
    if (time == null) return;

    setState(() {
      _eventTime = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoading = true;
    });
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Brak uprawnień do lokalizacji'), backgroundColor: Colors.redAccent),
            );
          }
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Uprawnienia do lokalizacji zostały trwale odrzucone'), backgroundColor: Colors.redAccent),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _currentPosition = position;
        _locationController.text = '${position.latitude}, ${position.longitude}'; // Wyświetl współrzędne
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania lokalizacji: $e'), backgroundColor: Colors.redAccent),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _geocodeAddress() async {
    if (_locationController.text.isEmpty) return;

    try {
      List<Location> locations = await locationFromAddress(_locationController.text);
      if (locations.isNotEmpty) {
        setState(() {
          _geocodedLocation = locations.first;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Nie znaleziono lokalizacji dla podanego adresu'), backgroundColor: Colors.redAccent),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd geokodowania adresu: $e'), backgroundColor: Colors.redAccent),
        );
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    if (_eventTime == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Proszę wybrać datę i godzinę wydarzenia'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
      return;
    }

    // Upewnij się, że mamy współrzędne, jeśli adres został wpisany ręcznie
    if (_locationController.text.isNotEmpty && _currentPosition == null && _geocodedLocation == null) {
      await _geocodeAddress();
      if (_geocodedLocation == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Nie udało się uzyskać współrzędnych dla lokalizacji'), backgroundColor: Theme.of(context).colorScheme.error),
          );
        }
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await supabase.from('events').insert({
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location_text': _locationController.text.trim(),
        'event_time': _eventTime!.toIso8601String(),
        'max_participants': _maxParticipants,
        'category': _category,
        'organizer_id': supabase.auth.currentUser!.id,
        'location_lat': _currentPosition?.latitude ?? _geocodedLocation?.latitude,
        'location_lng': _currentPosition?.longitude ?? _geocodedLocation?.longitude,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Wydarzenie zostało utworzone!')),
        );
        Navigator.of(context).pop();
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Nie udało się utworzyć wydarzenia: $error'), backgroundColor: Theme.of(context).colorScheme.error),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Stwórz nowe wydarzenie')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(labelText: 'Nazwa wydarzenia'),
                      validator: (value) => value == null || value.isEmpty ? 'Podaj nazwę' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: 'Opis'),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(labelText: 'Lokalizacja'),
                      onChanged: (value) {
                        // Wyczyść geokodowaną lokalizację, jeśli użytkownik edytuje ręcznie
                        setState(() {
                          _geocodedLocation = null;
                          _currentPosition = null;
                        });
                      },
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: _getCurrentLocation,
                      child: const Text('Użyj mojej lokalizacji'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(labelText: 'Kategoria'),
                      items: _categories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _category = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Text(_eventTime == null ? 'Nie wybrano daty' : '${_eventTime!.day}.${_eventTime!.month}.${_eventTime!.year} ${_eventTime!.hour}:${_eventTime!.minute.toString().padLeft(2, '0')}')),
                        ElevatedButton(onPressed: _selectDateTime, child: const Text('Wybierz datę i czas')),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Maksymalna liczba uczestników: $_maxParticipants'),
                    Slider(
                      value: _maxParticipants.toDouble(),
                      min: 1,
                      max: 50,
                      divisions: 49,
                      label: _maxParticipants.toString(),
                      onChanged: (value) {
                        setState(() {
                          _maxParticipants = value.round();
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(onPressed: _submit, child: const Text('Utwórz wydarzenie')),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
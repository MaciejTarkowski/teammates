
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:teammates/services/nominatim_service.dart';

class EventSearchWizard extends StatefulWidget {
  final Function(Map<String, dynamic> searchParams) onSearch;

  const EventSearchWizard({super.key, required this.onSearch});

  @override
  State<EventSearchWizard> createState() => _EventSearchWizardState();
}

class _EventSearchWizardState extends State<EventSearchWizard> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Search parameters
  String? _selectedCategory;
  DateTime? _startDate;
  DateTime? _endDate;
  double? _selectedLat;
  double? _selectedLng;
  double _selectedRadius = 2000; // Default to 2km in meters

  // Location step state
  final _locationController = TextEditingController();
  final _nominatimService = NominatimService();
  List<Map<String, dynamic>> _suggestions = [];
  Timer? _debounce;
  bool _isSelectingLocation = false;
  bool _isLoading = false;

  final List<String> _categories = [
    'piłka nożna',
    'koszykówka',
    'tenis',
    'wyprawa motocyklowa',
  ];

  final Map<double, String> _radii = {
    2000: '+2km',
    5000: '+5km',
    10000: '+10km',
    50000: '+50km',
    100000: '+100km',
  };

  @override
  void initState() {
    super.initState();
    _locationController.addListener(_onLocationChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    _locationController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onLocationChanged() {
    if (_isSelectingLocation) return;
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_locationController.text.isNotEmpty) {
        _searchLocation(_locationController.text);
      } else {
        if (mounted) setState(() => _suggestions = []);
      }
    });
  }

  Future<void> _searchLocation(String query) async {
    try {
      final results = await _nominatimService.search(query);
      if (mounted) setState(() => _suggestions = results);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd wyszukiwania lokalizacji: $e')),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Brak uprawnień do lokalizacji.')),
          );
        }
        setState(() => _isLoading = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _selectedLat = position.latitude;
          _selectedLng = position.longitude;
          _isLoading = false;
        });
        _triggerSearch();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd pobierania lokalizacji: $e')),
        );
      }
    }
  }

  void _triggerSearch() {
    final params = {
      'category': _selectedCategory,
      'startDate': _startDate?.toIso8601String(),
      'endDate': _endDate?.toIso8601String(),
      'lat': _selectedLat,
      'lng': _selectedLng,
      'radius': _selectedRadius,
    };
    widget.onSearch(params);
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.animateToPage(_currentPage + 1,
          duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
    }
  }

  ButtonStyle _getButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFD91B24),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildCategoryStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Co chciałbyś porobić?",
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: _categories.map((category) {
            return SizedBox(
              width: 160,
              height: 50,
              child: ElevatedButton(
                style: _getButtonStyle(),
                onPressed: () {
                  setState(() => _selectedCategory = category);
                  _nextPage();
                },
                child: Text(category, textAlign: TextAlign.center),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateStep() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Kiedy zaczynamy?",
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 24),
        SizedBox(
          width: 160,
          height: 50,
          child: ElevatedButton(
            style: _getButtonStyle(),
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                _startDate = now; // Start from now
                final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
                _endDate = endOfDay;
              });
              _nextPage();
            },
            child: const Text("Dzisiaj"),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: 160,
          height: 50,
          child: ElevatedButton(
            style: _getButtonStyle(),
            onPressed: () async {
              final picked = await showDateRangePicker(
                context: context,
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 365)),
              );
              if (picked != null) {
                setState(() {
                  _startDate = picked.start;
                  _endDate = DateTime(picked.end.year, picked.end.month, picked.end.day, 23, 59, 59);
                });
                _nextPage();
              }
            },
            child: const Text("Zakres dat"),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Gdzie startujemy?",
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 24),
            if (_isLoading) const CircularProgressIndicator(),
            if (!_isLoading) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: TextField(
                  controller: _locationController,
                  decoration: const InputDecoration(labelText: 'Wpisz adres lub miasto'),
                ),
              ),
              if (_suggestions.isNotEmpty)
                Container(
                  height: 150,
                  margin: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 8.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: ListView.builder(
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = _suggestions[index];
                      return ListTile(
                        title: Text(suggestion['display_name'] ?? ''),
                        onTap: () {
                          _isSelectingLocation = true;
                          if (mounted) {
                            setState(() {
                              _locationController.text = suggestion['display_name'];
                              _selectedLat = double.parse(suggestion['lat']);
                              _selectedLng = double.parse(suggestion['lon']);
                              _suggestions = [];
                            });
                          }
                          _isSelectingLocation = false;
                          // Don't trigger search immediately, wait for radius selection
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: DropdownButtonFormField<double>(
                  value: _selectedRadius,
                  decoration: const InputDecoration(labelText: 'Promień wyszukiwania'),
                  items: _radii.keys.map((radius) {
                    return DropdownMenuItem<double>(
                      value: radius,
                      child: Text(_radii[radius]!),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRadius = value;
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton.icon(
                  style: _getButtonStyle(),
                  icon: const Icon(Icons.my_location),
                  label: const Text("Użyj mojej lokalizacji"),
                  onPressed: _getCurrentLocation,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  style: _getButtonStyle(),
                  onPressed: () {
                    if (_selectedLat != null && _selectedLng != null) {
                      _triggerSearch();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Wybierz lokalizację z listy lub użyj GPS.')),
                      );
                    }
                  },
                  child: const Text('Szukaj'),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (page) => setState(() => _currentPage = page),
        children: [
          _buildCategoryStep(),
          _buildDateStep(),
          _buildLocationStep(),
        ],
      ),
    );
  }
}

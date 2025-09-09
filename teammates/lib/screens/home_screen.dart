import 'dart:async';
import 'package:flutter/material.dart';
import 'package:teammates/main.dart';
import 'package:teammates/services/error_service.dart';
import 'package:teammates/widgets/event_list_item.dart';
import 'package:teammates/widgets/event_search_wizard.dart';
import 'package:teammates/widgets/custom_button_style.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // State management
  bool _isSearching = true;
  bool _isLoading = false;
  bool _canLoadMore = true;
  int _page = 1;
  final int _pageSize = 20;
  double _selectedRadius = 5000; // Default to 5km in meters

  Map<String, dynamic>? _searchParams;
  List<Map<String, dynamic>> _events = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent * 0.9 &&
        !_isLoading &&
        _canLoadMore) {
      _fetchEvents();
    }
  }

  void _resetSearch() {
    setState(() {
      _isSearching = true;
      _events = [];
      _page = 1;
      _canLoadMore = true;
      _searchParams = null;
    });
  }

  Future<void> _startSearch(Map<String, dynamic> params) async {
    setState(() {
      _searchParams = params;
      _isSearching = false;
      _events = [];
      _page = 1;
      _canLoadMore = true;
    });
    await _fetchEvents();
  }

  Future<void> _fetchEvents() async {
    if (_isLoading || !_canLoadMore || _searchParams == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final params = {
        'p_lat': _searchParams!['lat'],
        'p_lng': _searchParams!['lng'],
        'p_radius_meters': _searchParams!['radius'], // Use radius from search params
        'p_category': _searchParams!['category'],
        'p_start_date': _searchParams!['startDate'],
        'p_end_date': _searchParams!['endDate'],
        'p_page_size': _pageSize,
        'p_page_number': _page,
      };

      final newEvents = await supabase.rpc('search_events', params: params);

      setState(() {
        if (newEvents.isEmpty || newEvents.length < _pageSize) {
          _canLoadMore = false;
        }
        _events.addAll(List<Map<String, dynamic>>.from(newEvents));
        _page++;
      });
    } catch (e) {
      ErrorService.logError(
          errorMessage: e.toString(), operationType: 'search_events');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Błąd ładowania wydarzeń: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
      setState(() {
        _canLoadMore = false;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isSearching
          ? Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: EventSearchWizard(
                    onSearch: _startSearch,
                  ),
                ),
              ),
            )
          : _buildResultsView(),
    );
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _resetSearch,
                  icon: const Icon(Icons.search),
                  label: const Text('Wyszukaj ponownie'),
                  style: getCustomButtonStyle(),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: DropdownButton<double>(
                  value: _selectedRadius,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 5000, child: Text('5 km')),
                    DropdownMenuItem(value: 10000, child: Text('10 km')),
                    DropdownMenuItem(value: 15000, child: Text('15 km')),
                    DropdownMenuItem(value: 30000, child: Text('30 km')),
                    DropdownMenuItem(value: 50000, child: Text('50 km')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedRadius = value;
                        _searchParams!['radius'] = value;
                        _events = [];
                        _page = 1;
                        _canLoadMore = true;
                      });
                      _fetchEvents();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _events.isEmpty && _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _events.isEmpty && !_isLoading
                  ? const Center(
                      child: Text('Brak wydarzeń spełniających kryteria.'),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _resetSearch();
                        // The search wizard will be shown, no need to fetch here
                      },
                      child: ListView.builder(
                        controller: _scrollController,
                        itemCount: _events.length + (_canLoadMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == _events.length) {
                            return const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final event = _events[index];
                          return EventListItem(
                            event: event,
                            onRefresh: () {
                              // A simple refresh of current data, might need a more specific implementation
                              // For now, let's just rebuild state
                              setState(() {});
                            },
                          );
                        },
                      ),
                    ),
        ),
      ],
    );
  }
}

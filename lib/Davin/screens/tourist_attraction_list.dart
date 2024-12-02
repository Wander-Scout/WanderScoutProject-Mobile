// tourist_attraction_screen.dart
import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart'; // Adjust the path
import 'package:wanderscout/Davin/API/tourist_api.dart'; // Import the API class

class TouristAttractionScreen extends StatefulWidget {
  const TouristAttractionScreen({super.key});

  @override
  State<TouristAttractionScreen> createState() =>
      _TouristAttractionScreenState();
}

class _TouristAttractionScreenState extends State<TouristAttractionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TouristAttractionApi _api = TouristAttractionApi(); // Use the API class

  List<TouristAttraction> _displayedAttractions = [];
  List<TouristAttraction> _allAttractions = [];
  List<TouristAttraction> _filteredAttractions = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 10;

  String _searchQuery = '';
  String _selectedType = 'All';
  List<String> _availableTypes = ['All'];

  @override
  void initState() {
    super.initState();
    _fetchTouristAttractions();

    // Add listener for infinite scrolling
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !_isLoading &&
          _hasMore) {
        _loadMoreAttractions();
      }
    });
  }

  Future<void> _fetchTouristAttractions() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final fetchedAttractions = await _api.fetchTouristAttractions(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        _allAttractions.addAll(fetchedAttractions);

        // Populate available types for filtering
        final types = _allAttractions
            .map((attraction) => attraction.type)
            .toSet()
            .toList();
        _availableTypes = ['All', ...types];

        _filteredAttractions = List.from(_allAttractions);
        _displayedAttractions.addAll(fetchedAttractions.take(_pageSize));
        if (fetchedAttractions.length < _pageSize) {
          _hasMore = false;
        }
        _currentPage++;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching attractions: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _filterAttractions() {
    setState(() {
      _filteredAttractions = _allAttractions.where((attraction) {
        final matchesSearchQuery =
            attraction.nama.toLowerCase().contains(_searchQuery.toLowerCase());
        final matchesType =
            _selectedType == 'All' || attraction.type == _selectedType;
        return matchesSearchQuery && matchesType;
      }).toList();

      _displayedAttractions = _filteredAttractions.take(_pageSize).toList();
      _hasMore = _filteredAttractions.length > _pageSize;
    });
  }

  void _loadMoreAttractions() {
    if (_displayedAttractions.length >= _filteredAttractions.length ||
        _isLoading ||
        !_hasMore) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      final nextItems = _filteredAttractions
          .skip(_displayedAttractions.length)
          .take(_pageSize)
          .toList();

      setState(() {
        _displayedAttractions.addAll(nextItems);
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Attractions'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Search and Filter Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Search Bar
                Expanded(
                  flex: 2,
                  child: TextField(
                    onChanged: (value) {
                      _searchQuery = value;
                      _filterAttractions();
                    },
                    decoration: InputDecoration(
                      labelText: 'Search by name...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Filter Dropdown
                Expanded(
                  flex: 1,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedType,
                    items: _availableTypes
                        .map((type) => DropdownMenuItem<String>(
                              value: type,
                              child: Text(type),
                            ))
                        .toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                          _filterAttractions();
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          // Attractions List
          Expanded(
            child: _allAttractions.isEmpty && !_isLoading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels ==
                          scrollInfo.metrics.maxScrollExtent) {
                        _loadMoreAttractions();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount:
                          _displayedAttractions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _displayedAttractions.length) {
                          final attraction = _displayedAttractions[index];

                          return Container(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            padding: const EdgeInsets.all(20.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: const [
                                BoxShadow(
                                  color: Colors.black26,
                                  blurRadius: 8.0,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  attraction.nama,
                                  style: const TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text("Rating: ${attraction.voteAverage}"),
                                const SizedBox(height: 10),
                                Text("Type: ${attraction.type}"),
                                const SizedBox(height: 10),
                                Text(
                                    "Weekday Price: IDR ${attraction.htmWeekday}"),
                                const SizedBox(height: 10),
                                Text(
                                    "Weekend Price: IDR ${attraction.htmWeekend}"),
                                const SizedBox(height: 10),
                                Text(
                                    "Description: ${attraction.description}"),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    // Handle any action, e.g., navigate to details page
                                  },
                                  child: const Text('View Details'),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

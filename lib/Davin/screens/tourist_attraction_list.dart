import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:wanderscout/Davin/API/tourist_api.dart';
import 'package:wanderscout/Davin/screens/attraction_detail.dart';

class TouristAttractionScreen extends StatefulWidget {
  const TouristAttractionScreen({super.key});

  @override
  State<TouristAttractionScreen> createState() => _TouristAttractionScreenState();
}

class _TouristAttractionScreenState extends State<TouristAttractionScreen> {
  final ScrollController _scrollController = ScrollController();
  final TouristAttractionApi _api = TouristAttractionApi();

  List<TouristAttraction> _displayedAttractions = [];
  final List<TouristAttraction> _allAttractions = [];
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

    _scrollController.addListener(() {
      if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
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

        final types = _allAttractions
            .map((attraction) => attraction.type.split(',').first.trim())
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
            _selectedType == 'All' ||
            attraction.type.split(',').first.trim() == _selectedType;
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

  String getImageForAttractionType(String? type) {
    final firstCategory =
        type?.split(',').first.trim().replaceAll(' ', '').toLowerCase() ??
            'placeholder';
    return 'lib/static/attractions/$firstCategory.png';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isSmallScreen = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Attractions'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
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
          Expanded(
            child: _allAttractions.isEmpty && !_isLoading
                ? const Center(child: CircularProgressIndicator())
                : NotificationListener<ScrollNotification>(
                    onNotification: (scrollInfo) {
                      if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
                        _loadMoreAttractions();
                      }
                      return false;
                    },
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16.0),
                      itemCount: _displayedAttractions.length + (_isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < _displayedAttractions.length) {
                          final attraction = _displayedAttractions[index];

                          return Card(
                            elevation: 4,
                            margin: const EdgeInsets.only(bottom: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        AttractionDetailScreen(attraction: attraction),
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: isSmallScreen
                                    ? Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              getImageForAttractionType(attraction.type),
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 200,
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          buildAttractionDetails(attraction),
                                        ],
                                      )
                                    : Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.asset(
                                              getImageForAttractionType(attraction.type),
                                              fit: BoxFit.cover,
                                              width: 150,
                                              height: 150,
                                            ),
                                          ),
                                          const SizedBox(width: 16),
                                          Expanded(
                                            child: buildAttractionDetails(attraction),
                                          ),
                                        ],
                                      ),
                              ),
                            ),
                          );
                        } else {
                          return const Center(child: CircularProgressIndicator());
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildAttractionDetails(TouristAttraction attraction) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          attraction.nama,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Rating: ${attraction.voteAverage} / 5',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Type: ${attraction.type}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Weekday Price: IDR ${attraction.htmWeekday}',
          style: const TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 4),
        Text(
          'Weekend Price: IDR ${attraction.htmWeekend}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}

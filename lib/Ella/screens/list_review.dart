import 'package:flutter/material.dart';
import 'package:wanderscout/ella/models/review_entry.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async'; // For Timer and Future.delayed

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  final List<ReviewEntry> _allReviews = [];
  final List<ReviewEntry> _displayedReviews = [];
  final ScrollController _scrollController = ScrollController();
  final int _pageSize = 5; // Loading 5 reviews per batch
  bool _isInitialLoading = false;
  bool _isLoadMoreLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;

  String _searchQuery = '';
  Timer? _debounce; // For debouncing search input

  @override
  void initState() {
    super.initState();
    _fetchInitialReviews();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_isLoadMoreLoading &&
          _hasMoreData &&
          !_isInitialLoading) {
        _loadMoreReviews();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Fetch initial reviews
  Future<void> _fetchInitialReviews({bool isRefresh = false}) async {
    if (_isInitialLoading) return; // Prevent multiple initial fetches

    setState(() {
      _isInitialLoading = true;
      if (isRefresh) {
        _currentPage = 1;
        _hasMoreData = true;
        _allReviews.clear();
        _displayedReviews.clear();
      }
    });

    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      // **Important:** Replace '127.0.0.1' with your server's IP address or use a tunneling service like ngrok.
      final url = Uri.parse(
          'http://127.0.0.1:8000/json/?page=$_currentPage&page_size=$_pageSize');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );



      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> reviewsJson = jsonResponse['reviews'];

        final fetchedReviews =
            reviewsJson.map((data) => ReviewEntry.fromJson(data)).toList();

        setState(() {
          _currentPage++;
          _hasMoreData = jsonResponse['has_next'];

          _allReviews.addAll(fetchedReviews);
          _applyFilter(); // Apply search filter
          _isInitialLoading = false;
        });
      } else {
        setState(() {
          _isInitialLoading = false;
        });
        throw Exception('Failed to load reviews: ${response.body}');
      }
    } catch (error) {
      setState(() {
        _isInitialLoading = false;
      });
      print('Error: $error');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching reviews: $error'),
        ),
      );
    }
  }

  // Fetch more reviews for pagination
  Future<void> _fetchMoreReviews() async {
    if (_isLoadMoreLoading || !_hasMoreData) return; // Prevent multiple fetches

    setState(() {
      _isLoadMoreLoading = true;
    });

    try {
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      // **Important:** Replace '127.0.0.1' with your server's IP address or use a tunneling service like ngrok.
      final url = Uri.parse(
          'http://127.0.0.1:8000/json/?page=$_currentPage&page_size=$_pageSize');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      // **Optional:** Simulate network delay for testing purposes
      await Future.delayed(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        List<dynamic> reviewsJson = jsonResponse['reviews'];

        final fetchedReviews =
            reviewsJson.map((data) => ReviewEntry.fromJson(data)).toList();

        setState(() {
          _currentPage++;
          _hasMoreData = jsonResponse['has_next'];

          _allReviews.addAll(fetchedReviews);
          _applyFilter(); // Apply search filter
          _isLoadMoreLoading = false;
        });
      } else {
        setState(() {
          _isLoadMoreLoading = false;
        });
        throw Exception('Failed to load reviews: ${response.body}');
      }
    } catch (error) {
      setState(() {
        _isLoadMoreLoading = false;
      });
      print('Error: $error');
      // Display an error message to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching reviews: $error'),
        ),
      );
    }
  }

  void _loadMoreReviews() {
    _fetchMoreReviews();
  }

  // Apply search filter
  void _applyFilter() {
    setState(() {
      if (_searchQuery.isEmpty) {
        _displayedReviews
          ..clear()
          ..addAll(_allReviews);
      } else {
        _displayedReviews
          ..clear()
          ..addAll(_allReviews.where((review) {
            final usernameLower = review.username.toLowerCase();
            final reviewTextLower = review.reviewText.toLowerCase();
            final queryLower = _searchQuery.toLowerCase();
            return usernameLower.contains(queryLower) ||
                reviewTextLower.contains(queryLower);
          }).toList());
      }
    });
  }

  // Handle search input with debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 00), () {
      setState(() {
        _searchQuery = query;
        _applyFilter();
      });
    });
  }

  // Refresh reviews (pull-to-refresh)
  Future<void> _refreshReviews() async {
    await _fetchInitialReviews(isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Review List'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                labelText: 'Search reviews...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refreshReviews,
              child: _isInitialLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _displayedReviews.isEmpty
                      ? const Center(child: Text('No reviews found.'))
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16.0),
                          itemCount: _displayedReviews.length +
                              (_isLoadMoreLoading && _hasMoreData ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index < _displayedReviews.length) {
                              final review = _displayedReviews[index];
                              return GestureDetector(
                                onTap: () {
                                  // Placeholder for review detail navigation
                                },
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 12),
                                  padding: const EdgeInsets.all(20.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10.0),
                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black26,
                                        blurRadius: 5.0,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "User: ${review.username}",
                                        style: const TextStyle(
                                          fontSize: 18.0,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text("Review: ${review.reviewText}"),
                                      const SizedBox(height: 10),
                                      Text("Rating: ${review.rating}/5"),
                                      const SizedBox(height: 10),
                                      Text(
                                          "Created At: ${review.createdAt.toLocal().toString().split(' ')[0]}"),
                                    ],
                                  ),
                                ),
                              );
                            } else {
                              // Bottom Loading Indicator
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.0),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
            ),
          ),
        ],
      ),
    );
  }
}

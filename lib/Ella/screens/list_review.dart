import 'package:flutter/material.dart';
import 'package:wanderscout/ella/models/review_entry.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:wanderscout/ella/services/review_api.dart';

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final ReviewApi _api = ReviewApi();

  List<ReviewEntry> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 5;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 1));

      final fetchedReviews = await _api.fetchReviews(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        // Check if fetched reviews are empty
        if (fetchedReviews.isEmpty) {
          _hasMore = false;
        } else {
          // Check for duplicates
          final fetchedIds = fetchedReviews.map((review) => review.id).toSet();
          final existingIds = _reviews.map((review) => review.id).toSet();
          final isDuplicate = fetchedIds.intersection(existingIds).isNotEmpty;

          if (isDuplicate) {
            _hasMore = false;
          } else {
            _reviews.addAll(fetchedReviews);
            _currentPage++;
            // If fewer reviews than pageSize are returned, no more reviews are available.
            if (fetchedReviews.length < _pageSize) {
              _hasMore = false;
            }
          }
        }

      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reviews: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshReviews() async {
    setState(() {
      _reviews.clear();
      _hasMore = true;
      _currentPage = 1;
    });
    await _fetchReviews();
  }

  void _loadMoreReviews() {
    if (_isLoading || !_hasMore) return;
    _fetchReviews();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reviews'),
      ),
      drawer: const LeftDrawer(),
      body: Column(
        children: [
          Expanded(
            child: _reviews.isEmpty && _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshReviews,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: (ScrollNotification scrollInfo) {
                        if (!_isLoading &&
                            _hasMore &&
                            scrollInfo.metrics.pixels >=
                                scrollInfo.metrics.maxScrollExtent - 200) {
                          _loadMoreReviews();
                        }
                        return false;
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        itemCount:
                            _reviews.length + (_isLoading && _hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index < _reviews.length) {
                            final review = _reviews[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(
                                vertical: 8.0,
                                horizontal: 16.0,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      review.username,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(review.reviewText),
                                    const SizedBox(height: 8),
                                    Text('Rating: ${review.rating}/5'),
                                    const SizedBox(height: 8),
                                    Text(
                                      "Created At: ${review.createdAt.toLocal().toString().split(' ')[0]}",
                                    ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            // Loading indicator at the bottom
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
          ),
        ],
      ),
    );
  }
}

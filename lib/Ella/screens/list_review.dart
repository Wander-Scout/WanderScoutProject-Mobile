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
  bool _isLoading = false; // Tracks loading state for reviews
  bool _hasMore = true; // Indicates if there are more reviews to load
  int _currentPage = 1;
  final int _pageSize = 5;

  bool _isAdmin = false; // Tracks if the user is an admin

  @override
  void initState() {
    super.initState();
    _checkAdminStatus();
    _fetchReviews();
  }

  /// Check if the current user is an admin
  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _api.isAdmin(); // Check admin status from the API
      setState(() {
        _isAdmin = isAdmin;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking admin status: $error')),
      );
    }
  }

  /// Fetch reviews with pagination
  Future<void> _fetchReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true; // Set loading state
    });

    try {
      // Simulate network delay (2 seconds for better visual loading)
      await Future.delayed(const Duration(seconds: 1));

      final fetchedReviews = await _api.fetchReviews(
        page: _currentPage,
        pageSize: _pageSize,
      );

      setState(() {
        if (fetchedReviews.isEmpty) {
          _hasMore = false; // No more reviews to fetch
        } else {
          _reviews.addAll(fetchedReviews); // Append new reviews
          _currentPage++;
          if (fetchedReviews.length < _pageSize) {
            _hasMore = false; // If fewer reviews than the page size are returned, no more are available
          }
        }
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reviews: $error')),
      );
    } finally {
      setState(() {
        _isLoading = false; // Reset loading state
      });
    }
  }

  /// Refresh the review list
  Future<void> _refreshReviews() async {
    setState(() {
      _reviews.clear();
      _hasMore = true;
      _currentPage = 1;
    });
    await _fetchReviews();
  }

  /// Load more reviews for infinite scrolling
  void _loadMoreReviews() {
    if (_isLoading || !_hasMore) return;
    _fetchReviews();
  }

  /// Add an admin reply
  Future<void> _addAdminReply(int reviewId, String replyText) async {
    try {
      _api.addAdminReply(
        reviewId: reviewId,
        replyText: replyText.trim(),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply added successfully!')),
      );
      _refreshReviews(); // Refresh reviews after adding reply
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding reply: $error')),
      );
    }
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
            child: RefreshIndicator(
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
                  itemCount: _reviews.length + (_hasMore ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index < _reviews.length) {
                      final review = _reviews[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
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
                              if (review.adminReplies.isNotEmpty)
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: review.adminReplies.map((reply) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        "Admin Reply: ${reply.replyText} (${reply.adminUsername})",
                                        style: const TextStyle(
                                          fontStyle: FontStyle.italic,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                )
                              else
                                const Text('No admin replies yet.'),
                              if (_isAdmin) ...[
                                const SizedBox(height: 16),
                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Write your reply...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onSubmitted: (value) {
                                    if (value.isNotEmpty) {
                                      _addAdminReply(review.id, value);
                                    }
                                  },
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    } else if (_hasMore) {
                      // Show loading spinner while fetching more reviews
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      // No more reviews to load
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Center(
                          child: Text('No more reviews to load.'),
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


extension on ReviewEntry {
  get adminReplies => null;
}

extension on ReviewApi {
  isAdmin() {}
  
  void addAdminReply({required int reviewId, required String replyText}) {}
}

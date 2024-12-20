import 'package:flutter/material.dart';
import 'package:wanderscout/Ella/models/review_entry.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:wanderscout/Ella/services/review_api.dart';

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  final ReviewApi _api = ReviewApi();

  final List<ReviewEntry> _reviews = [];
  bool _isLoading = false;
  bool _hasMore = true;
  int _currentPage = 1;
  final int _pageSize = 5;

  bool _isAdmin = false;
  String? _currentUsername;
  String _selectedRating = 'All Ratings';

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    _initializeUserState();
  }

  void _onScroll() {
    if (!_isLoading &&
        _hasMore &&
        _scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200) {
      _loadMoreReviews();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeUserState() async {
    await _checkAdminStatus();
    if (!mounted) return;
    await _fetchCurrentUser();
    if (!mounted) return;
    await _fetchReviews();
  }

  Future<void> _checkAdminStatus() async {
    try {
      final isAdmin = await _api.isAdmin();
      if (!mounted) return;
      setState(() {
        _isAdmin = isAdmin;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error checking admin status: $error')),
      );
    }
  }

  Future<void> _fetchCurrentUser() async {
    try {
      final username = await _api.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _currentUsername = username;
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching current user: $error')),
      );
    }
  }

  Future<void> _fetchReviews() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    try {
      int? ratingFilter;
      if (_selectedRating != 'All Ratings') {
        ratingFilter = int.tryParse(_selectedRating);
      }

      final fetchedReviews = await _api.fetchReviews(
        page: _currentPage,
        pageSize: _pageSize,
        rating: ratingFilter,
      );
      if (!mounted) return;

      setState(() {
        if (fetchedReviews.isEmpty) {
          _hasMore = false;
        } else {
          _reviews.addAll(fetchedReviews);
          _currentPage++;
          if (fetchedReviews.length < _pageSize) {
            _hasMore = false;
          }
        }
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching reviews: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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

  Future<void> _addAdminReply(int reviewId, String replyText) async {
    try {
      await _api.addAdminReply(reviewId: reviewId, replyText: replyText.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reply added successfully!')),
      );
      await _refreshReviews();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding reply: $error')),
      );
    }
  }

  Future<void> _deleteReview(int reviewId) async {
    try {
      await _api.deleteReview(reviewId);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review deleted successfully!')),
      );
      setState(() {
        _reviews.removeWhere((r) => r.id == reviewId);
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting review: $error')),
      );
    }
  }

  bool _canDeleteReview(ReviewEntry review) {
    return _isAdmin || (_currentUsername != null && review.username == _currentUsername);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Reviews'),
        backgroundColor: const Color(0xFF313EBC), // Solid color for title
      ),
      drawer: const LeftDrawer(),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF313EBC), Color(0xFFA6ADEF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text(
                    'Filter by Rating: ',
                    style: TextStyle(color: Colors.white),
                  ),
                  DropdownButton<String>(
                    dropdownColor: const Color(0xFFA6ADEF),
                    value: _selectedRating,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedRating = newValue ?? 'All Ratings';
                      });
                    },
                    items: <String>['All Ratings', '1', '2', '3', '4', '5']
                        .map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(
                          value,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFA6ADEF),
                    ),
                    onPressed: _refreshReviews,
                    child: const Text('Apply'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refreshReviews,
                child: _buildReviewList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewList() {
    if (_reviews.isEmpty && !_isLoading) {
      return const Center(
        child: Text(
          'No reviews available.',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _reviews.length + (_hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < _reviews.length) {
          final review = _reviews[index];
          final hasAdminReplies = review.adminReplies.isNotEmpty;

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 5,
            child: Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFB27FEC), Color(0xFFFFFFFF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${review.username.toUpperCase()} says..',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      if (_canDeleteReview(review))
                        IconButton(
                          icon: const Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            _deleteReview(review.id);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    review.reviewText.isNotEmpty
                        ? '"${review.reviewText}"'
                        : 'No rating message available',
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rating: ${review.rating}/5',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (hasAdminReplies)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: review.adminReplies.map((reply) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Admin Reply: ${reply.replyText} (${reply.adminUsername})",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 14,
                              color: Colors.black54,
                            ),
                          ),
                        );
                      }).toList(),
                    )
                  else
                    const Text(
                      'No admin replies yet.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 14,
                        color: Colors.black45,
                      ),
                    ),
                  if (_isAdmin) ...[
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                        labelText: 'Write your reply...',
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
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
        } else {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          );
        }
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:wanderscout/ella/models/review_entry.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ReviewListPage extends StatefulWidget {
  const ReviewListPage({super.key});

  @override
  State<ReviewListPage> createState() => _ReviewListPageState();
}

class _ReviewListPageState extends State<ReviewListPage> {
  // Function to fetch reviews using the authentication token
  Future<List<ReviewEntry>> fetchReviews() async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('http://127.0.0.1:8000/json/');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Token $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonResponse = jsonDecode(response.body);
      return jsonResponse.map((data) => ReviewEntry.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load reviews: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed CookieRequest since we're using token authentication
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review List',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<ReviewEntry>>(
        future: fetchReviews(), // Updated to call fetchReviews without parameters
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontSize: 18, color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No reviews found. Add some reviews!',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          } else {
            final reviews = snapshot.data!;
            return ListView.builder(
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                final review = reviews[index];
                return GestureDetector(
                  onTap: () {
                    // Placeholder for review detail navigation
                    // Navigator.push(...);
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                          "User: ${review.username}", // Handle null username
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
                        Text("Created At: ${review.createdAt.toLocal().toString().split(' ')[0]}"),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}

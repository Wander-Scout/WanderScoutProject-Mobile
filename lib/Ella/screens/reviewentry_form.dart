import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:wanderscout/ella/screens/list_review.dart'; // Import the ReviewListPage
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class ReviewEntryFormPage extends StatefulWidget {
  const ReviewEntryFormPage({super.key});

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _reviewText = "";
  int _rating = 1;

  // Function to submit the review using the authentication token
  Future<void> submitReview(String reviewText, int rating) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token'); // Retrieve the token


    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }

    final url = Uri.parse('http://127.0.0.1:8000/apireview/');
    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Token $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'review_text': reviewText,
        'rating': rating,
      }),
    );

    if (response.statusCode != 201 && response.statusCode != 200) {
      throw Exception('Failed to submit review: ${response.body}');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Removed CookieRequest since we're using token authentication
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add Your Review!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: InputDecoration(
                    hintText: "Enter your review",
                    labelText: "Review",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _reviewText = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Review text cannot be empty!";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "Rating",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: _rating,
                  items: List.generate(5, (index) {
                    return DropdownMenuItem(
                      value: index + 1,
                      child: Text("${index + 1}"),
                    );
                  }),
                  onChanged: (value) {
                    setState(() {
                      _rating = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        try {
                          // Send data to the backend
                          await submitReview(_reviewText, _rating);

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Review added successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                            // Redirect to Review List Page
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ReviewListPage(),
                              ),
                            );
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Error: $e"),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Save",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

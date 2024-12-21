import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wanderscout/Davin/widgets/left_drawer.dart';
import 'package:wanderscout/Ella/screens/list_review.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ReviewEntryFormPage extends StatefulWidget {
  const ReviewEntryFormPage({super.key});

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _reviewText = "";
  int _rating = 1;


  Future<void> submitReview(String reviewText, int rating) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'auth_token');

    if (token == null) {
      throw Exception('Authentication token not found. Please log in.');
    }


    final String? baseUrl = dotenv.env['BASE_URL'];
    if (baseUrl == null) {
      throw Exception('BASE_URL is not set in the .env file.');
    }

    final url = Uri.parse('$baseUrl/apireview/');
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
    return Scaffold(
      appBar: AppBar(
        title: const Center(
          child: Text(
            'Add Your Review!',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFF313EBC),
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Container(
        height: double.infinity, // Ensure it covers the full height
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF313EBC), Color(0xFFA6ADEF)], // Blue gradient
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Write your review:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Enter your review here...",
                      hintStyle: TextStyle(color: Colors.grey.shade300),
                      labelText: "Review",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
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
                  const Text(
                    "Rate your experience:",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: "Rating",
                      labelStyle: const TextStyle(color: Colors.white),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.2),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                    ),
                    dropdownColor: const Color(0xFF313EBC),
                    value: _rating,
                    items: List.generate(5, (index) {
                      return DropdownMenuItem(
                        value: index + 1,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }),
                    onChanged: (value) {
                      setState(() {
                        _rating = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFA6ADEF),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          try {
                            await submitReview(_reviewText, _rating);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Review added successfully!"),
                                  backgroundColor: Colors.green,
                                ),
                              );
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
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

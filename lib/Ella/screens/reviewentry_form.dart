import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:wanderscout/davin/widgets/left_drawer.dart';
import 'package:wanderscout/ella/screens/list_review.dart'; // Import the ReviewListPage
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';

class ReviewEntryFormPage extends StatefulWidget {
  const ReviewEntryFormPage({super.key});

  @override
  State<ReviewEntryFormPage> createState() => _ReviewEntryFormPageState();
}

class _ReviewEntryFormPageState extends State<ReviewEntryFormPage> {
  final _formKey = GlobalKey<FormState>();
  String _reviewText = "";
  int _rating = 1;

  @override
  Widget build(BuildContext context) {
    final request = context.watch<CookieRequest>();

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
                          final response = await request.postJson(
                            "http://127.0.0.1:8000/create-flutter/",
                            jsonEncode(<String, dynamic>{
                              'review_text': _reviewText,
                              'rating': _rating,
                            }),
                          );

                          if (context.mounted) {
                            if (response['status'] == 'success') {
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
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    "Failed to add review: ${response['message']}",
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
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

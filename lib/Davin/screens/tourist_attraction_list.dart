import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'dart:convert';
import 'package:wanderscout/davin/widgets/left_drawer.dart'; // Adjust the path

class TouristAttractionScreen extends StatefulWidget {
  const TouristAttractionScreen({super.key});

  @override
  State<TouristAttractionScreen> createState() => _TouristAttractionScreenState();
}

class _TouristAttractionScreenState extends State<TouristAttractionScreen> {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<List<TouristAttraction>> fetchTouristAttractions() async {
    try {
      // Retrieve the authentication token
      final token = await _storage.read(key: 'auth_token');

      if (token == null) {
        throw Exception('Authentication token not found. Please log in.');
      }

      // Make the HTTP GET request to fetch the tourist attractions
      final url = Uri.parse('http://127.0.0.1:8000/tourist_attraction/api_tourist_attractions');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Token $token',
        },
      );

      // Handle the response
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body);
        return jsonResponse.map((json) => TouristAttraction.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        throw Exception('Unauthorized. Please log in again.');
      } else {
        throw Exception('Failed to fetch tourist attractions: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching tourist attractions: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourist Attractions'),
      ),
      drawer: const LeftDrawer(),
      body: FutureBuilder<List<TouristAttraction>>(
        future: fetchTouristAttractions(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'No tourist attractions found.',
                style: TextStyle(fontSize: 20, color: Color(0xff59A5D8)),
              ),
            );
          } else {
            final attractions = snapshot.data!;
            return ListView.builder(
              itemCount: attractions.length,
              itemBuilder: (_, index) {
                final attraction = attractions[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                      Text("Weekday Price: IDR ${attraction.htmWeekday}"),
                      const SizedBox(height: 10),
                      Text("Weekend Price: IDR ${attraction.htmWeekend}"),
                      const SizedBox(height: 10),
                      Text("Description: ${attraction.description}"),
                      // Add more fields as needed
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
              },
            );
          }
        },
      ),
    );
  }
}

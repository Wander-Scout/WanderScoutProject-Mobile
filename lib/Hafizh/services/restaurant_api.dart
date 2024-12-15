// restaurant_api.dart
import 'dart:convert';
import 'package:wanderscout/Hafizh/models/restaurant.dart'; // Adjust the path if necessary
import 'package:wanderscout/Davin/API/api_service.dart';

class RestaurantApi {
  final ApiService _apiService;
  final String _baseUrl = 'https://alano-davin-wanderscout.pbp.cs.ui.ac.id/';

  // Initialize the API service
  RestaurantApi() : _apiService = ApiService();

  Future<List<Restaurant>> fetchRestaurants() async {
    // Make the GET request
    final response = await _apiService.get(
      url: '${_baseUrl}restaurant/api_restaurant/',
    );

    // Check for HTTP errors
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch restaurants. Status Code: ${response.statusCode}. Body: ${response.body}',
      );
    }

    // Parse the JSON response
    final List<dynamic> jsonResponse = jsonDecode(response.body);

    // Map JSON data to Restaurant objects
    return jsonResponse.map((json) => Restaurant.fromJson(json)).toList();
  }

  // Add more methods for other operations if necessary
}

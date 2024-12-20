import 'dart:convert';
import 'package:wanderscout/Hafizh/models/restaurant.dart'; 
import 'package:wanderscout/Davin/API/api_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';



class RestaurantApi {
  final ApiService _apiService;
  final String? baseUrl = dotenv.env['BASE_URL'];

  // Initialize the API service
  RestaurantApi() : _apiService = ApiService();

  Future<List<Restaurant>> fetchRestaurants() async {
    // Make the GET request
    final response = await _apiService.get(
      url: '${baseUrl}restaurant/api_restaurant/',
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

  // Add the editRestaurant method
  Future<void> editRestaurant({
    required String restaurantId,
    required String name,
    required FoodPreference foodPreference,
    required int averagePrice,
    required double rating,
    required Atmosphere atmosphere,
    required String foodVariety,
  }) async {
    final String url = '${baseUrl}restaurant/edit/$restaurantId/';

    final response = await _apiService.post(
      url: url,
      body: {
        "name": name,
        "food_preference": foodPreference.displayName,
        "average_price": averagePrice,
        "rating": rating,
        "atmosphere": atmosphere.displayName,
        "food_variety": foodVariety,
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to edit restaurant: ${response.body}');
    }
  }

  Future<void> deleteRestaurant(String restaurantId) async {
    final String url = '${baseUrl}restaurant/delete/$restaurantId/';

    final response = await _apiService.delete(url: url);

    if (response.statusCode != 200) {
      throw Exception('Failed to delete restaurant: ${response.body}');
    }
  }

}

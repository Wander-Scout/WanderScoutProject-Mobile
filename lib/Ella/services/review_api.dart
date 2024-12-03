import 'dart:convert';
import 'package:wanderscout/ella/models/review_entry.dart'; 
import 'package:wanderscout/davin/API/api_service.dart';

class ReviewApi {
  final ApiService _apiService;
  final String _baseUrl = 'http://127.0.0.1:8000/';

  // Initialize the API service
  ReviewApi() : _apiService = ApiService();

  Future<List<ReviewEntry>> fetchReviews({
    required int page,
    required int pageSize,
  }) async {
    // Make the GET request with pagination parameters
    final response = await _apiService.get(
      url: '${_baseUrl}json/', // The endpoint for fetching reviews
      queryParams: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    // Check for HTTP errors
    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch reviews. Status Code: ${response.statusCode}. Body: ${response.body}',
      );
    }

    // Parse the JSON response
    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    // Check if the "reviews" key exists in the JSON response
    if (!jsonResponse.containsKey('reviews')) {
      throw Exception('Invalid response format: "reviews" key not found.');
    }

    // Map JSON data to ReviewEntry objects
    final List<dynamic> reviewsJson = jsonResponse['reviews'] as List<dynamic>;
    return reviewsJson.map((json) => ReviewEntry.fromJson(json)).toList();
  }

}

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
    final response = await _apiService.get(
      url: '${_baseUrl}json/', // The endpoint for fetching reviews
      queryParams: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Failed to fetch reviews. Status Code: ${response.statusCode}. Body: ${response.body}',
      );
    }

    final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

    if (!jsonResponse.containsKey('reviews')) {
      throw Exception('Invalid response format: "reviews" key not found.');
    }

    final List<dynamic> reviewsJson = jsonResponse['reviews'] as List<dynamic>;
    return reviewsJson.map((json) => ReviewEntry.fromJson(json)).toList();
  }

  // Check if the user is an admin
  Future<bool> isAdmin() async {
    final response = await _apiService.get(
      url: '${_baseUrl}check_if_admin/', // Django endpoint to check admin status
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['is_admin'] ?? false;
    } else {
      throw Exception('Failed to check admin status');
    }
  }

  // Add a reply as an admin
  Future<void> addAdminReply({
    required int reviewId,
    required String replyText,
  }) async {
    final response = await _apiService.post(
      url: '${_baseUrl}reviews/$reviewId/reply/',
      body: {'reply_text': replyText}, // Pass the body as a Map<String, dynamic>
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add reply: ${response.body}');
    }
  }

}

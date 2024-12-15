import 'dart:convert';
import 'package:wanderscout/Ella/models/review_entry.dart';
import 'package:wanderscout/Davin/API/api_service.dart';

class ReviewApi {
  final ApiService _apiService;
  final String _baseUrl = 'https://alano-davin-wanderscout.pbp.cs.ui.ac.id/';

  // Initialize the API service
  ReviewApi() : _apiService = ApiService();

  Future<List<ReviewEntry>> fetchReviews({
    required int page,
    required int pageSize,
    int? rating,
  }) async {
    // Build query parameters
    final queryParams = {
      'page': '$page',
      'page_size': '$pageSize',
    };

    // Add rating only if it's provided
    if (rating != null) {
      queryParams['rating'] = rating.toString();
    }

    final response = await _apiService.get(
      url: '${_baseUrl}json/',
      queryParams: queryParams,
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
      url: '${_baseUrl}check_if_admin/',
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
      body: {'reply_text': replyText},
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to add reply: ${response.body}');
    }
  }

  // Get the current logged-in user's username
  Future<String> getCurrentUser() async {
    final response = await _apiService.get(
      url: '${_baseUrl}get_current_user/',
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.containsKey('username')) {
        return data['username'];
      } else {
        throw Exception('Response does not contain "username" field.');
      }
    } else {
      throw Exception('Failed to get current user: ${response.body}');
    }
  }

  // Delete a review
  Future<void> deleteReview(int reviewId) async {
    final response = await _apiService.delete(
      url: '${_baseUrl}reviews/$reviewId/delete/',
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete review: ${response.body}');
    }
  }
}

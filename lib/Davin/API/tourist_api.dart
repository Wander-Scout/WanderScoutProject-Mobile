// services/tourist_attraction_api.dart
import 'dart:convert';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'api_service.dart';

class TouristAttractionApi {
  final ApiService _apiService = ApiService();
  final String _baseUrl = 'http://127.0.0.1:8000/tourist_attraction';

  Future<List<TouristAttraction>> fetchTouristAttractions({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiService.get(
      url: '$_baseUrl/api_tourist_attractions',
      queryParams: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((json) => TouristAttraction.fromJson(json)).toList();
  }

  // You can add more methods like fetchById, create, update, delete, etc.
}

import 'dart:convert';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'api_service.dart';

class TouristAttractionApi {
  final ApiService _apiService = ApiService();
  final String _baseUrl = 'https://alano-davin-wanderscout.pbp.cs.ui.ac.id/tourist_attraction';

  Future<List<TouristAttraction>> fetchTouristAttractions({
    required int page,
    required int pageSize,
  }) async {
    // You can pass origin/referer if needed, or rely on defaults in ApiService
    final response = await _apiService.get(
      url: '$_baseUrl/api_tourist_attractions',
      queryParams: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((json) => TouristAttraction.fromJson(json)).toList();
  }
}

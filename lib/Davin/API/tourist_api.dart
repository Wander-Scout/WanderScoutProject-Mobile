import 'dart:convert';
import 'package:wanderscout/Davin/models/touristattraction.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_service.dart';

class TouristAttractionApi {
  final ApiService _apiService = ApiService();
  final String _baseUrl = dotenv.env['BASE_URL']!;

  String get _touristAttractionUrl => '${_baseUrl}tourist_attraction';

  Future<List<TouristAttraction>> fetchTouristAttractions({
    required int page,
    required int pageSize,
  }) async {
    final response = await _apiService.get(
      url: '$_touristAttractionUrl/api_tourist_attractions',
      queryParams: {
        'page': '$page',
        'page_size': '$pageSize',
      },
    );

    final List<dynamic> jsonResponse = jsonDecode(response.body);
    return jsonResponse.map((json) => TouristAttraction.fromJson(json)).toList();
  }

  Future<TouristAttraction> addTouristAttraction(TouristAttraction attraction) async {
    final response = await _apiService.post(
      url: '$_touristAttractionUrl/api_tourist_attractions/add',
      body: attraction.toJson(),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data.containsKey('attraction_id')) {
      return TouristAttraction(
        id: data['attraction_id'],
        no: attraction.no,
        nama: attraction.nama,
        rating: attraction.rating,
        voteAverage: attraction.voteAverage,
        voteCount: attraction.voteCount,
        type: attraction.type,
        htmWeekday: attraction.htmWeekday,
        htmWeekend: attraction.htmWeekend,
        description: attraction.description,
        gmapsUrl: attraction.gmapsUrl,
        latitude: attraction.latitude,
        longitude: attraction.longitude,
      );
    } else {
      throw Exception('Failed to add attraction: ${data['error']}');
    }
  }

  Future<TouristAttraction> editTouristAttraction(TouristAttraction attraction) async {
    if (attraction.id.isEmpty) {
      throw Exception('Attraction ID is required to edit an attraction.');
    }

    final response = await _apiService.post(
      url: '$_touristAttractionUrl/api_tourist_attractions/edit/${attraction.id}/',
      body: attraction.toJson(),
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (data.containsKey('attraction_id')) {
      return attraction;
    } else {
      throw Exception('Failed to edit attraction: ${data['error']}');
    }
  }

  Future<void> deleteTouristAttraction(String attractionId) async {
    if (attractionId.isEmpty) {
      throw Exception('Attraction ID is required to delete an attraction.');
    }

    final response = await _apiService.delete(
      url: '$_touristAttractionUrl/api_tourist_attractions/delete/$attractionId/',
    );

    final Map<String, dynamic> data = jsonDecode(response.body);
    if (!data.containsKey('message')) {
      throw Exception('Failed to delete attraction: ${data['error']}');
    }
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://127.0.0.1:8000/restaurant/api_restaurant/';

  Future<Map<String, dynamic>> fetchRestaurants() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      return json.decode(response.body); // Return the JSON as a map
    } else {
      throw Exception('Failed to load restaurants');
    }
  }
}

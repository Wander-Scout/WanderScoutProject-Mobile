// services/api_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'http_service.dart';

class ApiService {
  final HttpService _httpService = HttpService();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'auth_token');
    if (token == null) throw Exception('Authentication token not found. Please log in.');
    return {'Authorization': 'Token $token'};
  }

  Future<http.Response> get({
    required String url,
    Map<String, String>? queryParams,
  }) async {
    final headers = await _getHeaders();
    return _httpService.get(url: url, headers: headers, queryParams: queryParams);
  }


  Future<http.Response> post({
    required String url,
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    return _httpService.post(url: url, headers: headers, body: body ?? {});
  }

}

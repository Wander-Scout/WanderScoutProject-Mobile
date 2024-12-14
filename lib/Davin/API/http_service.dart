import 'dart:convert';
import 'package:http/http.dart' as http;

class HttpService {
  Future<http.Response> get({
    required String url,
    required Map<String, String> headers,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: headers);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
        'Failed to fetch data from $url. Status Code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<http.Response> post({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);

    final response = await http.post(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
        'Failed to post data to $url. Status Code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<http.Response> put({
    required String url,
    required Map<String, String> headers,
    required Map<String, dynamic> body,
  }) async {
    final uri = Uri.parse(url);

    print('PUT Request: $uri');
    print('Headers: $headers');
    print('Body: $body');

    final response = await http.put(
      uri,
      headers: headers,
      body: jsonEncode(body),
    );

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
        'Failed to update data at $url. Status Code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<http.Response> delete({
    required String url,
    required Map<String, String> headers,
  }) async {
    final uri = Uri.parse(url);

    print('DELETE Request: $uri');
    print('Headers: $headers');

    final response = await http.delete(uri, headers: headers);

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      throw Exception(
        'Failed to delete data at $url. Status Code: ${response.statusCode}, Body: ${response.body}',
      );
    }
  }

  Future<http.Response> options({
    required String url,
    required Map<String, String> headers,
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(url).replace(queryParameters: queryParams);

    print('OPTIONS Request: $uri');
    print('Headers: $headers');

    final request = http.Request('OPTIONS', uri);
    request.headers.addAll(headers);

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    print('Response Status Code: ${response.statusCode}');
    print('Response Body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      // Not necessarily an error for OPTIONS, but handle as needed.
      return response; 
    }
  }
}

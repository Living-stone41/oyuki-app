import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../user_session.dart';

class ApiException implements Exception {
  final String message;
  ApiException(this.message);

  @override
  String toString() => message;
}

class ApiClient {
  static const _defaultBaseUrl = 'http://127.0.0.1:8000/api/v1';
  static const baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: _defaultBaseUrl,
  );

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated && UserSession.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${UserSession.accessToken}';
    }

    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: headers,
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static Future<Map<String, dynamic>> get(
    String path, {
    bool authenticated = false,
  }) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (authenticated && UserSession.accessToken.isNotEmpty) {
      headers['Authorization'] = 'Bearer ${UserSession.accessToken}';
    }

    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: headers)
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw ApiException('The server returned an invalid response.');
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      final message = decoded['message']?.toString() ?? 'Request failed.';
      throw ApiException(message);
    }
    return decoded;
  }

  static String connectionError(Object error) {
    if (error is TimeoutException || error is http.ClientException) {
      return 'Backend is unavailable. Start the Django server and try again.';
    }
    return 'Unable to connect to the backend.';
  }
}

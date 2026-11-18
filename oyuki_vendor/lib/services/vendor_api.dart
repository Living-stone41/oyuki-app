import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class VendorApiException implements Exception {
  final String message;
  VendorApiException(this.message);
  @override
  String toString() => message;
}

class VendorApi {
  VendorApi._();

  static const baseUrl = String.fromEnvironment(
    'VENDOR_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000/api/v1',
  );

  static const _storage = FlutterSecureStorage();
  static const _accessKey = 'oyuki_vendor_access_token';
  static const _refreshKey = 'oyuki_vendor_refresh_token';

  static Future<String> get accessToken async =>
      await _storage.read(key: _accessKey) ?? '';

  static Future<Map<String, String>> _headers() async {
    final token = await accessToken;
    return {
      'Content-Type': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static Future<Map<String, dynamic>> get(String path) async {
    final response = await http
        .get(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await http
        .patch(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body ?? {}),
        )
        .timeout(const Duration(seconds: 20));
    return _decode(response);
  }

  static Future<void> delete(String path) async {
    final response = await http
        .delete(Uri.parse('$baseUrl$path'), headers: await _headers())
        .timeout(const Duration(seconds: 20));
    if (response.statusCode < 200 || response.statusCode >= 300) {
      _decode(response);
    }
  }

  static Future<void> saveSession(String access, String refresh) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
  }

  static Future<bool> restoreSession() async {
    final access = await _storage.read(key: _accessKey) ?? '';
    return access.isNotEmpty;
  }

  static Future<void> clearSession() async {
    await _storage.delete(key: _accessKey);
    await _storage.delete(key: _refreshKey);
  }

  static Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body);

    if (decoded is! Map<String, dynamic>) {
      throw VendorApiException('The server returned an invalid response.');
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw VendorApiException(
        decoded['message']?.toString() ?? 'Request failed.',
      );
    }
    return decoded;
  }
}

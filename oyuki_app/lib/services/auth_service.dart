import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../user_session.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();

  static const _storage = FlutterSecureStorage();

  static const _accessKey = 'oyuki_access_token';
  static const _refreshKey = 'oyuki_refresh_token';
  static const _userIdKey = 'oyuki_user_id';
  static const _nameKey = 'oyuki_user_name';
  static const _emailKey = 'oyuki_user_email';

  static Future<void> restoreSession() async {
    final access = await _storage.read(key: _accessKey) ?? '';
    final refresh = await _storage.read(key: _refreshKey) ?? '';
    final name = await _storage.read(key: _nameKey) ?? '';
    final email = await _storage.read(key: _emailKey) ?? '';
    final userId = await _storage.read(key: _userIdKey);

    UserSession.setTokens(access: access, refresh: refresh);
    UserSession.update(name: name, accountEmail: email);
    UserSession.userId = int.tryParse(userId ?? '');
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await ApiClient.post('/auth/register/', body: {
      'name': name,
      'email': email,
      'password': password,
      'role': 'buyer',
    });
    await _saveAuthResult(result);
    return result;
  }

  static Future<Map<String, dynamic>> login({
    required String identifier,
    required String password,
  }) async {
    final result = await ApiClient.post('/auth/login/', body: {
      'identifier': identifier,
      'password': password,
    });
    await _saveAuthResult(result);
    return result;
  }

  static Future<void> logout() async {
    try {
      if (UserSession.refreshToken.isNotEmpty) {
        await ApiClient.post('/auth/logout/', body: {
          'refresh': UserSession.refreshToken,
        }, authenticated: true);
      }
    } catch (_) {
      // Local session cleanup must still succeed when the network is offline.
    }
    await _storage.deleteAll();
    UserSession.clear();
  }

  static Future<void> forgotPassword(String identifier) =>
      ApiClient.post('/auth/password/forgot/', body: {'identifier': identifier});

  static Future<void> verifyResetOtp(String identifier, String otp) =>
      ApiClient.post('/auth/password/verify-otp/', body: {
        'identifier': identifier,
        'otp': otp,
      });

  static Future<void> resetPassword({
    required String identifier,
    required String otp,
    required String password,
  }) => ApiClient.post('/auth/password/reset/', body: {
        'identifier': identifier,
        'otp': otp,
        'password': password,
      });

  static Future<void> _saveAuthResult(Map<String, dynamic> result) async {
    final access = result['access']?.toString() ?? '';
    final refresh = result['refresh']?.toString() ?? '';
    final user = result['user'];

    String name = '';
    String email = '';
    int? userId;

    if (user is Map) {
      name = user['name']?.toString() ?? '';
      email = user['email']?.toString() ?? '';
      userId = int.tryParse(user['id']?.toString() ?? '');
    }

    if (access.isEmpty) {
      throw ApiException('The server response did not include an access token.');
    }

    UserSession.setTokens(access: access, refresh: refresh);
    UserSession.update(name: name, accountEmail: email);
    UserSession.userId = userId;

    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _nameKey, value: name);
    await _storage.write(key: _emailKey, value: email);
    if (userId != null) {
      await _storage.write(key: _userIdKey, value: userId.toString());
    }
  }
}

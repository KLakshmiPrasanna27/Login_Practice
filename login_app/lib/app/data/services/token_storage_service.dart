import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorageService {

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage();

  static const String _tokenKey = 'jwt_token';

  // Save JWT token
  Future<void> saveToken(String token) async {
    await _storage.write(
      key: _tokenKey,
      value: token,
    );
  }

  // Retrieve JWT token
  Future<String?> getToken() async {
    return await _storage.read(
      key: _tokenKey,
    );
  }

  // Delete JWT token
  Future<void> deleteToken() async {
    await _storage.delete(
      key: _tokenKey,
    );
  }

  // Check whether token exists
  Future<bool> hasToken() async {
    final token = await getToken();

    return token != null && token.isNotEmpty;
  }
}
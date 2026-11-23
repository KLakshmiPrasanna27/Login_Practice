import 'dart:convert';

import 'package:http/http.dart' as http;

import '../endpoints/api_endpoints.dart';
import '../models/user_model.dart';
import 'token_storage_service.dart';

class AuthService {
  AuthService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  final TokenStorageService _tokenStorage = TokenStorageService();

  final Map<String, String> _headers = {'Content-Type': 'application/json'};

  // ================= REGISTER =================


  Future<UserModel> register({
    required String name,
    required String username,
    required String email,
    required String phone,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.register),
      headers: _headers,
      body: jsonEncode({
        'full_name': name,
        'username': username,
        'email': email,
        'phone': phone,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return UserModel.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Registration failed');
  }

  // ================= REQUEST LOGIN OTP =================

  Future<bool> requestLoginOtp({
    required String username,
    required String password,
    required String phone,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.login),
      headers: _headers,
      body: jsonEncode({
        'username': username,
        'password': password,
        'phone': phone,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return true;
    }

    throw Exception(data['message'] ?? 'Failed to request login OTP');
  }

  // ================= VERIFY OTP =================

  Future<UserModel> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    final response = await _client.post(
      Uri.parse(ApiEndpoints.verifyOtp),
      headers: _headers,
      body: jsonEncode({'phone': phone, 'otp': otp}),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _tokenStorage.saveToken(data['token']);

      return UserModel.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'OTP verification failed');
  }

  // ================= GET PROFILE =================

  Future<UserModel> getProfile() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login first');
    }

    final response = await _client.get(
      Uri.parse(ApiEndpoints.getProfile),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Failed to get profile');
  }

  // ================= UPDATE PROFILE =================

  Future<UserModel> updateProfile({
    required String name,
    required String username,
    required String email,
    required String phone,
  }) async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login first');
    }

    final response = await _client.put(
      Uri.parse(ApiEndpoints.updateProfile),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
      body: jsonEncode({
        'full_name': name,
        'username': username,
        'email': email,
        'phone': phone,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return UserModel.fromJson(data['user']);
    }

    throw Exception(data['message'] ?? 'Profile update failed');
  }

  // ================= DELETE ACCOUNT =================

  Future<bool> deleteAccount() async {
    final token = await _tokenStorage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception('Please login first');
    }

    final response = await _client.delete(
      Uri.parse(ApiEndpoints.deleteAccount),
      headers: {..._headers, 'Authorization': 'Bearer $token'},
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      await _tokenStorage.deleteToken();

      return true;
    }

    throw Exception(data['message'] ?? 'Account deletion failed');
  }

  // ================= LOGOUT =================

  Future<void> logout() async {
    await _tokenStorage.deleteToken();
  }
}

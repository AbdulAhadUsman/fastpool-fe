import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthContext {
  static const _boxName = 'authBox';
  static const _tokenKey = 'auth_token';
  static const _expiryKey = 'auth_token_expiry';
  static String get _baseUrl => dotenv.env['BASE_URL'] ?? 'https://127.0.0.1';

  // Initialize Hive (call this once at app startup)
  static Future<void> init() async {
    await Hive.openBox(_boxName);
  }

  static Box get _box => Hive.box(_boxName);

  static Future<void> saveToken(String token) async {
    final expiryTime = DateTime.now().add(Duration(days: 9)).toIso8601String();
    await _box.put(_tokenKey, token);
    await _box.put(_expiryKey, expiryTime);
  }

  static String? getToken() {
    final expiryTimeStr = _box.get(_expiryKey);
    if (expiryTimeStr != null) {
      final expiryTime = DateTime.parse(expiryTimeStr);
      if (DateTime.now().isAfter(expiryTime)) {
        removeToken(); // Token expired, remove it
        return null;
      }
    }
    return _box.get(_tokenKey);
  }

  static Future<void> removeToken() async {
    await _box.delete(_tokenKey);
    await _box.delete(_expiryKey);
  }

  static bool isLoggedIn() {
    return getToken() != null;
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/login/'),
        body: {'email': email, 'password': password},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        await saveToken(data['access_token']);
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> register({
    required String email,
    required String password,
    required String username,
    required String phoneNumber,
    required String gender,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/register/'),
        body: {
          'email': email,
          'password': password,
          'username': username,
          'phone': phoneNumber,
          'gender': gender,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        final errorMessage = errorData['error'] ?? 'Unknown error';
        throw Exception('Registration failed: $errorMessage');
      }
    } catch (e) {
      print('An error occurred during registration: $e');
      throw Exception('An error occurred during registration: $e');
    }
  }

  static Future<bool> verify({
    required String username,
    required String email,
    required String gender,
    required String phone,
    required String password,
    required String otp,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/users/verify/'),
        body: {
          'username': username,
          'email': email,
          'gender': gender,
          'phone': phone,
          'password': password,
          'otp': otp,
        },
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = json.decode(response.body);
        print('Verification failed: ${errorData['error'] ?? 'Unknown error'}');
        return false;
      }
    } catch (e) {
      print('An error occurred during verification: $e');
      return false;
    }
  }
}
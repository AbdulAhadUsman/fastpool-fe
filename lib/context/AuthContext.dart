import 'package:fastpool_fe/pages/loading.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fastpool_fe/pages/driverHome.dart';
import 'package:fastpool_fe/pages/riderHome.dart';
import 'package:fastpool_fe/pages/roleSelection.dart';
import 'package:path_provider/path_provider.dart';

class AuthContext {
  static const _boxName = 'authBox';
  static const _tokenKey = 'auth_token';
  static const _expiryKey = 'auth_token_expiry';
  static const _roleKey = 'user_role';
  static const _vehicleInfoKey = 'vehicle_info';
  static const _usernameKey = 'username';
  static const _emailKey = 'email';
  static const _phoneKey = 'phone';
  static const _genderKey = 'gender';
  static const _ratingsKey = 'ratings';


  static const _baseUrlKey = 'http://192.168.172.254:8000';

  static const _baseUrlKey = 'http://192.168.43.254:8000';

  static String get _baseUrl =>
      dotenv.env['BASE_URL'] ?? 'http://192.168.43.254:8000';

  // Initialize Hive (call this once at app startup)
  static Future<void> init() async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      final dir = await getApplicationDocumentsDirectory();
      Hive.init(dir.path);
      await Hive.openBox(_boxName);
    } catch (e) {
      print('Error initializing Hive: $e');
      // Fallback to temporary directory if needed
      final tempDir = await getTemporaryDirectory();
      Hive.init(tempDir.path);
      await Hive.openBox(_boxName);
    }
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
    await _box.delete(_roleKey);
    await _box.delete(_vehicleInfoKey);
    await _box.delete(_usernameKey);
    await _box.delete(_emailKey);
    await _box.delete(_phoneKey);
    await _box.delete(_genderKey);
    await _box.delete(_ratingsKey);
  }

  static bool isLoggedIn() {
    return getToken() != null;
  }

  static Future<void> setRole(String role) async {
    await _box.put(_roleKey, role);
  }

  static String? getRole() {
    return _box.get(_roleKey);
  }

  static Future<void> cacheVehicleInfo(
      List<Map<String, dynamic>> vehicleInfo) async {
    await _box.put(_vehicleInfoKey, json.encode(vehicleInfo));
  }

  static List<Map<String, dynamic>>? getCachedVehicleInfo() {
    final vehicleInfoJson = _box.get(_vehicleInfoKey);
    if (vehicleInfoJson != null) {
      return List<Map<String, dynamic>>.from(json.decode(vehicleInfoJson));
    }
    return null;
  }

  static Future<void> navigateUserBasedOnRole(BuildContext context) async {
    final role = getRole();
    final token = getToken();

    if (role != null && token != null) {
      try {
        final response = await http.get(
          Uri.parse('$_baseUrlKey/users/profile/?role=$role'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final username = data['username'];
          final email = data['email'];
          final gender = data['gender'];
          final phone = data['phone'];
          final profilePicUrl = data['profile_picture_url'];
          final ratings = data['ratings'];
          final numberOfRatings = data['no_of_ratings'];
          final vehicleInfo = List<Map<String, dynamic>>.from(data[
              'vehicles']); // Assuming 'vehicles' contains the list of vehicle info

          // Save data to local storage
          await _box.put(_usernameKey, username);
          await _box.put(_emailKey, email);
          await _box.put(_genderKey, gender);
          await _box.put(_phoneKey, phone);
          await _box.put(_ratingsKey, ratings);

          // Cache vehicle info including IDs
          if (vehicleInfo.isNotEmpty) {
            await cacheVehicleInfo(vehicleInfo);
          }

          print('User Profile:');
          print('Username: $username');
          print('Email: $email');
          print('Gender: $gender');
          print('Phone: $phone');
          print('Profile Picture URL: $profilePicUrl');
          print('Rating: $ratings');
          print('Number of Ratings: $numberOfRatings');
          print('Vehicle Info: $vehicleInfo');
        } else {
          print('Failed to fetch user profile: ${response.statusCode}');
        }
      } catch (e) {
        print('An error occurred while fetching user profile: $e');
      }
    }

    if (role == 'driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => DriverHomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => RiderHomePage()),
      );
    }
  }

  static Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrlKey/users/login/'),
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
    print('in the register function');
    try {
      print('in the try block of register function');
      print(email);
      print(_baseUrlKey);
      final response = await http.post(
        Uri.parse('$_baseUrlKey/users/signup/'),
        body: {
          'email': email,
          'password': password,
          'username': username,
          'phone': phoneNumber,
          'gender': gender,
        },
      );

      if (response.statusCode == 200) {
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
      print(username);
      print(email);
      print(gender);
      print(phone);
      print(password);
      print(otp);

      final response = await http.post(
        Uri.parse('$_baseUrlKey/users/verify/'),
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

  static String? getUsername() {
    return _box.get(_usernameKey);
  }

  static String? getEmail() {
    return _box.get(_emailKey);
  }

  static String? getPhone() {
    return _box.get(_phoneKey);
  }

  static String? getGender() {
    return _box.get(_genderKey);
  }

  static double? getRatings() {
    return _box.get(_ratingsKey);
  }

  static Future<void> setUsername(String username) async {
    await _box.put(_usernameKey, username);
  }

  static Future<void> setPhone(String phone) async {
    await _box.put(_phoneKey, phone);
  }

  static Future<void> logout(BuildContext context) async {
    await removeToken();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const Login()),
      (route) => false, // Prevent navigating back
    );
  }
}

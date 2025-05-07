import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/models/search_response.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:fastpool_fe/context/AuthContext.dart';

class ApiClient {
  final String backendUrl;

  ApiClient({
    this.backendUrl =
        'http://10.0.2.2:8000', // Default URL for Android emulator
  });

  Map<String, String> get _headers {
    final token = AuthContext.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  Future<Map<String, dynamic>> fetchRiderHomepage() async {
    final response = await http.get(
      Uri.parse('$backendUrl/riders/homepage'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load homepage data: ${response.statusCode}');
    }
  }

  Future<SearchResponse> searchRides({
    LatLng? currentLocation,
    String? cursor,
    Map<String, dynamic>? filters,
  }) async {
    // Convert all values to strings for query parameters
    final Map<String, String> queryParams = {
      'role': 'rider',
      if (currentLocation != null) ...{
        'source_lat': currentLocation.latitude.toString(),
        'source_lng': currentLocation.longitude.toString(),
      },
      if (cursor != null) 'cursor': cursor,
      // Convert filter values to strings
      if (filters != null)
        ...filters.map((key, value) => MapEntry(key, value.toString())),
    };

    final uri = Uri.parse(
      '$backendUrl/rides/search/',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      return SearchResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to search rides: ${response.statusCode}');
    }
  }

  Future<List<Map<String, dynamic>>> fetchRiderRequests() async {
    final response = await http.get(
      Uri.parse('$backendUrl/rides/requests/?role=rider'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final List<dynamic> requests = data['results'] ?? [];
      return List<Map<String, dynamic>>.from(requests);
    } else {
      throw Exception('Failed to fetch requests: ${response.statusCode}');
    }
  }

  Future<void> cancelRideRequest(int requestId) async {
    final response = await http.delete(
      Uri.parse('$backendUrl/rides/requests/$requestId/?role=rider'),
      headers: _headers,
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      throw Exception('Failed to cancel request: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchRiderHistory({String? cursor}) async {
    final queryParams = <String, String>{
      if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
    };

    final uri = Uri.parse(
      '$backendUrl/riders/history/',
    ).replace(queryParameters: queryParams);

    final response = await http.get(uri, headers: _headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print('History Response: $data'); // Debug log
      return data;
    } else {
      throw Exception('Failed to fetch ride history: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createRideRequest({
    required int rideId,
    required double pickupLat,
    required double pickupLng,
    required String pickupTime,
  }) async {
    final response = await http.post(
      Uri.parse('$backendUrl/rides/requests/'),
      headers: _headers,
      body: jsonEncode({
        'ride': rideId,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'pickup_time': pickupTime,
      }),
    );

    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to create ride request: ${response.statusCode}');
    }
  }
}

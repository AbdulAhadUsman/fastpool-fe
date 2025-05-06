import 'package:fastpool_fe/constants/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String googleMapsApiKey = GoogleMapsApiKey;

Future<String> getAddressFromLatLng(double lat, double lng) async {
  print(googleMapsApiKey);
  print(lat);
  print(lng);
  final url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapsApiKey';

  print('before try');
  try {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'OK' && data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      } else {
        return 'Unknown location';
      }
    } else {
      return 'Error: ${response.statusCode}';
    }
  } catch (e) {
    return 'Error: $e';
  }
}

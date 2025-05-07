import 'package:fastpool_fe/constants/api.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

final String googleMapsApiKey = GoogleMapsApiKey;

Future<String> getAddressFromLatLng(double lat, double lng) async {


  final url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$googleMapsApiKey';


  try {
    final response = await http
        .get(
          Uri.parse(
            'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GoogleMapsApiKey',
          ),
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            return http.Response('{"status": "TIMEOUT"}', 408);
          },
        );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK' &&
          data['results'] != null &&
          data['results'].isNotEmpty) {
        return data['results'][0]['formatted_address'];
      }
    }

    return 'Unknown';
  } catch (e) {
    print('Error in reverse geocoding: $e');
    return 'Unknown';
  }
}

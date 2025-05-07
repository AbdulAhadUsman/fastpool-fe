import 'package:fastpool_fe/helper-functions/reverseGeoLoc.dart';

class PastTrip {
  final int id;
  final double sourceLat;
  final double sourceLng;
  final double destinationLat;
  final double destinationLng;
  final DateTime dateTime;
  String? sourceAddress;
  String? destinationAddress;
  bool isLoadingAddresses = true;

  PastTrip({
    required this.id,
    required this.sourceLat,
    required this.sourceLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.dateTime,
  });

  factory PastTrip.fromJson(Map<String, dynamic> json) {
    return PastTrip(
      id: json['id'],
      sourceLat: json['source_lat'].toDouble(),
      sourceLng: json['source_lng'].toDouble(),
      destinationLat: json['destination_lat'].toDouble(),
      destinationLng: json['destination_lng'].toDouble(),
      dateTime: DateTime.parse('${json['date']} ${json['time']}'),
    );
  }

  Future<void> loadAddresses() async {
    isLoadingAddresses = true;
    sourceAddress = await getAddressFromLatLng(sourceLat, sourceLng);
    destinationAddress = await getAddressFromLatLng(
      destinationLat,
      destinationLng,
    );
    isLoadingAddresses = false;
  }
}

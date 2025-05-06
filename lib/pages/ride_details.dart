import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../components/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RideDetailsPage extends StatefulWidget {
  final Ride ride;

  const RideDetailsPage({
    super.key,
    required this.ride,
  });

  @override
  State<RideDetailsPage> createState() => _RideDetailsPageState();
}

class _RideDetailsPageState extends State<RideDetailsPage> {
  String? sourceAddress;
  String? destinationAddress;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isMapLoading = true;

  @override
  void initState() {
    super.initState();
    _getAddresses();
    _initializeMapData();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  Future<void> _getAddresses() async {
    sourceAddress = await _getAddressFromCoordinates(
      widget.ride.sourceLat,
      widget.ride.sourceLng,
    );
    destinationAddress = await _getAddressFromCoordinates(
      widget.ride.destinationLat,
      widget.ride.destinationLng,
    );
    if (mounted) {
      setState(() {});
    }
  }

  Future<String> _getAddressFromCoordinates(double lat, double lng) async {
    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$GoogleMapsApiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          return data['results'][0]['formatted_address'];
        }
      }
      return '$lat, $lng';
    } catch (e) {
      return '$lat, $lng';
    }
  }

  Future<void> _initializeMapData() async {
    try {
      // Create markers for source and destination
      markers.add(
        Marker(
          markerId: const MarkerId('source'),
          position: LatLng(widget.ride.sourceLat, widget.ride.sourceLng),
          infoWindow: const InfoWindow(title: 'Pickup Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        ),
      );

      markers.add(
        Marker(
          markerId: const MarkerId('destination'),
          position:
              LatLng(widget.ride.destinationLat, widget.ride.destinationLng),
          infoWindow: const InfoWindow(title: 'Destination'),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        ),
      );

      // Get route polyline
      await _getRoutePolyline();

      if (mounted) {
        setState(() {
          isMapLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isMapLoading = false;
        });
      }
      debugPrint('Error initializing map data: $e');
    }
  }

  Future<void> _getRoutePolyline() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${widget.ride.sourceLat},${widget.ride.sourceLng}'
          '&destination=${widget.ride.destinationLat},${widget.ride.destinationLng}'
          '&key=$GoogleMapsApiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
          String points = data['routes'][0]['overview_polyline']['points'];
          List<LatLng> polylineCoordinates = _decodePolyline(points);

          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: AppColors.primaryBlue,
              points: polylineCoordinates,
              width: 3,
            ),
          );
        }
      }
    } catch (e) {
      // Handle error silently
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return poly;
  }

  String _formatTime(String time) {
    // Parse the 24-hour time string
    final timeParts = time.split(':');
    if (timeParts.length < 2) return time;

    int hour = int.tryParse(timeParts[0]) ?? 0;
    int minute = int.tryParse(timeParts[1]) ?? 0;

    String period = 'AM';
    if (hour >= 12) {
      period = 'PM';
      if (hour > 12) hour -= 12;
    }
    if (hour == 0) hour = 12;

    return '$hour:${minute.toString().padLeft(2, '0')} $period';
  }

  String _formatDate(String date) {
    try {
      final DateTime dateTime = DateTime.parse(date);
      final List<String> months = [
        'January',
        'February',
        'March',
        'April',
        'May',
        'June',
        'July',
        'August',
        'September',
        'October',
        'November',
        'December'
      ];
      return '${dateTime.day} ${months[dateTime.month - 1]}, ${dateTime.year}';
    } catch (e) {
      return date;
    }
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: content,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Ride Details',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Section
            _buildSection(
              'Driver Information',
              Column(
                children: [
                  Row(
                    children: [
                      _buildProfileImage(widget.ride.driver.profilePic),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.ride.driver.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.ride.driver.driverRating.toString(),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Email', widget.ride.driver.email),
                  _buildInfoRow('Phone', widget.ride.driver.phone),
                  _buildInfoRow('Gender', widget.ride.driver.gender),
                ],
              ),
            ),

            // Vehicle Section
            _buildSection(
              'Vehicle Information',
              Column(
                children: [
                  _buildInfoRow('Name', widget.ride.vehicle.name),
                  _buildInfoRow(
                      'Registration', widget.ride.vehicle.registrationNumber),
                  _buildInfoRow('Type', widget.ride.vehicle.type),
                  _buildInfoRow('AC', widget.ride.vehicle.hasAC ? 'Yes' : 'No'),
                  _buildInfoRow('Capacity', '${widget.ride.vehicle.capacity}'),
                ],
              ),
            ),

            // Route Map Section
            _buildSection(
              'Route',
              Container(
                height: 200,
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: isMapLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryBlue,
                        ),
                      )
                    : Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(
                                (widget.ride.sourceLat +
                                        widget.ride.destinationLat) /
                                    2,
                                (widget.ride.sourceLng +
                                        widget.ride.destinationLng) /
                                    2,
                              ),
                              zoom: 11,
                            ),
                            markers: markers,
                            polylines: polylines,
                            onMapCreated: (GoogleMapController controller) {
                              mapController = controller;
                              // Set map style to dark mode
                              controller.setMapStyle('''
                                [
                                  {
                                    "elementType": "geometry",
                                    "stylers": [
                                      {
                                        "color": "#242f3e"
                                      }
                                    ]
                                  },
                                  {
                                    "elementType": "labels.text.fill",
                                    "stylers": [
                                      {
                                        "color": "#746855"
                                      }
                                    ]
                                  },
                                  {
                                    "elementType": "labels.text.stroke",
                                    "stylers": [
                                      {
                                        "color": "#242f3e"
                                      }
                                    ]
                                  },
                                  {
                                    "featureType": "water",
                                    "elementType": "geometry",
                                    "stylers": [
                                      {
                                        "color": "#17263c"
                                      }
                                    ]
                                  }
                                ]
                              ''');
                            },
                            zoomControlsEnabled: false,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: false,
                            compassEnabled: false,
                            tiltGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                          ),
                          Positioned(
                            right: 8,
                            bottom: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    AppColors.backgroundColor.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: const Text(
                                'Tap to interact',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontFamily: 'Poppins',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            // Ride Details Section
            _buildSection(
              'Ride Details',
              Column(
                children: [
                  _buildInfoRow('Pickup', sourceAddress ?? 'Loading...'),
                  _buildInfoRow(
                      'Destination', destinationAddress ?? 'Loading...'),
                  _buildInfoRow('Time', _formatTime(widget.ride.time)),
                  _buildInfoRow('Date', _formatDate(widget.ride.date)),
                  _buildInfoRow(
                      'Available Seats', '${widget.ride.availableSeats}'),
                  _buildInfoRow('Amount', 'Rs ${widget.ride.amount}'),
                  _buildInfoRow(
                      'Preferred Gender', widget.ride.preferredGender),
                  _buildInfoRow('Payment', widget.ride.paymentOption),
                  if (widget.ride.description != null)
                    _buildInfoRow('Description', widget.ride.description!),
                ],
              ),
            ),

            // Book Ride Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement booking functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Ride',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../components/colors.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';

class RouteMapView extends StatefulWidget {
  final LatLng pickupLocation;
  final LatLng destinationLocation;
  final String pickupAddress;
  final String destinationAddress;
  // New optional parameter for request's pickup location
  final LatLng? requestPickupLocation;
  final String? requestPickupAddress;

  const RouteMapView({
    super.key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupAddress,
    required this.destinationAddress,
    this.requestPickupLocation,
    this.requestPickupAddress,
  });

  @override
  State<RouteMapView> createState() => _RouteMapViewState();
}

class _RouteMapViewState extends State<RouteMapView> {
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // Add markers for pickup and destination
    markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: widget.pickupLocation,
        infoWindow: InfoWindow(title: 'Pickup', snippet: widget.pickupAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
    );

    markers.add(
      Marker(
        markerId: const MarkerId('destination'),
        position: widget.destinationLocation,
        infoWindow: InfoWindow(
            title: 'Destination', snippet: widget.destinationAddress),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );

    // Add request pickup marker if provided
    if (widget.requestPickupLocation != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('request_pickup'),
          position: widget.requestPickupLocation!,
          infoWindow: InfoWindow(
            title: 'Request Pickup',
            snippet: widget.requestPickupAddress ?? 'Your pickup location',
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    // Get route between points
    await _getRoute();

    setState(() {
      isLoading = false;
    });
  }

  Future<void> _getRoute() async {
    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/directions/json'
          '?origin=${widget.pickupLocation.latitude},${widget.pickupLocation.longitude}'
          '&destination=${widget.destinationLocation.latitude},${widget.destinationLocation.longitude}'
          '&key=$GoogleMapsApiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        // Decode polyline points
        final points =
            _decodePolyline(data['routes'][0]['overview_polyline']['points']);

        setState(() {
          polylines.add(
            Polyline(
              polylineId: const PolylineId('route'),
              color: AppColors.primaryBlue,
              points: points,
              width: 4,
            ),
          );
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1E5, lng / 1E5));
    }
    return points;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Route Map',
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
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(
                (widget.pickupLocation.latitude +
                        widget.destinationLocation.latitude) /
                    2,
                (widget.pickupLocation.longitude +
                        widget.destinationLocation.longitude) /
                    2,
              ),
              zoom: 12,
            ),
            markers: markers,
            polylines: polylines,
            onMapCreated: (GoogleMapController controller) {
              mapController = controller;
              controller.setMapStyle('''[
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
              ]''');

              // Calculate bounds to include all markers
              double minLat = widget.pickupLocation.latitude;
              double maxLat = widget.pickupLocation.latitude;
              double minLng = widget.pickupLocation.longitude;
              double maxLng = widget.pickupLocation.longitude;

              void updateBounds(LatLng point) {
                minLat = minLat < point.latitude ? minLat : point.latitude;
                maxLat = maxLat > point.latitude ? maxLat : point.latitude;
                minLng = minLng < point.longitude ? minLng : point.longitude;
                maxLng = maxLng > point.longitude ? maxLng : point.longitude;
              }

              updateBounds(widget.destinationLocation);
              if (widget.requestPickupLocation != null) {
                updateBounds(widget.requestPickupLocation!);
              }

              final bounds = LatLngBounds(
                southwest: LatLng(minLat, minLng),
                northeast: LatLng(maxLat, maxLng),
              );

              controller
                  .animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
          ),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            ),
        ],
      ),
    );
  }
}

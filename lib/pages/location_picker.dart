import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../constants/api.dart';
import '../components/colors.dart';

class PlacePrediction {
  final String placeId;
  final String mainText;
  final String secondaryText;
  final String fullText;

  PlacePrediction({
    required this.placeId,
    required this.mainText,
    required this.secondaryText,
  }) : fullText =
            mainText + (secondaryText.isNotEmpty ? ', $secondaryText' : '');

  factory PlacePrediction.fromJson(Map<String, dynamic> json) {
    final structured = json['structured_formatting'];
    return PlacePrediction(
      placeId: json['place_id'],
      mainText: structured['main_text'],
      secondaryText: structured['secondary_text'] ?? '',
    );
  }
}

// FAST NUCES Lahore constants
const fastNucesLocation = LatLng(31.4820, 74.3029);
const fastNucesAddress = 'FAST NUCES, Block B1 Faisal Town, Lahore';

class LocationPickerPage extends StatefulWidget {
  final String title;
  final LatLng? initialLocation;
  final bool isFastSelectionAllowed;

  const LocationPickerPage({
    super.key,
    required this.title,
    this.initialLocation,
    this.isFastSelectionAllowed = false,
  });

  @override
  State<LocationPickerPage> createState() => _LocationPickerPageState();
}

class _LocationPickerPageState extends State<LocationPickerPage> {
  GoogleMapController? mapController;
  LatLng? selectedLocation;
  String? selectedAddress;
  bool isLoading = false;
  List<PlacePrediction> predictions = [];
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation ??
        const LatLng(31.5204, 74.3587); // Default to Lahore center

    // Add FAST NUCES marker
    markers.add(
      Marker(
        markerId: const MarkerId('fast_nuces'),
        position: fastNucesLocation,
        infoWindow: const InfoWindow(title: 'FAST NUCES Lahore'),
      ),
    );
  }

  Future<void> _getAddressFromCoordinates(LatLng location) async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=$GoogleMapsApiKey'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['status'] == 'OK' && data['results'].isNotEmpty) {
          setState(() {
            selectedAddress = data['results'][0]['formatted_address'];
            searchController.text = selectedAddress!;
            isLoading = false;
          });
          return;
        }
      }
      setState(() {
        selectedAddress = '${location.latitude}, ${location.longitude}';
        searchController.text = selectedAddress!;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        selectedAddress = '${location.latitude}, ${location.longitude}';
        searchController.text = selectedAddress!;
        isLoading = false;
      });
    }
  }

  Future<void> _getPlacePredictions(String input) async {
    if (input.isEmpty) {
      setState(() => predictions = []);
      return;
    }

    // Add FAST NUCES as the first suggestion if input matches
    if ('fast'.contains(input.toLowerCase()) ||
        'nuces'.contains(input.toLowerCase()) ||
        'university'.contains(input.toLowerCase())) {
      setState(() {
        predictions = [
          PlacePrediction(
            placeId: 'fast_nuces_lahore',
            mainText: 'FAST NUCES',
            secondaryText: 'Block B1 Faisal Town, Lahore',
          ),
        ];
      });
      return;
    }

    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=$input'
          '&key=$GoogleMapsApiKey'
          '&components=country:pk'
          '&location=31.5204,74.3587'
          '&radius=30000'
          '&strictbounds=true'
          '&types=establishment|geocode'
          '&language=en'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        setState(() {
          predictions = (data['predictions'] as List)
              .map((p) => PlacePrediction.fromJson(p))
              .toList();
        });
      }
    }
  }

  Future<void> _selectPlace(String placeId, String displayAddress) async {
    if (placeId == 'fast_nuces_lahore') {
      setState(() {
        selectedLocation = fastNucesLocation;
        selectedAddress = fastNucesAddress;
        searchController.text = selectedAddress!;
        predictions = [];
        isSearching = false;
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(fastNucesLocation, 16),
      );
      return;
    }

    final response = await http.get(
      Uri.parse('https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId'
          '&key=$GoogleMapsApiKey'
          '&fields=geometry'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['status'] == 'OK') {
        final location = data['result']['geometry']['location'];
        final newLocation = LatLng(location['lat'], location['lng']);

        setState(() {
          selectedLocation = newLocation;
          selectedAddress = displayAddress;
          searchController.text = displayAddress;
          predictions = [];
          isSearching = false;
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(newLocation, 16),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: Text(
          widget.title,
          style: const TextStyle(
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
              target: selectedLocation!,
              zoom: 15,
            ),
            markers: markers,
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
            },
            onCameraMove: (CameraPosition position) {
              selectedLocation = position.target;
            },
            onCameraIdle: () {
              if (selectedLocation != null && !isSearching) {
                _getAddressFromCoordinates(selectedLocation!);
              }
            },
            zoomControlsEnabled: false,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
          ),
          // Search bar at the top
          SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white),
                              onPressed: () => Navigator.pop(context),
                            ),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search location',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                ),
                                onChanged: (value) {
                                  setState(() => isSearching = true);
                                  _getPlacePredictions(value);
                                },
                              ),
                            ),
                            if (searchController.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.white),
                                onPressed: () {
                                  searchController.clear();
                                  setState(() {
                                    predictions = [];
                                    isSearching = false;
                                  });
                                },
                              ),
                          ],
                        ),
                        if (predictions.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(
                              maxHeight:
                                  MediaQuery.of(context).size.height * 0.4,
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: predictions.length,
                              itemBuilder: (context, index) {
                                final prediction = predictions[index];
                                return ListTile(
                                  title: Text(
                                    prediction.mainText,
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                  subtitle: Text(
                                    prediction.secondaryText,
                                    style: TextStyle(color: Colors.grey[400]),
                                  ),
                                  onTap: () => _selectPlace(
                                      prediction.placeId, prediction.fullText),
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Center marker
          if (predictions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: Icon(
                  Icons.location_on,
                  size: 50,
                  color: AppColors.primaryBlue.withOpacity(0.9),
                ),
              ),
            ),
          // Bottom panel with location info and confirm button
          if (predictions.isEmpty)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.backgroundColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(8.0),
                          child: CircularProgressIndicator(
                            color: AppColors.primaryBlue,
                          ),
                        ),
                      )
                    else if (selectedAddress != null)
                      Text(
                        selectedAddress!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selectedLocation == null || isLoading
                          ? null
                          : () {
                              Navigator.pop(
                                context,
                                {
                                  'location': selectedLocation,
                                  'address': selectedAddress,
                                },
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Confirm Location',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

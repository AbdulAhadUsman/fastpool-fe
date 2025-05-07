import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:fastpool_fe/pages/selectVehicle.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker.dart';
import 'route_map_view.dart';

// FAST NUCES Lahore constants
const fastNucesLocation = LatLng(31.4820, 74.3029);
const fastNucesAddress = 'FAST NUCES, Block B1 Faisal Town, Lahore';

// Keywords to identify FAST NUCES location
const fastKeywords = ['fast nuces', 'faisal town'];

class SelectRoute extends StatefulWidget {
  const SelectRoute({super.key});

  @override
  State<SelectRoute> createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute> {
  LatLng? pickupLocation;
  String? pickupAddress;
  LatLng? destinationLocation;
  String? destinationAddress;

  bool isFastNucesLocation(String? address) {
    if (address == null) return false;
    final lowerAddress = address.toLowerCase();
    return fastKeywords
        .any((keyword) => lowerAddress.contains(keyword.toLowerCase()));
  }

  Future<void> _handleLocationSelection(bool isPickup) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          title: isPickup ? 'Select Pickup Location' : 'Select Destination',
          initialLocation: isPickup ? pickupLocation : destinationLocation,
        ),
      ),
    );

    if (result != null) {
      final newLocation = result['location'] as LatLng;
      final newAddress = result['address'] as String;
      final isFastNuces = isFastNucesLocation(newAddress);

      setState(() {
        if (isPickup) {
          // If pickup is being set to FAST NUCES
          if (isFastNuces) {
            // If destination is also FAST NUCES, show error
            if (isFastNucesLocation(destinationAddress)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Both locations cannot be FAST NUCES'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          }
          pickupLocation = newLocation;
          pickupAddress = newAddress;
        } else {
          // If destination is being set to FAST NUCES
          if (isFastNuces) {
            // If pickup is also FAST NUCES, show error
            if (isFastNucesLocation(pickupAddress)) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Both locations cannot be FAST NUCES'),
                  backgroundColor: Colors.red,
                ),
              );
              return;
            }
          }
          destinationLocation = newLocation;
          destinationAddress = newAddress;
        }

        // If neither location is FAST NUCES, set the other one to FAST NUCES
        if (!isFastNucesLocation(pickupAddress) &&
            !isFastNucesLocation(destinationAddress)) {
          if (isPickup) {
            destinationLocation = fastNucesLocation;
            destinationAddress = fastNucesAddress;
          } else {
            pickupLocation = fastNucesLocation;
            pickupAddress = fastNucesAddress;
          }
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Route",
          style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const Divider(
            color: Colors.white24,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              readOnly: true,
              onTap: () => _handleLocationSelection(true),
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Poppins"),
              controller: TextEditingController(text: pickupAddress),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: "Pickup",
                labelStyle: const TextStyle(
                    color: Colors.white70, fontFamily: "Poppins"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              readOnly: true,
              onTap: () => _handleLocationSelection(false),
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Poppins"),
              controller: TextEditingController(text: destinationAddress),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: "Destination",
                labelStyle: const TextStyle(
                    color: Colors.white70, fontFamily: "Poppins"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          if (pickupLocation != null && destinationLocation != null) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RouteMapView(
                          pickupLocation: pickupLocation!,
                          destinationLocation: destinationLocation!,
                          pickupAddress: pickupAddress!,
                          destinationAddress: destinationAddress!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.map, color: Colors.white),
                  label: const Text(
                    'View on Map',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ],
          const Spacer(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: pickupLocation != null && destinationLocation != null
                  ? () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectVehicle(),
                          settings: RouteSettings(
                            arguments: {
                              'source_lat': pickupLocation!.latitude,
                              'source_lng': pickupLocation!.longitude,
                              'destination_lat': destinationLocation!.latitude,
                              'destination_lng': destinationLocation!.longitude,
                              'source_address': pickupAddress,
                              'destination_address': destinationAddress,
                            },
                          ),
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontFamily: "Poppins"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProgressBar(initialStep: 0),
    );
  }
}

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:fastpool_fe/pages/selectVehicle.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/DriverNavBar.dart';

class SelectRoute extends StatefulWidget {
  const SelectRoute({super.key});

  @override
  State<SelectRoute> createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute> {
  int _currentStep = 1; // Change this value to update progress (0-2)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Route",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const Divider(
            color: Colors.white24, // Divider color
            thickness: 1, // Divider thickness
            height: 1, // Space occupied by the divider
          ),
          const SizedBox(height: 20), // Add top padding
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style: const TextStyle(color: Colors.white), // Match text color
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850], // Match fill color
                labelText: "Starting Point",
                labelStyle:
                    const TextStyle(color: Colors.white70), // Label color
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
              style: const TextStyle(color: Colors.white), // Match text color
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850], // Match fill color
                labelText: "Destination",
                labelStyle:
                    const TextStyle(color: Colors.white70), // Label color
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectVehicle(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Next",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProgressBar(initialStep: 0),
    );
  }
}

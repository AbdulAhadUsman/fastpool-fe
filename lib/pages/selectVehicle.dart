import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:fastpool_fe/pages/rideFinalization.dart';
import 'package:flutter/material.dart';

class SelectVehicle extends StatefulWidget {
  const SelectVehicle({super.key});

  @override
  State<SelectVehicle> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehicle> {
  int? _selectedVehicleIndex;

  final List<Map<String, String>> _vehicles = [
    {
      'name': 'Honda City',
      'type': 'Car',
      'regNumber': 'ABC-123',
      'capacity': '4',
      'ac': 'Yes',
      'image': 'honda_city.png', // You can add image paths here
    },
    {
      'name': 'Suzuki Alto',
      'type': 'Car',
      'regNumber': 'XYZ-123',
      'capacity': '4',
      'ac': 'Yes',
      'image': 'suzuki_alto.png',
    },
    {
      'name': 'Honda Cd-70',
      'type': 'Bike',
      'regNumber': 'DEF-123',
      'capacity': '2',
      'ac': 'No',
      'image': 'honda_cd70.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Vehicle",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: ProgressBar(initialStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Colors.white24, // Divider color
              thickness: 1, // Divider thickness
              height: 1, // Space occupied by the divider
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _vehicles.length,
                itemBuilder: (context, index) {
                  final vehicle = _vehicles[index];
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedVehicleIndex = index;
                      });
                      // You can add additional logic here when a vehicle is selected
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: _selectedVehicleIndex == index
                                ? [
                                    Colors.blue.withOpacity(0.3),
                                    Colors.blue.withOpacity(0.1)
                                  ]
                                : [
                                    const Color(0xFF3A3A3A),
                                    const Color(0xFF1F1F1F)
                                  ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: _selectedVehicleIndex == index
                                ? Colors.blue
                                : Colors.grey.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                vehicle['name']!,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildVehicleDetailRow('Type', vehicle['type']!),
                              _buildVehicleDetailRow(
                                  'Reg #', vehicle['regNumber']!),
                              _buildVehicleDetailRow(
                                  'Capacity', vehicle['capacity']!),
                              _buildVehicleDetailRow('A.C', vehicle['ac']!),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            if (_selectedVehicleIndex != null)
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.8, // Make the button less wide
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RideFinalization(),
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
                      'Next', // Changed text to "Next"
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(value),
        ],
      ),
    );
  }
}

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:fastpool_fe/context/authContext.dart';
import 'package:fastpool_fe/pages/rideFinalization.dart';
import 'package:flutter/material.dart';

class SelectVehicle extends StatefulWidget {
  const SelectVehicle({super.key});

  @override
  State<SelectVehicle> createState() => _SelectVehicleState();
}

class _SelectVehicleState extends State<SelectVehicle> {
  int? _selectedVehicleIndex;
  List<Map<String, dynamic>> _vehicles = [];
  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _routeInfo;

  @override
  void initState() {
    super.initState();
    _fetchVehicles();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _routeInfo =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
  }

  void _fetchVehicles() {
    try {
      final cachedVehicles = AuthContext.getCachedVehicleInfo();
      setState(() {
        _vehicles = cachedVehicles ?? [];
        _isLoading = false;
        if (_vehicles.isEmpty) {
          _error = 'No vehicles found. Please add a vehicle first.';
        }
      });
    } catch (e) {
      setState(() {
        _error = 'Error loading vehicles: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Vehicle",
          style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: ProgressBar(initialStep: 1),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryBlue,
                ),
              )
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: "Poppins",
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Go Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Poppins",
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        height: 1,
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
                              },
                              child: Card(
                                margin: const EdgeInsets.only(bottom: 16),
                                elevation: 8,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1C1C1E),
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          vehicle['name']!,
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD1D1D6),
                                            fontFamily: "Poppins",
                                          ),
                                        ),
                                        const Divider(
                                          color: Colors.white24,
                                          thickness: 1,
                                          height: 16,
                                        ),
                                        _buildVehicleDetailRow(
                                            'Type', vehicle['type']!),
                                        const SizedBox(height: 8),
                                        _buildVehicleDetailRow('Reg #',
                                            vehicle['registration_number']!),
                                        const SizedBox(height: 8),
                                        _buildVehicleDetailRow('Capacity',
                                            vehicle['capacity']!.toString()),
                                        const SizedBox(height: 8),
                                        _buildVehicleDetailRow('A.C',
                                            vehicle['AC']! ? 'Yes' : 'No'),
                                        const Divider(
                                          color: Colors.white24,
                                          thickness: 1,
                                          height: 16,
                                        ),
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
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: ElevatedButton(
                              onPressed: () {
                                if (_routeInfo == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('Route information is missing'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => RideFinalization(),
                                    settings: RouteSettings(
                                      arguments: {
                                        'id': _vehicles[_selectedVehicleIndex!]
                                            ['id'],
                                        'capacity':
                                            _vehicles[_selectedVehicleIndex!]
                                                ['capacity'],
                                        'source_lat': _routeInfo!['source_lat'],
                                        'source_lng': _routeInfo!['source_lng'],
                                        'destination_lat':
                                            _routeInfo!['destination_lat'],
                                        'destination_lng':
                                            _routeInfo!['destination_lng'],
                                        'source_address':
                                            _routeInfo!['source_address'],
                                        'destination_address':
                                            _routeInfo!['destination_address'],
                                      },
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text(
                                'Next',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontFamily: "Poppins"),
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
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Poppins",
                  color: AppColors.textColor),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontFamily: "Poppins", color: AppColors.textColor),
            ),
          ),
        ],
      ),
    );
  }
}

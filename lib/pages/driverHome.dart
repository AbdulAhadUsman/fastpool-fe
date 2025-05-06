import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/helper-functions/reverseGeoLoc.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  String driverName = 'Loading...';
  String email = 'Loading...';
  String gender = 'Loading...';
  String phone = 'Loading...';

  final String profilePicUrl = 'assets/images/Login.png';
  int activeRides = 0;
  double myRating = 0.0;

  String? source = 'Loading...';
  String? destination = 'Loading...';
  String time = 'Loading...';
  String preferredGender = 'Loading...';
  int amount = 0;
  String paymentOption = 'Loading...';
  String vehicleType = 'Loading...';
  String registrationNumber = 'Loading...';
  int availableSeats = 0;
  String acStatus = 'Loading...';

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    final token = AuthContext.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('BASE_URL is not defined in the .env file.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/drivers/homepage/'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final upcomingRide = data['upcoming_ride'];

        if (upcomingRide != null) {
          source = await getAddressFromLatLng(
            upcomingRide['source_lat'],
            upcomingRide['source_lng'],
          );
          destination = await getAddressFromLatLng(
            upcomingRide['destination_lat'],
            upcomingRide['destination_lng'],
          );
        }

        setState(() {
          driverName = AuthContext.getUsername() ?? 'Unknown';
          activeRides = data['active_rides'] ?? 0;
          myRating = AuthContext.getRatings() ?? 0.0;

          if (upcomingRide != null) {
            time = upcomingRide['time'] ?? 'Unknown';
            preferredGender = upcomingRide['preferred_gender'] ?? 'Unknown';
            amount = upcomingRide['amount'] ?? 0;
            paymentOption = upcomingRide['payment_option'] ?? 'Unknown';
            vehicleType = upcomingRide['vehicle']?['type'] ?? 'Unknown';
            registrationNumber =
                upcomingRide['vehicle']?['registration_number'] ?? 'Unknown';
            availableSeats = upcomingRide['available_seats'] ?? 0;
            acStatus = upcomingRide['vehicle']?["AC"] ?? true ? 'Yes' : 'No';
          } else {
            source = null;
            destination = null;
          }
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to fetch data: ${response.statusCode}')),
        );
      }
    } catch (e) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(content: Text('An error occurred: $e')),
      // );
      print('An error occurred: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: _fetchData, // Refresh on pull-down
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Header
                        Card(
                          color: const Color(0xFF1E1E1E),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: AssetImage(profilePicUrl),
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Welcome $driverName',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Stats Section
                        const Text(
                          'Stats',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                icon: Icons.directions_car,
                                title: 'Active Rides',
                                value: '$activeRides',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: StatCard(
                                icon: Icons.star,
                                title: 'My Rating',
                                value: '$myRating',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Upcoming Ride Section
                        const Text(
                          'Upcoming Ride',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 12),
                        source == null || destination == null
                            ? const Center(
                                child: Text(
                                  'No upcoming rides',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              )
                            : UpcomingRideCard(
                                source: source ?? 'Unknown',
                                destination: destination ?? 'Unknown',
                                time: time,
                                preferredGender: preferredGender,
                                amount: amount.toString(),
                                paymentOption: paymentOption,
                                vehicleType: vehicleType,
                                registrationNumber: registrationNumber,
                                availableSeats: availableSeats,
                                acStatus: acStatus,
                              ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
      // Bottom Navigation Bar
      bottomNavigationBar: DriverNavbar(
        initialIndex: 0,
      ),
    );
  }
}

class StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const StatCard({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins'),
            ),
          ],
        ),
      ),
    );
  }
}

class UpcomingRideCard extends StatelessWidget {
  final String source;
  final String destination;
  final String time;
  final String preferredGender;
  final String amount;
  final String paymentOption;
  final String vehicleType;
  final String registrationNumber;
  final int availableSeats;
  final String acStatus;

  const UpcomingRideCard({
    super.key,
    required this.source,
    required this.destination,
    required this.time,
    required this.preferredGender,
    required this.amount,
    required this.paymentOption,
    required this.vehicleType,
    required this.registrationNumber,
    required this.availableSeats,
    required this.acStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            RideInfoRow(label: 'Source', value: source),
            RideInfoRow(label: 'Destination', value: destination),
            RideInfoRow(label: 'Time', value: time),
            RideInfoRow(label: 'Preferred Gender', value: preferredGender),
            RideInfoRow(label: 'Amount', value: amount),
            RideInfoRow(label: 'Payment Option', value: paymentOption),
            RideInfoRow(label: 'Vehicle Type', value: vehicleType),
            RideInfoRow(label: 'Reg #', value: registrationNumber),
            RideInfoRow(label: 'Available Seats', value: '$availableSeats'),
            RideInfoRow(label: 'A.C', value: acStatus),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor: Colors.blueAccent,
                ),
                child: const Text(
                  'Show Requests',
                  style: TextStyle(
                      fontSize: 16, color: Colors.white, fontFamily: 'Poppins'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class RideInfoRow extends StatelessWidget {
  final String label;
  final String value;

  const RideInfoRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 7,
            child: Text(
              value,
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, fontFamily: 'Poppins'),
              overflow: TextOverflow.visible, // Allow text to wrap
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}

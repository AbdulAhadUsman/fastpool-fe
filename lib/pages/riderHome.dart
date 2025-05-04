import 'package:fastpool_fe/components/RiderNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/helper-functions/reverseGeoLoc.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
// import 'package:lucide_icons/lucide_icons.dart'; // Optional if you want matching icons

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage>
    with AutomaticKeepAliveClientMixin {
  final String profilePicUrl = 'assets/images/Login.png';
  final String driverName = 'Shariq Munir';
  final String backendUrl = 'http://10.0.2.2:8000'; // <-- changeable URL
  final String accessToken = access_token;

  int? pendingRequestsCount;
  Map<String, dynamic>? upcomingRide;
  double? rating;
  bool isLoading = true;
  String? errorMessage;

  // Cache for homepage data
  Map<String, dynamic>? cachedData;

  @override
  void initState() {
    super.initState();
    if (cachedData == null) {
      fetchHomepageData();
    } else {
      setState(() {
        isLoading = false;
        pendingRequestsCount = cachedData?['Results']['pending_requests_count'];
        rating = (cachedData?['Results']['rating'] as num).toDouble();
        upcomingRide = cachedData?['Results']['upcoming_ride'];
      });
    }
  }

  @override
  bool get wantKeepAlive => true; // This makes sure the page state is preserved

  Future<void> fetchHomepageData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.get(
        Uri.parse('$backendUrl/riders/homepage'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final ride = data['Results']['upcoming_ride'];

        String? sourceAddress;
        String? destinationAddress;

        if (ride != null) {
          sourceAddress = await getAddressFromLatLng(
            ride['source_lat'],
            ride['source_lng'],
          );
          destinationAddress = await getAddressFromLatLng(
            ride['destination_lat'],
            ride['destination_lng'],
          );

          ride['source_address'] = sourceAddress;
          ride['destination_address'] = destinationAddress;
        }

        setState(() {
          pendingRequestsCount = data['Results']['pending_requests_count'];
          rating = (data['Results']['rating'] as num).toDouble();
          upcomingRide = ride;
          isLoading = false;

          // Cache the data after fetching
          cachedData = data;
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load data: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // This is important for AutomaticKeepAliveClientMixin

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Text(errorMessage!,
                        style: const TextStyle(color: Colors.red)))
                : buildContent(),
      ),
      bottomNavigationBar: RiderNavbar(initialIndex: 0),
    );
  }

  Widget buildContent() {
    return RefreshIndicator(
      onRefresh: fetchHomepageData,
      color: AppColors.primaryBlue,
      backgroundColor: AppColors.backgroundColor,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
              const SizedBox(height: 20),
              const Text(
                'Stats',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.directions_car,
                      title: 'Pending Requests',
                      value: pendingRequestsCount?.toString() ?? '-',
                    ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: StatCard(
                      icon: Icons.star,
                      title: 'My Rating',
                      value: rating?.toStringAsFixed(1) ?? '-',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              const Text(
                'Upcoming Ride',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              if (upcomingRide != null) ...[
                UpcomingRideCard(
                  source: upcomingRide!['source_address'] ?? 'Unknown',
                  destination:
                      upcomingRide!['destination_address'] ?? 'Unknown',
                  time: upcomingRide!['time'],
                  date: upcomingRide!['date'],
                  preferredGender: upcomingRide!['preferred_gender'],
                  amount: upcomingRide!['amount'].toString(),
                  paymentOption: upcomingRide!['payment_option'],
                  vehicleType: upcomingRide!['vehicle_type'],
                  registrationNumber: upcomingRide!['vehicle_reg#'],
                  availableSeats: upcomingRide!['available_seats'],
                  acStatus: upcomingRide!['ac'] ? 'Yes' : 'No',
                ),
              ] else ...[
                const Text(
                  'You have no upcoming ride.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontFamily: 'Poppins',
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
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
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 14, fontFamily: 'Poppins'),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 26,
                  fontWeight: FontWeight.w700),
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
  final String date;
  final String acStatus;

  const UpcomingRideCard(
      {super.key,
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
      required this.date});

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
            RideInfoRow(label: 'Date', value: date),
            RideInfoRow(label: 'Preferred Gender', value: preferredGender),
            RideInfoRow(label: 'Amount', value: amount),
            RideInfoRow(label: 'Payment Option', value: paymentOption),
            RideInfoRow(label: 'Vehicle Type', value: vehicleType),
            RideInfoRow(label: 'Reg #', value: registrationNumber),
            RideInfoRow(label: 'Available Seats', value: '$availableSeats'),
            RideInfoRow(label: 'A.C', value: acStatus),
          ],
        ),
      ),
    );
  }
}

class RideSummaryCard extends StatelessWidget {
  final String pickup;
  final String dateTime;
  final String fare;

  const RideSummaryCard({
    super.key,
    required this.pickup,
    required this.dateTime,
    required this.fare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side: Icons and text
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      pickup,
                      style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.calendar_today,
                        color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Text(
                      dateTime,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Right side: Fare
            Text(
              'Rs $fare',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontFamily: 'Poppins',
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start, // Align top for multi-line
        children: [
          SizedBox(
            width: 130, // Fixed width for label
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              softWrap: true,
              overflow: TextOverflow.visible,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
            ),
          ),
        ],
      ),
    );
  }
}

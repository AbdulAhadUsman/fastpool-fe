import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart'; // Optional if you want matching icons

class RiderHomePage extends StatefulWidget {
  const RiderHomePage({super.key});

  @override
  State<RiderHomePage> createState() => _RiderHomePageState();
}

class _RiderHomePageState extends State<RiderHomePage> {
  final String driverName = 'Shariq Munir';
  final String profilePicUrl = 'assets/images/Login.png';
  final int last30DaysRides = 3;
  final double myRating = 4.8;

  final String source = 'DHA Phase 7';
  final String destination = 'Fast NUCES Lahore';
  final String time = '8:30 AM';
  final String preferredGender = 'Male';
  final String amount = '150';
  final String paymentOption = 'Cash';
  final String vehicleType = 'Car';
  final String registrationNumber = 'ABC-123';
  final int availableSeats = 4;
  final String acStatus = 'Yes';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                const SizedBox(height: 20),

                // Stats Section
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
                        value: '$last30DaysRides',
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: StatCard(
                        icon: Icons.star,
                        title: 'My Rating',
                        value: '$myRating',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),

                // Upcoming Ride Section
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
                UpcomingRideCard(
                  source: source,
                  destination: destination,
                  time: time,
                  preferredGender: preferredGender,
                  amount: amount,
                  paymentOption: paymentOption,
                  vehicleType: vehicleType,
                  registrationNumber: registrationNumber,
                  availableSeats: availableSeats,
                  acStatus: acStatus,
                ),
                const SizedBox(height: 15),

                const Text(
                  'Pending Requests',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 5),
                RideSummaryCard(
                  pickup: 'Askari 11',
                  dateTime: 'Friday, 8:30',
                  fare: '100',
                )
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: RiderNavbar(
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
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: const TextStyle(
                color: Colors.white, fontFamily: 'Poppins', fontSize: 14),
          ),
        ],
      ),
    );
  }
}

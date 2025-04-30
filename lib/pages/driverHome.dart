import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';
// import 'package:lucide_icons/lucide_icons.dart'; // Optional if you want matching icons

class DriverHomePage extends StatefulWidget {
  const DriverHomePage({super.key});

  @override
  State<DriverHomePage> createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  final String driverName = 'Shariq';
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
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        icon: Icons.directions_car,
                        title: 'Last 30 Days',
                        value: '$last30DaysRides',
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
                  ),
                ),
                const SizedBox(height: 12),
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
              ],
            ),
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: DriverNavbar(
        initial_index: 0,
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
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                  color: Colors.blueAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
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
                  'See Pending Requests',
                  style: TextStyle(fontSize: 16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(color: Colors.white, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

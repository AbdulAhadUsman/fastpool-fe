import 'package:fastpool_fe/components/RiderNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/helper-functions/reverseGeoLoc.dart';
import 'package:fastpool_fe/services/api_client.dart';
import 'package:fastpool_fe/components/shimmer_widgets.dart';
import 'package:fastpool_fe/pages/route_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/material.dart';
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
  final ApiClient _apiClient = ApiClient();

  int? pendingRequestsCount;
  Map<String, dynamic>? upcomingRide;
  double? rating;
  bool isLoading = true;
  bool isLoadingAddresses = false;
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

  Future<void> fetchAddresses(Map<String, dynamic> ride) async {
    setState(() {
      isLoadingAddresses = true;
    });

    try {
      final sourceAddress = await getAddressFromLatLng(
        ride['source_lat'],
        ride['source_lng'],
      );
      final destinationAddress = await getAddressFromLatLng(
        ride['destination_lat'],
        ride['destination_lng'],
      );

      setState(() {
        ride['source_address'] = sourceAddress;
        ride['destination_address'] = destinationAddress;
        isLoadingAddresses = false;
      });
    } catch (e) {
      setState(() {
        isLoadingAddresses = false;
      });
    }
  }

  Future<void> fetchHomepageData() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final data = await _apiClient.fetchRiderHomepage();
      final ride = data['Results']['upcoming_ride'];

      setState(() {
        pendingRequestsCount = data['Results']['pending_requests_count'];
        rating = (data['Results']['rating'] as num).toDouble();
        upcomingRide = ride;
        isLoading = false;
        cachedData = data;
      });

      // Fetch addresses after setting the initial data
      if (ride != null) {
        fetchAddresses(ride);
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
        child: errorMessage != null
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
              // Welcome Card
              isLoading
                  ? const WelcomeCardShimmer()
                  : Card(
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
                    child: isLoading
                        ? const StatCardShimmer()
                        : StatCard(
                            icon: Icons.directions_car,
                            title: 'Pending Requests',
                            value: pendingRequestsCount?.toString() ?? '-',
                          ),
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: isLoading
                        ? const StatCardShimmer()
                        : StatCard(
                            icon: Icons.star,
                            title: 'My Rating',
                            value: rating?.toStringAsFixed(1) ?? '-',
                          ),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Upcoming Ride',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (!isLoading && upcomingRide != null && !isLoadingAddresses)
                    TextButton(
                      onPressed: () {
                        final ride = upcomingRide!;
                        if (ride['source_lat'] == null ||
                            ride['source_lng'] == null ||
                            ride['destination_lat'] == null ||
                            ride['destination_lng'] == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please wait for the locations to load completely.'),
                              backgroundColor: Colors.red,
                            ),
                          );
                          return;
                        }

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RouteMapView(
                              pickupLocation: LatLng(
                                ride['source_lat'],
                                ride['source_lng'],
                              ),
                              destinationLocation: LatLng(
                                ride['destination_lat'],
                                ride['destination_lng'],
                              ),
                              pickupAddress:
                                  ride['source_address'] ?? 'Unknown',
                              destinationAddress:
                                  ride['destination_address'] ?? 'Unknown',
                            ),
                          ),
                        );
                      },
                      child: const Text(
                        'View in Map',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 5),
              if (isLoading)
                const UpcomingRideShimmer()
              else if (upcomingRide != null)
                UpcomingRideCard(
                  source: isLoadingAddresses
                      ? 'Loading address...'
                      : upcomingRide!['source_address'] ?? 'Unknown',
                  destination: isLoadingAddresses
                      ? 'Loading address...'
                      : upcomingRide!['destination_address'] ?? 'Unknown',
                  time: upcomingRide!['time'],
                  date: upcomingRide!['date'],
                  preferredGender: upcomingRide!['preferred_gender'],
                  amount: upcomingRide!['amount'].toString(),
                  paymentOption: upcomingRide!['payment_option'],
                  vehicleType: upcomingRide!['vehicle_type'],
                  registrationNumber: upcomingRide!['vehicle_reg#'],
                  availableSeats: upcomingRide!['available_seats'],
                  acStatus: upcomingRide!['ac'] ? 'Yes' : 'No',
                  isLoadingAddresses: isLoadingAddresses,
                )
              else
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
  final bool isLoadingAddresses;

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
    required this.date,
    this.isLoadingAddresses = false,
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

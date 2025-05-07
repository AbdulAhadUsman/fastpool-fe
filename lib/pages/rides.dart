import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/helper-functions/reverseGeoLoc.dart';
import 'package:fastpool_fe/pages/rideRequests.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Vehicle {
  final int id;
  final String name;
  final String registrationNumber;
  final String type;
  final int capacity;
  final bool hasAC;

  Vehicle({
    required this.id,
    required this.name,
    required this.registrationNumber,
    required this.type,
    required this.capacity,
    required this.hasAC,
  });
}

class Ride {
  final int id; // Added id attribute
  final String pickup;
  final String destination;
  final int seats;
  final String day;
  final String time;
  final String preferredGender;
  final int amount;
  final String paymentOption;
  final int availableSeats;
  final Vehicle vehicle;

  Ride({
    required this.id, // Added id to constructor
    required this.pickup,
    required this.destination,
    required this.seats,
    required this.day,
    required this.time,
    required this.preferredGender,
    required this.amount,
    required this.paymentOption,
    required this.availableSeats,
    required this.vehicle,
  });
}

class MyRides extends StatefulWidget {
  const MyRides({Key? key}) : super(key: key);

  @override
  State<MyRides> createState() => _MyRidesState();
}

class _MyRidesState extends State<MyRides> {
  bool isLoading = true;
  List<Ride> rides = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() {
      isLoading = true;
    });

    final baseUrl = dotenv.env['BASE_URL'] ?? '';

    try {
      final token = AuthContext.getToken();
      if (token == null) {
        throw Exception("Token not found");
      }

      final response = await http.get(
        Uri.parse('$baseUrl/rides?role=driver'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Ride> preparedRides = [];

        if (data is List) {
          for (var ride in data) {
            final source = await getAddressFromLatLng(
              ride['source_lat'],
              ride['source_lng'],
            );
            final destination = await getAddressFromLatLng(
              ride['destination_lat'],
              ride['destination_lng'],
            );

            final vehicleData = ride['vehicle'];
            final vehicle = Vehicle(
              id: vehicleData['id'],
              name: vehicleData['name'],
              registrationNumber: vehicleData['registration_number'],
              type: vehicleData['type'],
              capacity: vehicleData['capacity'],
              hasAC: vehicleData['AC'],
            );

            preparedRides.add(Ride(
              id: ride['id'], // Added id from database
              pickup: source,
              destination: destination,
              seats: ride['capacity'] - ride['available_seats'],
              day: ride['date'],
              time: ride['time'],
              preferredGender: ride['preferred_gender'],
              amount: ride['amount'],
              paymentOption: ride['payment_option'],
              availableSeats: ride['available_seats'],
              vehicle: vehicle,
            ));
          }
        } else if (data is Map) {
          final List<dynamic> rideList = data['results'] ?? [];
          for (var ride in rideList) {
            final source = await getAddressFromLatLng(
              ride['source_lat'],
              ride['source_lng'],
            );
            final destination = await getAddressFromLatLng(
              ride['destination_lat'],
              ride['destination_lng'],
            );

            final vehicleData = ride['vehicle'];
            final vehicle = Vehicle(
              id: vehicleData['id'],
              name: vehicleData['name'],
              registrationNumber: vehicleData['registration_number'],
              type: vehicleData['type'],
              capacity: vehicleData['capacity'],
              hasAC: vehicleData['AC'],
            );

            preparedRides.add(Ride(
              id: ride['id'], // Added id from database
              pickup: source,
              destination: destination,
              seats: ride['capacity'] - ride['available_seats'],
              day: ride['date'],
              time: ride['time'],
              preferredGender: ride['preferred_gender'],
              amount: ride['amount'],
              paymentOption: ride['payment_option'],
              availableSeats: ride['available_seats'],
              vehicle: vehicle,
            ));
          }
        } else {
          print('Unexpected response format');
        }

        setState(() {
          rides = preparedRides;
        });
      } else {
        print('Failed to fetch rides: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching rides: $e');
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
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Colors.blue),
              )
            : RefreshIndicator(
                onRefresh: fetchData,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 8.0, bottom: 16.0),
                        child: Text(
                          'My Rides',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: rides.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 12.0),
                              child: RideCard(
                                ride: rides[index],
                                isHeader: index == 0,
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
      bottomNavigationBar: DriverNavbar(initialIndex: 1),
    );
  }
}

class RideCard extends StatelessWidget {
  final Ride ride;
  final bool isHeader;

  const RideCard({
    Key? key,
    required this.ride,
    this.isHeader = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Column(
                children: const [
                  Center(
                    child: Text(
                      'Ride Details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  SizedBox(height: 8),
                  Divider(color: Colors.white70),
                ],
              ),
              content: SingleChildScrollView(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RideInfoRow(label: 'Source', value: ride.pickup),
                      RideInfoRow(
                          label: 'Destination', value: ride.destination),
                      RideInfoRow(label: 'Time', value: ride.time),
                      RideInfoRow(
                          label: 'Preferred Gender',
                          value: ride.preferredGender),
                      RideInfoRow(label: 'Amount', value: '${ride.amount}'),
                      RideInfoRow(
                          label: 'Payment Option', value: ride.paymentOption),
                      RideInfoRow(
                          label: 'Vehicle Type', value: ride.vehicle.type),
                      RideInfoRow(
                          label: 'Registration #',
                          value: ride.vehicle.registrationNumber),
                      RideInfoRow(
                          label: 'Available Seats',
                          value: '${ride.availableSeats}'),
                      RideInfoRow(
                          label: 'A.C',
                          value: ride.vehicle.hasAC ? 'Yes' : 'No'),
                    ],
                  ),
                ),
              ),
              actions: [
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (ride.vehicle.id != null) {
                            // Ensure ride.vehicle.id is valid
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    RideRequestsPage(rideId: ride.id),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Invalid ride ID.')),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        child: const Text(
                          'Show Requests',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                            color: Colors.white, fontFamily: 'Poppins'),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: const Color(0xFF282828), // Updated background color
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.circle_outlined,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.pickup,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isHeader ? FontWeight.bold : FontWeight.normal,
                      fontFamily: "Poppins",
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    ride.destination,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight:
                          isHeader ? FontWeight.bold : FontWeight.normal,
                      fontFamily: "Poppins",
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.people_outline, size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '${ride.seats} Riders',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined,
                    size: 18, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  ride.day,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                ride.time,
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                  fontFamily: "Poppins",
                ),
              ),
            ),
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
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start, // Align items at the top
        children: [
          Text(
            '$label:',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontFamily: 'Poppins',
              ),
              softWrap: true, // Allow text to wrap to the next line
            ),
          ),
        ],
      ),
    );
  }
}

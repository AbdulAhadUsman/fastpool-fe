import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/DriverNavBar.dart';

class DriverRideRequests extends StatelessWidget {
  const DriverRideRequests({super.key});

  final List<Map<String, dynamic>> rideRequests = const [
    {
      'name': 'Ali Haider',
      'email': 'l226666@lhr.nu.edu.pk',
      'pickup': 'Askari 11',
      'time': 'Monday, 8:30',
      'rating': 4.4,
      'profileUrl': 'assets/images/Login.png',
      'rideDetails': {
        'Source': 'Askari 11',
        'Destination': 'Destination Placeholder',
        'Time': 'Monday, 8:30',
        'Preferred Gender': 'Gender Placeholder',
        'Amount': 'Amount Placeholder',
        'Payment Option': 'Payment Placeholder',
        'Vehicle Type': 'Vehicle Placeholder',
        'Registration #': 'Reg# Placeholder',
        'Available Seats': 'Seats Placeholder',
        'AC': 'AC Placeholder',
      },
    },
    {
      'name': 'Sara Khan',
      'email': 'sara.k@lhr.nu.edu.pk',
      'pickup': 'DHA Phase 5',
      'time': 'Tuesday, 9:00',
      'rating': 4.7,
      'profileUrl': 'assets/images/Login.png',
      'rideDetails': {
        'Source': 'DHA Phase 5',
        'Destination': 'Destination Placeholder',
        'Time': 'Tuesday, 9:00',
        'Preferred Gender': 'Gender Placeholder',
        'Amount': 'Amount Placeholder',
        'Payment Option': 'Payment Placeholder',
        'Vehicle Type': 'Vehicle Placeholder',
        'Registration #': 'Reg# Placeholder',
        'Available Seats': 'Seats Placeholder',
        'AC': 'AC Placeholder',
      },
    },
    {
      'name': 'Ahmed Raza',
      'email': 'ahmed.r@lhr.nu.edu.pk',
      'pickup': 'Gulberg III',
      'time': 'Wednesday, 8:00',
      'rating': 4.9,
      'profileUrl': 'assets/images/Login.png',
      'rideDetails': {
        'Source': 'Gulberg III',
        'Destination': 'Destination Placeholder',
        'Time': 'Wednesday, 8:00',
        'Preferred Gender': 'Gender Placeholder',
        'Amount': 'Amount Placeholder',
        'Payment Option': 'Payment Placeholder',
        'Vehicle Type': 'Vehicle Placeholder',
        'Registration #': 'Reg# Placeholder',
        'Available Seats': 'Seats Placeholder',
        'AC': 'AC Placeholder',
      },
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Ride Requests',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: rideRequests.map((ride) {
              return Column(
                children: [
                  RideRequestCard(
                    name: ride['name'],
                    email: ride['email'],
                    pickup: ride['pickup'],
                    time: ride['time'],
                    rating: ride['rating'],
                    profileUrl: ride['profileUrl'],
                    rideDetails: ride['rideDetails'],
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          ),
        ),
      ),
      bottomNavigationBar: DriverNavbar(initialIndex: 3),
    );
  }
}

class RideRequestCard extends StatelessWidget {
  final String name;
  final String email;
  final String pickup;
  final String time;
  final double rating;
  final String profileUrl;

  final Map<String, String> rideDetails;

  const RideRequestCard({
    super.key,
    required this.name,
    required this.email,
    required this.pickup,
    required this.time,
    required this.rating,
    required this.profileUrl,
    required this.rideDetails, // Added ride details map
  });

  @override
  Widget build(BuildContext context) {
    Color cardColor = const Color(0xFF2C2C2C);

    return StatefulBuilder(
      builder: (context, setState) {
        return GestureDetector(
          onTap: () {
            setState(() {
              cardColor = Colors.blueGrey; // Change color on click
            });

            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: const Color(0xFF2C2C2C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20), // Rounded corners
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
                      Divider(color: Colors.white70), // Added divider
                    ],
                  ),
                  content: SingleChildScrollView(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(
                            0xFF3A3A3A), // Lighter background for details
                        borderRadius:
                            BorderRadius.circular(16), // Rounded corners
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: rideDetails.entries.map((entry) {
                          return Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('${entry.key}:',
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 16,
                                        fontFamily: 'Poppins',
                                      )),
                                  Flexible(
                                    child: Text(entry.value,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontFamily: 'Poppins',
                                        ),
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  actions: [
                    Column(
                      children: [
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              // Add functionality for pending requests
                              print('See Pending Requests button clicked');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'See Pending Requests',
                              style: TextStyle(
                                  color: Colors.white, fontFamily: 'Poppins'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(
                            color: Colors.white70), // Divider after button
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Add functionality for delete button
                                print('Delete button clicked');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24), // Increased size
                              ),
                              child: const Text(
                                'Delete',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Poppins'),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                // Add functionality for edit button
                                print('Edit button clicked');
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24), // Increased size
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(
                                    color: Colors.white, fontFamily: 'Poppins'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                );
              },
            );
          },
          child: Column(
            children: [
              Card(
                color: const Color(0xFF2C2C2C), // Reverted to original color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundImage: AssetImage(profileUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                fontFamily: 'Poppins',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.email,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    email,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Poppins'),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(pickup,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Poppins')),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time,
                                    color: Colors.white70, size: 16),
                                const SizedBox(width: 6),
                                Text(time,
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 14,
                                        fontFamily: 'Poppins')),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}

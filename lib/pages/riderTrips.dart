import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';
import '../models/past_trip.dart';
import '../components/past_trip_card.dart';

class RiderTripsPage extends StatelessWidget {
  const RiderTripsPage({super.key});

  // Sample data - Replace with actual data from your backend
  static final List<PastTrip> _pastTrips = [
    PastTrip(
      source: 'FAST NUCES, Islamabad',
      destination: 'F-11 Markaz, Islamabad',
      dateTime: DateTime(2024, 3, 15, 14, 30),
      fare: 300,
    ),
    PastTrip(
      source: 'F-11 Markaz, Islamabad',
      destination: 'FAST NUCES, Islamabad',
      dateTime: DateTime(2024, 3, 14, 9, 15),
      fare: 250,
    ),
    PastTrip(
      source: 'FAST NUCES, Islamabad',
      destination: 'G-11 Markaz, Islamabad',
      dateTime: DateTime(2024, 3, 13, 16, 45),
      fare: 400,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151316),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'Ride History',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 1,
                    color: Colors.grey[800],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _pastTrips.isEmpty
                    ? const Center(
                        child: Text(
                          'No trips yet',
                          style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _pastTrips.length,
                        itemBuilder: (context, index) {
                          return PastTripCard(trip: _pastTrips[index]);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 2),
    );
  }
}

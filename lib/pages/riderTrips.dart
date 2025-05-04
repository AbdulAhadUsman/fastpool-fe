import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';

class RiderTripsPage extends StatelessWidget {
  const RiderTripsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151316),
      body: SafeArea(
        child: Center(
          child: Text(
            'Your Trips',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 2),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';

class RiderExplorePage extends StatelessWidget {
  const RiderExplorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151316),
      body: SafeArea(
        child: Center(
          child: Text(
            'Explore Rides',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 1),
    );
  }
}

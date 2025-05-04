import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/colors.dart';

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage(
              'assets/images/background.png'), // Replace with your background image
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor:
            AppColors.backgroundColor, // Semi-transparent background
        body: Center(
          child: Text(
            "FastPool",
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Poppins',
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:fastpool_fe/pages/driverHome.dart';
import 'package:fastpool_fe/pages/riderHome.dart';

class RoleSelection extends StatelessWidget {
  const RoleSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Role",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                // Set the role as driver and navigate to DriverHomePage
                await AuthContext.setRole('driver');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => DriverHomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Driver',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                // Set the role as rider and navigate to RiderHomePage
                await AuthContext.setRole('rider');
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => RiderHomePage()),
                );
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Rider',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

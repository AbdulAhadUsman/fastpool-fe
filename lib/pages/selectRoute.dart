import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:fastpool_fe/pages/selectVehicle.dart';
import 'package:flutter/material.dart';

class SelectRoute extends StatefulWidget {
  const SelectRoute({super.key});

  @override
  State<SelectRoute> createState() => _SelectRouteState();
}

class _SelectRouteState extends State<SelectRoute> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Select Route",
          style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: AppColors.backgroundColor,
      body: Column(
        children: [
          const Divider(
            color: Colors.white24,
            thickness: 1,
            height: 1,
          ),
          const SizedBox(height: 20),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Poppins"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: "Starting Point",
                labelStyle: const TextStyle(
                    color: Colors.white70, fontFamily: "Poppins"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              style:
                  const TextStyle(color: Colors.white, fontFamily: "Poppins"),
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[850],
                labelText: "Destination",
                labelStyle: const TextStyle(
                    color: Colors.white70, fontFamily: "Poppins"),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SelectVehicle(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                "Next",
                style: TextStyle(
                    color: Colors.white, fontSize: 16, fontFamily: "Poppins"),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: ProgressBar(initialStep: 0),
    );
  }
}

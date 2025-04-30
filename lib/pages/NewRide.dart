import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/pages/selectRoute.dart';
import 'package:flutter/material.dart';

class NewRide extends StatefulWidget {
  const NewRide({super.key});

  @override
  State<NewRide> createState() => _NewRideState();
}

class _NewRideState extends State<NewRide> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/UploadRideBackground.png"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding:
                EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.7),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center, // Center vertically

              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width *
                      0.7, // Set button width to 80% of screen width
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SelectRoute(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      "Upload Ride",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: DriverNavbar(initial_index: 2),
      ),
    );
  }
}

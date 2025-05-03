import 'package:flutter/material.dart';
import 'package:fastpool_fe/pages/driverHome.dart';
import 'package:fastpool_fe/pages/newRide.dart';
import 'package:fastpool_fe/pages/driverProfile.dart';
import 'package:fastpool_fe/pages/driverRideRequests.dart';

class DriverNavbar extends StatefulWidget {
  final initial_index;
  const DriverNavbar({super.key, required this.initial_index});

  @override
  State<DriverNavbar> createState() => _DriverNavbarState();
}

class _DriverNavbarState extends State<DriverNavbar> {
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.directions_car),
      label: 'Rides',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.add_circle, size: 30), // Moved "New Ride" here
      label: 'New Ride',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_search), // Moved "Requests" here
      label: 'Requests',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initial_index; // Set current index to initial index
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F1F1F), // Matches the card background gradient
        borderRadius: BorderRadius.circular(30), // Rounded edges
      ),
      child: ClipRRect(
        borderRadius:
            BorderRadius.circular(30), // Ensures content follows rounded edges
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            // Navigation logic
            switch (index) {
              case 0:
                setState(() {
                  _currentIndex = 0; // Reset index to home
                });
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverHomePage()),
                  (route) => false, // Clear the stack for the home page
                );
                break;
              case 1:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverRideRequests()),
                ).then((_) {
                  setState(() {
                    _currentIndex =
                        widget.initial_index; // Reset to initial index
                  });
                });
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const NewRide()),
                ).then((_) {
                  setState(() {
                    _currentIndex =
                        widget.initial_index; // Reset to initial index
                  });
                });
                break;
              case 4:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const DriverRideRequests()),
                ).then((_) {
                  setState(() {
                    _currentIndex =
                        widget.initial_index; // Reset to initial index
                  });
                });
                break;
              default:
                // Handle other cases if needed
                break;
            }
          },
          items: _bottomNavItems,
          selectedItemColor: Colors.blue, // Changed to blue
          unselectedItemColor:
              Colors.white70, // Slightly faded white for unselected items
          backgroundColor: Colors.transparent, // Transparent to match container
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}

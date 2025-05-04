import 'package:flutter/material.dart';
import 'package:fastpool_fe/pages/riderHome.dart';
import 'package:fastpool_fe/pages/riderExplore.dart';
import 'package:fastpool_fe/pages/riderTrips.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/pages/riderProfile.dart';

class RiderNavbar extends StatefulWidget {
  final int initialIndex;
  const RiderNavbar({super.key, required this.initialIndex});

  @override
  State<RiderNavbar> createState() => _RiderNavbarState();
}

class _RiderNavbarState extends State<RiderNavbar> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  Future<void> _navigateTo(int index) async {
    if (_currentIndex == index) return;

    setState(() => _currentIndex = index);

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const RiderHomePage();
        break;
      case 1:
        targetPage = const RiderExplorePage();
        break;
      case 2:
        targetPage = const RiderTripsPage();
        break;
      case 3:
        targetPage = const RiderProfile();
        break;
      default:
        return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => targetPage),
    );

    // After coming back, reset to current page or home
    setState(() {
      _currentIndex = widget.initialIndex; // Or 0 to default back to home
    });
  }

  @override
  Widget build(BuildContext context) {
    const backgroundColor = Color(0xFF282828);

    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 10, bottom: 20),
      // margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _navIcon(icon: Icons.home_rounded, index: 0),
          _navIcon(icon: Icons.explore_rounded, index: 1),
          _navIcon(icon: Icons.directions_car_rounded, index: 2),
          _navIcon(icon: Icons.person_rounded, index: 3),
        ],
      ),
    );
  }

  Widget _navIcon({required IconData icon, required int index}) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () => _navigateTo(index),
      child: isSelected
          ? Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue, // Circular background
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: Colors.white, // Icon inside is white
                size: 26,
              ),
            )
          : Icon(
              icon,
              color: Colors.white54, // Unselected icons
              size: 28,
            ),
    );
  }
}

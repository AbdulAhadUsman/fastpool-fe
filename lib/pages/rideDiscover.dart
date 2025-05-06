import 'package:flutter/material.dart';
import '../components/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/ride_card.dart';
import '../models/ride.dart';

class RideDiscover extends StatefulWidget {
  const RideDiscover({super.key});

  @override
  State<RideDiscover> createState() => _RideDiscoverState();
}

class _RideDiscoverState extends State<RideDiscover>
    with SingleTickerProviderStateMixin {
  late final FocusNode pickupFocusNode;
  late final FocusNode destinationFocusNode;
  late final AnimationController _animationController;
  late final Animation<double> _animation;

  bool isPickupFocused = false;
  bool isDestinationFocused = false;

  // Sample rides data
  final List<Ride> rides = [
    Ride(
      driver: Driver(
        name: 'John Doe',
        rating: 4.8,
        email: 'john.doe@example.com',
        contactNumber: '+92 300 1234567',
        profilePicUrl: 'https://xsgames.co/randomusers/avatar.php?g=male',
      ),
      sourceLat: 0,
      sourceLng: 0,
      destinationLat: 0,
      destinationLng: 0,
      vehicle: Vehicle(
        model: 'Honda City',
        number: 'ABC-123',
        type: 'car',
        hasAC: true,
      ),
      time: DateTime.now().add(const Duration(hours: 1)),
      capacity: 4,
      availableSeats: 4,
      unbookedSeats: 3,
      amount: 100,
      preferredGender: 'Any',
      paymentOption: 'Cash',
      expirationTime: DateTime.now().add(const Duration(hours: 2)),
      date: DateTime.now(),
      riders: [],
      pickup: 'Gulshan-e-Iqbal, Block 13',
      destination: 'Saddar, Empress Market',
      duration: 45,
      distance: 12.5,
    ),
    Ride(
      driver: Driver(
        name: 'Jane Smith',
        rating: 4.9,
        email: 'jane.smith@example.com',
        contactNumber: '+92 300 7654321',
        profilePicUrl: 'https://xsgames.co/randomusers/avatar.php?g=female',
      ),
      sourceLat: 0,
      sourceLng: 0,
      destinationLat: 0,
      destinationLng: 0,
      vehicle: Vehicle(
        model: 'Toyota Corolla',
        number: 'XYZ-789',
        type: 'car',
        hasAC: true,
      ),
      time: DateTime.now().add(const Duration(hours: 2)),
      capacity: 4,
      availableSeats: 4,
      unbookedSeats: 2,
      amount: 150,
      preferredGender: 'Any',
      paymentOption: 'Cash',
      expirationTime: DateTime.now().add(const Duration(hours: 3)),
      date: DateTime.now(),
      riders: [],
      pickup: 'North Nazimabad, Block A',
      destination: 'DHA Phase 6',
      duration: 30,
      distance: 8.7,
    ),
  ];

  @override
  void initState() {
    super.initState();
    pickupFocusNode = FocusNode();
    destinationFocusNode = FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 2.0,
      end: 5.0,
    ).animate(_animationController);

    pickupFocusNode.addListener(() {
      setState(() {
        isPickupFocused = pickupFocusNode.hasFocus;
      });
    });

    destinationFocusNode.addListener(() {
      setState(() {
        isDestinationFocused = destinationFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    pickupFocusNode.dispose();
    destinationFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Widget _buildGlowingShape({
    required bool isSquare,
    required bool isFocused,
  }) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: isSquare ? BoxShape.rectangle : BoxShape.circle,
            color: isFocused ? AppColors.primaryBlue : const Color(0xFFA4A4A4),
            boxShadow: isFocused
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.6),
                      blurRadius: _animation.value * 1.5,
                      spreadRadius: _animation.value * 0.75,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Center(
                child: Text(
                  'Discover Rides',
                  style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 15),
              Column(
                children: [
                  Stack(
                    children: [
                      // Main content container
                      Container(
                        height: 120,
                        margin: const EdgeInsets.only(right: 50),
                        child: Stack(
                          children: [
                            // Vertical line
                            Positioned(
                              left: 4,
                              top: 25,
                              height: 70,
                              child: Container(
                                width: 2,
                                color: const Color(0xFFA4A4A4),
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    _buildGlowingShape(
                                      isSquare: false,
                                      isFocused: isPickupFocused,
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 280,
                                      child: TextField(
                                        focusNode: pickupFocusNode,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Pickup',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFFA4A4A4),
                                            fontFamily: 'Poppins',
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF282828),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    _buildGlowingShape(
                                      isSquare: true,
                                      isFocused: isDestinationFocused,
                                    ),
                                    const SizedBox(width: 20),
                                    SizedBox(
                                      width: 280,
                                      child: TextField(
                                        focusNode: destinationFocusNode,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontFamily: 'Poppins',
                                        ),
                                        decoration: InputDecoration(
                                          hintText: 'Destination',
                                          hintStyle: const TextStyle(
                                            color: Color(0xFFA4A4A4),
                                            fontFamily: 'Poppins',
                                          ),
                                          filled: true,
                                          fillColor: const Color(0xFF282828),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            borderSide: BorderSide.none,
                                          ),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Filter icon
                      Positioned(
                        right: 0,
                        top: 42,
                        child: SvgPicture.asset(
                          'assets/icons/Filter.svg',
                          width: 26,
                          height: 29,
                          colorFilter: const ColorFilter.mode(
                            Color(0xFFA4A4A4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Container(
                    height: 1,
                    color: Colors.grey[800],
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Ride results
              Expanded(
                child: ListView.builder(
                  itemCount: rides.length,
                  itemBuilder: (context, index) {
                    return RideCard(ride: rides[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

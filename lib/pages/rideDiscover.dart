import 'package:flutter/material.dart';
import '../components/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/ride_card.dart';
import '../models/ride.dart';
import '../components/RiderNavBar.dart';
import '../components/ride_filters.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_picker.dart';
import 'route_map_view.dart';

// FAST NUCES Lahore constants
const fastNucesLocation = LatLng(31.4820, 74.3029);
const fastNucesAddress = 'FAST NUCES, Block B1 Faisal Town, Lahore';

// Keywords to identify FAST NUCES location
const fastKeywords = ['fast nuces', 'faisal town'];

class RideDiscover extends StatefulWidget {
  const RideDiscover({super.key});

  @override
  State<RideDiscover> createState() => _RideDiscoverState();
}

class _RideDiscoverState extends State<RideDiscover>
    with TickerProviderStateMixin {
  late final FocusNode pickupFocusNode;
  late final FocusNode destinationFocusNode;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  late final AnimationController _filterAnimationController;
  late final Animation<Offset> _filterSlideAnimation;

  bool isPickupFocused = false;
  bool isDestinationFocused = false;
  bool isFilterVisible = false;
  Map<String, dynamic> currentFilters = {};
  List<ActiveFilter> activeFilters = [];
  GlobalKey filterIconKey = GlobalKey();
  double? filterIconYPosition;

  // Location state
  LatLng? pickupLocation;
  String? pickupAddress;
  LatLng destinationLocation = fastNucesLocation;
  String destinationAddress = fastNucesAddress;

  bool isFastNucesLocation(String? address) {
    if (address == null) return false;
    final lowerAddress = address.toLowerCase();
    return fastKeywords
        .any((keyword) => lowerAddress.contains(keyword.toLowerCase()));
  }

  // Sample rides data
  final List<Ride> rides = [
    Ride(
      id: 1,
      driver: Driver(
        username: 'John Doe',
        email: 'john.doe@example.com',
        gender: 'Male',
        phone: '+92 300 1234567',
        profilePic: 'https://xsgames.co/randomusers/avatar.php?g=male',
        riderRating: 0.0,
        driverRating: 4.8,
      ),
      sourceLat: 24.8880,
      sourceLng: 67.2212,
      destinationLat: 24.9475,
      destinationLng: 67.1007,
      vehicle: Vehicle(
        id: 1,
        driver: 1,
        name: 'Honda City',
        registrationNumber: 'ABC-123',
        type: 'Sedan',
        capacity: 4,
        hasAC: true,
      ),
      time: '08:00:00',
      capacity: 4,
      availableSeats: 3,
      amount: 100,
      preferredGender: 'Any',
      paymentOption: 'Cash',
      expirationTime: '23:59:00',
      date: '2024-03-20',
      description: 'Ride from Gulshan to Saddar. AC: Yes',
      riders: [],
      pickup: 'Gulshan-e-Iqbal, Block 13',
      destination: 'Saddar, Empress Market',
      duration: 45,
      distance: 12.5,
    ),
    Ride(
      id: 2,
      driver: Driver(
        username: 'Jane Smith',
        email: 'jane.smith@example.com',
        gender: 'Female',
        phone: '+92 300 7654321',
        profilePic: 'https://xsgames.co/randomusers/avatar.php?g=female',
        riderRating: 0.0,
        driverRating: 4.9,
      ),
      sourceLat: 24.9283,
      sourceLng: 67.0841,
      destinationLat: 24.8600,
      destinationLng: 67.0011,
      vehicle: Vehicle(
        id: 2,
        driver: 2,
        name: 'Toyota Corolla',
        registrationNumber: 'XYZ-789',
        type: 'Sedan',
        capacity: 4,
        hasAC: true,
      ),
      time: '09:00:00',
      capacity: 4,
      availableSeats: 2,
      amount: 150,
      preferredGender: 'Any',
      paymentOption: 'Cash',
      expirationTime: '23:59:00',
      date: '2024-03-20',
      description: 'Ride from North Nazimabad to DHA. AC: Yes',
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

    _filterAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _filterSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    ));

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

    // Add post-frame callback to get filter icon position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilterIconPosition();
    });
  }

  void _updateFilterIconPosition() {
    final RenderBox? renderBox =
        filterIconKey.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      setState(() {
        filterIconYPosition = position.dy;
      });
    }
  }

  @override
  void dispose() {
    pickupFocusNode.dispose();
    destinationFocusNode.dispose();
    _animationController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFilter() async {
    _updateFilterIconPosition();
    setState(() {
      isFilterVisible = !isFilterVisible;
    });

    if (isFilterVisible) {
      _filterAnimationController.forward();
    } else {
      await _filterAnimationController.reverse();
    }
  }

  void _handleFilters(Map<String, dynamic> filters) {
    setState(() {
      currentFilters = filters;
      _updateActiveFilters();
    });
  }

  void _updateActiveFilters() {
    activeFilters = _getActiveFilterBubbles();
  }

  List<ActiveFilter> _getActiveFilterBubbles() {
    final List<ActiveFilter> filters = [];

    if (currentFilters.isEmpty) return filters;

    if (currentFilters['type'] != null) {
      filters.add(ActiveFilter(type: 'Type', value: currentFilters['type']));
    }

    if (currentFilters['capacityOption'] != null &&
        currentFilters['capacityOption'] != 'Any') {
      final value = currentFilters['customCapacity']?.toString() ??
          currentFilters['capacityOption'];
      filters.add(ActiveFilter(type: 'Capacity', value: value));
    }

    if (currentFilters['acPreference'] != null) {
      filters
          .add(ActiveFilter(type: 'AC', value: currentFilters['acPreference']));
    }

    if (currentFilters['amountFilterType'] != null &&
        currentFilters['amountFilterType'] != 'Any') {
      String value = '';
      switch (currentFilters['amountFilterType']) {
        case 'Range':
          if (currentFilters['minAmount'] != null &&
              currentFilters['maxAmount'] != null) {
            value =
                'Rs. ${currentFilters['minAmount'].toStringAsFixed(0)} - Rs. ${currentFilters['maxAmount'].toStringAsFixed(0)}';
          }
          break;
        case 'At Least':
          if (currentFilters['minAmount'] != null) {
            value = '≥ Rs. ${currentFilters['minAmount'].toStringAsFixed(0)}';
          }
          break;
        case 'At Most':
          if (currentFilters['maxAmount'] != null) {
            value = '≤ Rs. ${currentFilters['maxAmount'].toStringAsFixed(0)}';
          }
          break;
      }
      if (value.isNotEmpty) {
        filters.add(ActiveFilter(type: 'Amount', value: value));
      }
    }

    if (currentFilters['costType'] != null) {
      filters
          .add(ActiveFilter(type: 'Cost', value: currentFilters['costType']));
    }

    if (currentFilters['paymentOption'] != null) {
      filters.add(ActiveFilter(
          type: 'Payment', value: currentFilters['paymentOption']));
    }

    if (currentFilters['date'] != null) {
      final date = currentFilters['date'] as DateTime;
      filters.add(ActiveFilter(
        type: 'Date',
        value: '${date.day}/${date.month}/${date.year}',
      ));
    }

    if (currentFilters['time'] != null) {
      final time = currentFilters['time'] as TimeOfDay;
      final hour = time.hour.toString().padLeft(2, '0');
      final minute = time.minute.toString().padLeft(2, '0');
      filters.add(ActiveFilter(type: 'Time', value: '$hour:$minute'));
    }

    return filters;
  }

  void _removeFilter(String type) {
    setState(() {
      switch (type) {
        case 'Type':
          currentFilters.remove('type');
          break;
        case 'Capacity':
          currentFilters.remove('capacityOption');
          currentFilters.remove('customCapacity');
          break;
        case 'AC':
          currentFilters.remove('acPreference');
          break;
        case 'Amount':
          currentFilters.remove('amountFilterType');
          currentFilters.remove('minAmount');
          currentFilters.remove('maxAmount');
          break;
        case 'Cost':
          currentFilters.remove('costType');
          break;
        case 'Payment':
          currentFilters.remove('paymentOption');
          break;
        case 'Date':
          currentFilters.remove('date');
          break;
        case 'Time':
          currentFilters.remove('time');
          break;
      }
      _updateActiveFilters();
    });
  }

  Future<void> _handleOutsideTap() async {
    if (isFilterVisible) {
      await _toggleFilter();
    }
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

  void _handleLocationSelection(bool isPickup) async {
    if (!isPickup && !isFastNucesLocation(pickupAddress)) {
      // Don't allow changing destination if pickup is not FAST
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Pickup location must be FAST NUCES to change destination'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerPage(
          title: isPickup ? 'Select Pickup Location' : 'Select Destination',
          initialLocation: isPickup ? pickupLocation : destinationLocation,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        if (isPickup) {
          pickupLocation = result['location'] as LatLng;
          pickupAddress = result['address'] as String;

          // If pickup is not FAST, force destination to be FAST
          if (!isFastNucesLocation(pickupAddress)) {
            destinationLocation = fastNucesLocation;
            destinationAddress = fastNucesAddress;
          }
        } else {
          destinationLocation = result['location'] as LatLng;
          destinationAddress = result['address'] as String;
        }
      });
    }
  }

  Widget _buildLocationInputs() {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 120,
              margin: const EdgeInsets.only(right: 50),
              child: Stack(
                children: [
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
                              readOnly: true,
                              onTap: () => _handleLocationSelection(true),
                              controller:
                                  TextEditingController(text: pickupAddress),
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
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
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
                              readOnly: true,
                              onTap: () => _handleLocationSelection(false),
                              controller: TextEditingController(
                                  text: destinationAddress),
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
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
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
              child: GestureDetector(
                onTap: _toggleFilter,
                child: Container(
                  key: filterIconKey,
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
              ),
            ),
          ],
        ),
        if (pickupLocation != null && destinationLocation != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RouteMapView(
                      pickupLocation: pickupLocation!,
                      destinationLocation: destinationLocation,
                      pickupAddress: pickupAddress!,
                      destinationAddress: destinationAddress,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.map, color: Colors.white),
              label: const Text(
                'View on Map',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Poppins',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        children: [
          SafeArea(
            child: GestureDetector(
              onTap: _handleOutsideTap,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Center(
                      child: Text(
                        'Discover Rides',
                        style: TextStyle(
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
                    _buildLocationInputs(),
                    const SizedBox(height: 15),
                    Container(
                      height: 1,
                      color: Colors.grey[800],
                    ),
                    if (activeFilters.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      ActiveFilters(
                        filters: activeFilters,
                        onRemove: _removeFilter,
                      ),
                    ],
                    const SizedBox(height: 20),
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
          ),
          // Filter overlay
          if (isFilterVisible)
            Positioned.fill(
              child: GestureDetector(
                onTap: _handleOutsideTap,
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            ),
          // Filter panel
          if (isFilterVisible && filterIconYPosition != null)
            Positioned(
              right: 20,
              top: filterIconYPosition! - 20,
              child: SlideTransition(
                position: _filterSlideAnimation,
                child: GestureDetector(
                  onTap: () {}, // Prevent taps from reaching the overlay
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.7,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primaryGray,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: RideFilters(
                      onApplyFilters: _handleFilters,
                      initialFilters: currentFilters,
                      onClose: _toggleFilter,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 1),
    );
  }
}

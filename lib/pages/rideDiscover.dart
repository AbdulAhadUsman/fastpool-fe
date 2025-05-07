import 'package:flutter/material.dart';
import '../components/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../components/ride_card.dart';
import '../models/ride.dart';
import '../components/RiderNavBar.dart';
import '../components/ride_filters.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../services/api_client.dart';
import '../helper-functions/reverseGeoLoc.dart';
import '../components/shimmer_widgets.dart';
import 'location_picker.dart';
import 'route_map_view.dart';
import 'dart:math' show min;

// FAST NUCES Lahore constants
const fastNucesLocation = LatLng(37.426573, -122.091052);
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
  final ApiClient _apiClient = ApiClient();

  bool isPickupFocused = false;
  bool isDestinationFocused = false;
  bool isFilterVisible = false;
  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic> currentFilters = {
    'role': 'rider',
  };
  List<ActiveFilter> activeFilters = [];
  GlobalKey filterIconKey = GlobalKey();
  double? filterIconYPosition;
  String? nextCursor;
  bool isLoadingMore = false;

  // Location state
  LatLng? currentLocation;
  LatLng? pickupLocation;
  String? pickupAddress;
  LatLng destinationLocation = fastNucesLocation;
  String destinationAddress = fastNucesAddress;

  // Rides data
  List<Ride> rides = [];
  Map<int, Map<String, String?>> addressCache = {};

  bool isFastNucesLocation(String? address) {
    if (address == null) return false;
    final lowerAddress = address.toLowerCase();
    return fastKeywords
        .any((keyword) => lowerAddress.contains(keyword.toLowerCase()));
  }

  @override
  void initState() {
    super.initState();
    pickupFocusNode = FocusNode();
    destinationFocusNode = FocusNode();

    _setupAnimations();
    _setupFocusListeners();
    _requestLocationPermission();

    // Add post-frame callback to get filter icon position
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateFilterIconPosition();
    });
  }

  void _setupAnimations() {
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
  }

  void _setupFocusListeners() {
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

  Future<void> _requestLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage = 'Location services are disabled.';
        isLoading = false;
      });
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = 'Location permissions are denied.';
          isLoading = false;
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage =
            'Location permissions are permanently denied, we cannot request permissions.';
        isLoading = false;
      });
      return;
    }

    // Get current location
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
      _fetchRides();
    } catch (e) {
      setState(() {
        errorMessage = 'Error getting location: $e';
        isLoading = false;
      });
    }
  }

  Future<void> _fetchRides() async {
    if (isLoadingMore) return;

    setState(() {
      isLoading = nextCursor == null;
      isLoadingMore = nextCursor != null;
      errorMessage = null;
    });

    try {
      final response = await _apiClient.searchRides(
        currentLocation: currentLocation,
        cursor: nextCursor,
        filters: currentFilters,
      );

      final List<Ride> newRides = response.results
          .map((ride) => Ride(
                id: ride.id,
                driver: ride.driver,
                sourceLat: ride.sourceLat,
                sourceLng: ride.sourceLng,
                destinationLat: ride.destinationLat,
                destinationLng: ride.destinationLng,
                vehicle: ride.vehicle,
                time: ride.time,
                capacity: ride.capacity,
                availableSeats: ride.availableSeats,
                amount: ride.amount,
                preferredGender: ride.preferredGender,
                paymentOption: ride.paymentOption,
                expirationTime: ride.expirationTime,
                date: ride.date,
                description: ride.description,
                riders: ride.riders,
                pickup: null,
                destination: null,
                duration: ride.duration,
                distance: ride.distance,
              ))
          .toList();

      setState(() {
        if (nextCursor == null) {
          // First load or refresh
          rides = newRides;
        } else {
          // Loading more
          rides.addAll(newRides);
        }
        nextCursor = response.nextCursor;
        isLoading = false;
        isLoadingMore = false;
      });

      // Load addresses asynchronously
      for (var ride in newRides) {
        _loadAddressesForRide(ride);
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load rides: $e';
        isLoading = false;
        isLoadingMore = false;
      });
    }
  }

  Future<void> _loadAddressesForRide(Ride ride) async {
    if (addressCache[ride.id] != null) return;

    try {
      final sourceAddress = await getAddressFromLatLng(
        ride.sourceLat,
        ride.sourceLng,
      );

      final destinationAddress = await getAddressFromLatLng(
        ride.destinationLat,
        ride.destinationLng,
      );

      setState(() {
        addressCache[ride.id] = {
          'source': sourceAddress,
          'destination': destinationAddress,
        };

        // Update the ride object with the addresses
        final index = rides.indexWhere((r) => r.id == ride.id);
        if (index != -1) {
          rides[index] = Ride(
            id: ride.id,
            driver: ride.driver,
            sourceLat: ride.sourceLat,
            sourceLng: ride.sourceLng,
            destinationLat: ride.destinationLat,
            destinationLng: ride.destinationLng,
            vehicle: ride.vehicle,
            time: ride.time,
            capacity: ride.capacity,
            availableSeats: ride.availableSeats,
            amount: ride.amount,
            preferredGender: ride.preferredGender,
            paymentOption: ride.paymentOption,
            expirationTime: ride.expirationTime,
            date: ride.date,
            description: ride.description,
            riders: ride.riders,
            pickup: sourceAddress,
            destination: destinationAddress,
            duration: ride.duration,
            distance: ride.distance,
          );
        }
      });
    } catch (e) {
      print('Error loading addresses for ride ${ride.id}: $e');
    }
  }

  String? _getAddress(int rideId, String type) {
    return addressCache[rideId]?[type];
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

  bool get isLoadingState => isLoading || isLoadingMore;

  Future<void> _toggleFilter() async {
    if (isLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while rides are being loaded...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

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
      // Merge with the role parameter
      currentFilters = {
        'role': 'rider',
        ...filters,
      };
      // Update active filters list
      activeFilters = _getActiveFilterBubbles();
    });
  }

  List<ActiveFilter> _getActiveFilterBubbles() {
    final List<ActiveFilter> filters = [];

    // Vehicle Type filter
    if (currentFilters['vehicle_type'] != null) {
      filters.add(ActiveFilter(
        type: 'Vehicle',
        value: currentFilters['vehicle_type'],
      ));
    }

    // Minimum Seats filter
    if (currentFilters['min_seats'] != null) {
      filters.add(ActiveFilter(
        type: 'Seats',
        value: '≥ ${currentFilters['min_seats']}',
      ));
    }

    // Gender Preference filter
    if (currentFilters['preferred_gender'] != null) {
      filters.add(ActiveFilter(
        type: 'Gender',
        value: currentFilters['preferred_gender'],
      ));
    }

    // Amount Range filters
    if (currentFilters['min_amount'] != null ||
        currentFilters['max_amount'] != null) {
      String value = '';
      if (currentFilters['min_amount'] != null &&
          currentFilters['max_amount'] != null) {
        value =
            'Rs. ${currentFilters['min_amount']} - ${currentFilters['max_amount']}';
      } else if (currentFilters['min_amount'] != null) {
        value = '≥ Rs. ${currentFilters['min_amount']}';
      } else {
        value = '≤ Rs. ${currentFilters['max_amount']}';
      }
      filters.add(ActiveFilter(type: 'Amount', value: value));
    }

    // Payment Option filter
    if (currentFilters['payment_option'] != null) {
      filters.add(ActiveFilter(
        type: 'Payment',
        value: currentFilters['payment_option'],
      ));
    }

    // Sort filter
    if (currentFilters['ordering'] != null) {
      String sortValue = '';
      switch (currentFilters['ordering']) {
        case '-date':
          sortValue = 'Newest First';
          break;
        case 'date':
          sortValue = 'Oldest First';
          break;
        case 'time':
          sortValue = 'Early to Late';
          break;
        case '-time':
          sortValue = 'Late to Early';
          break;
        case 'amount':
          sortValue = 'Price: Low to High';
          break;
        case '-amount':
          sortValue = 'Price: High to Low';
          break;
      }
      if (sortValue.isNotEmpty) {
        filters.add(ActiveFilter(type: 'Sort', value: sortValue));
      }
    }

    return filters;
  }

  void _removeFilter(String type) {
    if (isLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while rides are being loaded...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      switch (type) {
        case 'Vehicle':
          currentFilters.remove('vehicle_type');
          break;
        case 'Seats':
          currentFilters.remove('min_seats');
          break;
        case 'Gender':
          currentFilters.remove('preferred_gender');
          break;
        case 'Amount':
          currentFilters.remove('min_amount');
          currentFilters.remove('max_amount');
          break;
        case 'Payment':
          currentFilters.remove('payment_option');
          break;
        case 'Sort':
          currentFilters.remove('ordering');
          break;
      }
      activeFilters = _getActiveFilterBubbles();
    });
  }

  void _handleSearch() {
    if (isLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while rides are being loaded...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Update location filters
    setState(() {
      if (pickupLocation != null) {
        currentFilters['source_lat'] = pickupLocation!.latitude;
        currentFilters['source_lng'] = pickupLocation!.longitude;
      }
      if (destinationLocation != null) {
        currentFilters['destination_lat'] = destinationLocation.latitude;
        currentFilters['destination_lng'] = destinationLocation.longitude;
      }
    });

    // Reset cursor and fetch rides with current filters
    nextCursor = null;
    _fetchRides();
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
    if (isLoadingState) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait while rides are being loaded...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!isPickup && !isFastNucesLocation(pickupAddress)) {
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

          if (!isFastNucesLocation(pickupAddress)) {
            destinationLocation = fastNucesLocation;
            destinationAddress = fastNucesAddress;
          }
        } else {
          destinationLocation = result['location'] as LatLng;
          destinationAddress = result['address'] as String;
        }
        // Update active filters to show the new location
        activeFilters = _getActiveFilterBubbles();
      });
    }
  }

  Widget _buildLocationInputs() {
    return Column(
      children: [
        Container(
          height: 120,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left section with shapes and inputs
              Expanded(
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
                    // Input fields and shapes
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pickup row
                        Row(
                          children: [
                            _buildGlowingShape(
                              isSquare: false,
                              isFocused: isPickupFocused,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                focusNode: pickupFocusNode,
                                readOnly: true,
                                enabled: !isLoadingState,
                                onTap: () => _handleLocationSelection(true),
                                controller:
                                    TextEditingController(text: pickupAddress),
                                style: TextStyle(
                                  color: isLoadingState
                                      ? Colors.grey
                                      : Colors.white,
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
                        const SizedBox(height: 15),
                        // Destination row
                        Row(
                          children: [
                            _buildGlowingShape(
                              isSquare: true,
                              isFocused: isDestinationFocused,
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: TextField(
                                focusNode: destinationFocusNode,
                                readOnly: true,
                                enabled: !isLoadingState,
                                onTap: () => _handleLocationSelection(false),
                                controller: TextEditingController(
                                    text: destinationAddress),
                                style: TextStyle(
                                  color: isLoadingState
                                      ? Colors.grey
                                      : Colors.white,
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
              // Right section with icons
              Container(
                width: 50,
                margin: const EdgeInsets.only(left: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Search Icon
                    GestureDetector(
                      onTap: isLoadingState ? null : _handleSearch,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.search,
                          color: isLoadingState
                              ? const Color(0xFF666666)
                              : AppColors.primaryBlue,
                          size: 24,
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    // Filter Icon
                    GestureDetector(
                      onTap: isLoadingState ? null : _toggleFilter,
                      child: Container(
                        key: filterIconKey,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF282828),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: SvgPicture.asset(
                          'assets/icons/Filter.svg',
                          width: 24,
                          height: 24,
                          colorFilter: ColorFilter.mode(
                            isLoadingState
                                ? const Color(0xFF666666)
                                : const Color(0xFFA4A4A4),
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (pickupLocation != null && destinationLocation != null) ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoadingState
                  ? null
                  : () {
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
                disabledBackgroundColor: AppColors.primaryBlue.withOpacity(0.5),
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
                      child: isLoading
                          ? ListView.builder(
                              itemCount:
                                  5, // Show 5 shimmer cards while loading
                              itemBuilder: (context, index) {
                                return const Padding(
                                  padding: EdgeInsets.only(bottom: 10),
                                  child: RideCardShimmer(),
                                );
                              },
                            )
                          : errorMessage != null
                              ? Center(
                                  child: Text(
                                    errorMessage!,
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontFamily: 'Poppins',
                                    ),
                                  ),
                                )
                              : rides.isEmpty
                                  ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 24.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.search_off_rounded,
                                              size: 64,
                                              color: AppColors.primaryBlue
                                                  .withOpacity(0.7),
                                            ),
                                            const SizedBox(height: 16),
                                            const Text(
                                              'No Rides Found',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 24,
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              'We couldn\'t find any rides matching your search criteria. Try adjusting your filters or search for a different route.',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 16,
                                                fontFamily: 'Poppins',
                                              ),
                                            ),
                                            const SizedBox(height: 24),
                                            ElevatedButton.icon(
                                              onPressed: () {
                                                // Reset filters and search
                                                setState(() {
                                                  currentFilters = {
                                                    'role': 'rider',
                                                  };
                                                  activeFilters = [];
                                                  nextCursor = null;
                                                });
                                                _fetchRides();
                                              },
                                              icon: const Icon(
                                                  Icons.refresh_rounded,
                                                  color: Colors.white),
                                              label: const Text(
                                                'Reset Filters',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontFamily: 'Poppins',
                                                  fontSize: 16,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    AppColors.primaryBlue,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 24,
                                                  vertical: 12,
                                                ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : NotificationListener<ScrollNotification>(
                                      onNotification:
                                          (ScrollNotification scrollInfo) {
                                        if (!isLoadingMore &&
                                            nextCursor != null &&
                                            scrollInfo.metrics.pixels ==
                                                scrollInfo
                                                    .metrics.maxScrollExtent) {
                                          _fetchRides();
                                        }
                                        return true;
                                      },
                                      child: RefreshIndicator(
                                        onRefresh: () async {
                                          nextCursor = null;
                                          await _fetchRides();
                                        },
                                        color: AppColors.primaryBlue,
                                        backgroundColor:
                                            AppColors.backgroundColor,
                                        child: ListView.builder(
                                          itemCount: rides.length +
                                              (isLoadingMore
                                                  ? 3
                                                  : 0), // Show 3 shimmer cards while loading more
                                          itemBuilder: (context, index) {
                                            if (index >= rides.length) {
                                              return const Padding(
                                                padding:
                                                    EdgeInsets.only(bottom: 10),
                                                child: RideCardShimmer(),
                                              );
                                            }
                                            return RideCard(ride: rides[index]);
                                          },
                                        ),
                                      ),
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
          // Centered Filter panel
          if (isFilterVisible)
            Positioned.fill(
              child: SlideTransition(
                position: _filterSlideAnimation,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Calculate available space
                        final screenHeight = MediaQuery.of(context).size.height;
                        final screenWidth = MediaQuery.of(context).size.width;
                        final bottomNavHeight = kBottomNavigationBarHeight;
                        final safeAreaTop = MediaQuery.of(context).padding.top;
                        final safeAreaBottom =
                            MediaQuery.of(context).padding.bottom;

                        // Calculate maximum dimensions
                        // Leave 20px padding from all sides and nav bars
                        final maxHeight = screenHeight -
                            safeAreaTop -
                            bottomNavHeight -
                            safeAreaBottom -
                            40;
                        final maxWidth = screenWidth - 40;

                        // Use the smaller of maxHeight or 80% of available height
                        final targetHeight = min(
                            maxHeight,
                            (screenHeight - safeAreaTop - safeAreaBottom) *
                                0.8);
                        final targetWidth =
                            min(maxWidth, 400.0); // Max width of 400

                        return Container(
                          width: targetWidth,
                          height: targetHeight,
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
                        );
                      },
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

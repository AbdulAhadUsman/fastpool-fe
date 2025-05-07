import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';

class RiderExplorePage extends StatefulWidget {
  const RiderExplorePage({super.key});

  @override
  State<RiderExplorePage> createState() => _RiderExplorePageState();
}

class _RiderExplorePageState extends State<RiderExplorePage> {
  // Filter states
  String vehicleType = 'Car';
  int capacity = 4;
  String ac = 'Yes';
  String preferredGender = 'Male'; // Default selected gender
  String paymentOption = '';
  double? minAmount;
  double? maxAmount;

  final TextEditingController pickupController = TextEditingController();
  final TextEditingController destinationController = TextEditingController();
  bool isFilterVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151316),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Discover Rides',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Poppins",
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Search fields
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff252427),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.circle_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: pickupController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Pickup',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff252427),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: destinationController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              hintText: 'Destination',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isFilterVisible = !isFilterVisible;
                            });
                          },
                          child: const Icon(Icons.filter_list,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Ride cards
                  Expanded(
                    child: ListView.builder(
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff252427),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.circle_outlined,
                                                    color: Colors.white,
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Pickup',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "Poppins"),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Row(
                                              children: [
                                                const Icon(
                                                    Icons.location_on_outlined,
                                                    color: Colors.white,
                                                    size: 16),
                                                const SizedBox(width: 8),
                                                const Text(
                                                  'Destination',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontFamily: "Poppins"),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            const Text(
                                              'Rs 100',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Poppins"),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        decoration: BoxDecoration(
                                          color: const Color(0xff3D90E3),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.access_time,
                                                color: Colors.white, size: 16),
                                            const SizedBox(width: 4),
                                            const Text(
                                              'Time',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: "Poppins"),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),

              // Filter overlay
              if (isFilterVisible)
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withOpacity(0.8),
                    child: Center(
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xff252427),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Filters',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: "Poppins"),
                              textAlign: TextAlign.center,
                            ),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 16),

                            // Vehicle Type
                            const Text('Type',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Spacer(),
                                const Text('Car',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins")),
                                const SizedBox(width: 8),
                                Switch(
                                  value: vehicleType == 'Car',
                                  onChanged: (value) {
                                    setState(() {
                                      vehicleType = value ? 'Car' : 'Bike';
                                    });
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                const Text('Bike',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins")),
                                const Spacer(),
                              ],
                            ),

                            // Capacity
                            const SizedBox(height: 16),
                            const Text('Capacity',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    if (capacity > 1) {
                                      setState(() {
                                        capacity--;
                                      });
                                    }
                                  },
                                  icon: const Icon(Icons.remove,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  '$capacity',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontFamily: "Poppins"),
                                ),
                                const SizedBox(width: 16),
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      capacity++;
                                    });
                                  },
                                  icon: const Icon(Icons.add,
                                      color: Colors.white),
                                ),
                              ],
                            ),

                            // AC
                            const SizedBox(height: 16),
                            const Text('AC',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Spacer(),
                                const Text('Yes',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins")),
                                const SizedBox(width: 8),
                                Switch(
                                  value: ac == 'Yes',
                                  onChanged: (value) {
                                    setState(() {
                                      ac = value ? 'Yes' : 'No';
                                    });
                                  },
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.blue,
                                ),
                                const SizedBox(width: 8),
                                const Text('No',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Poppins")),
                                const Spacer(),
                              ],
                            ),

                            // Amount
                            const SizedBox(height: 16),
                            const Text('Amount',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Min',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Poppins"),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('~',
                                    style: TextStyle(color: Colors.white)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text(
                                      'Max',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontFamily: "Poppins"),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Preferred Gender
                            const SizedBox(height: 16),
                            const Text('Preferred Gender',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        preferredGender = 'Male';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: preferredGender == 'Male'
                                            ? const Color(0xff3D90E3)
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: const Color(0xff3D90E3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Male',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        preferredGender = 'Female';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: preferredGender == 'Female'
                                            ? const Color(0xff3D90E3)
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: const Color(0xff3D90E3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Female',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        preferredGender = 'All';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                      decoration: BoxDecoration(
                                        color: preferredGender == 'All'
                                            ? const Color(0xff3D90E3)
                                            : Colors.transparent,
                                        border: Border.all(
                                            color: const Color(0xff3D90E3)),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'All',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            // Payment Option
                            const SizedBox(height: 16),
                            const Text('Payment Option',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Poppins")),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        paymentOption = 'Cash';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Cash',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        paymentOption = 'Online';
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'Online',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),
                            const Divider(color: Colors.grey),
                            const SizedBox(height: 16),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        // Reset filters
                                        vehicleType = 'Car';
                                        capacity = 4;
                                        ac = 'Yes';
                                        preferredGender = 'Male';
                                        paymentOption = '';
                                        minAmount = null;
                                        maxAmount = null;
                                        isFilterVisible = false;
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: Colors.grey[800],
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Text(
                                        'Clear',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        isFilterVisible = false;
                                        // Apply filters here
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff3D90E3),
                                        borderRadius: BorderRadius.circular(24),
                                      ),
                                      child: const Text(
                                        'OK',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontFamily: "Poppins"),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 1),
    );
  }
}

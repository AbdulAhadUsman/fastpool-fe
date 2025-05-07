import 'dart:convert';

import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Vehicle {
  int id; // Add ID field
  String name;
  String type;
  String regNumber;
  int capacity;
  bool hasAC;

  Vehicle({
    required this.id,
    required this.name,
    required this.type,
    required this.regNumber,
    required this.capacity,
    required this.hasAC,
  });
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onDelete;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: const Color(0xFF282828), // Updated card color
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(color: Colors.white24, thickness: 1), // Divider added
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w600,
                      fontFamily: "Poppins"),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () async {
                    final success = await _deleteVehicle(context, vehicle.id);
                    if (success) {
                      onDelete();
                    }
                  },
                ),
              ],
            ),
            const Divider(color: Colors.white24, thickness: 1), // Divider added
            _vehicleRow("Type", vehicle.type),
            const SizedBox(height: 8),
            _vehicleRow("Reg #", vehicle.regNumber),
            const SizedBox(height: 8),
            _vehicleRow("Capacity", vehicle.capacity.toString()),
            const SizedBox(height: 8),
            _vehicleRow("A.C", vehicle.hasAC ? "Yes" : "No"),
            const Divider(color: Colors.white24, thickness: 1), // Divider added
          ],
        ),
      ),
    );
  }

  Future<bool> _deleteVehicle(BuildContext context, int vehicleId) async {
    final token = AuthContext.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      return false;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('BASE_URL is not defined in the .env file.')),
      );
      return false;
    }
    print(token);
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/drivers/vehicles/delete/'),
        body: jsonEncode({'id': vehicleId}),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        // Remove vehicle from cached vehicles
        final cachedVehicles = AuthContext.getCachedVehicleInfo();
        if (cachedVehicles != null) {
          final updatedVehicles =
              cachedVehicles.where((v) => v['id'] != vehicleId).toList();
          await AuthContext.cacheVehicleInfo(updatedVehicles);
        }
        return true;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete vehicle: $error')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      return false;
    }
  }

  Widget _vehicleRow(String label, String value) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins"),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
              color: AppColors.textColor,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins"),
          textAlign: TextAlign.right, // Right-align the data
        ),
      ],
    );
  }

  IconData _getIcon(String label) {
    switch (label) {
      case "Name":
        return Icons.directions_car;
      case "Type":
        return Icons.car_rental;
      case "Reg #":
        return Icons.confirmation_number;
      case "Capacity":
        return Icons.event_seat;
      case "A.C":
        return Icons.ac_unit;
      default:
        return Icons.info;
    }
  }
}

class Driver {
  String username; // Replace firstName and lastName with username
  String password;
  String phone;
  String email;
  String gender;
  String profileImage;
  int rides;
  double rating;
  Vehicle vehicle;

  Driver({
    required this.username,
    required this.password,
    required this.phone,
    required this.email,
    required this.gender,
    required this.profileImage,
    required this.rides,
    required this.rating,
    required this.vehicle,
  });
}

class DriverProfile extends StatefulWidget {
  const DriverProfile({super.key});

  @override
  State<DriverProfile> createState() => _DriverProfileState();
}

class _DriverProfileState extends State<DriverProfile> {
  bool isLoading = true;

  final Driver driver = Driver(
    username: "Shariq Munir", // Update to use username
    password: "********",
    phone: "03123456789",
    email: "l226680@lhr.nu.edu.pk",
    gender: "Male",
    profileImage: "assets/images/Sign-up.png",
    rides: 1900,
    rating: 4.8,
    vehicle: Vehicle(
      id: 1,
      name: "Honda City",
      type: "Car",
      regNumber: "ABC-123",
      capacity: 4,
      hasAC: true,
    ),
  );

  List<Vehicle> vehicleList = [
    Vehicle(
        id: 1,
        name: "Honda City",
        type: "Car",
        regNumber: "ABC-123",
        capacity: 4,
        hasAC: true),
    Vehicle(
        id: 2,
        name: "Suzuki Alto",
        type: "Car",
        regNumber: "XYZ-789",
        capacity: 4,
        hasAC: false),
  ];

  // Text controllers
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isEditing = {};

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Initialize driver

    // Create controllers
    controllers["firstname"] = TextEditingController(text: driver.username);
    controllers["password"] = TextEditingController(text: driver.password);
    controllers["phone"] = TextEditingController(text: driver.phone);
    controllers["email"] = TextEditingController(text: driver.email);
    controllers["gender"] = TextEditingController(text: driver.gender);

    // Initial edit states
    isEditing["name"] = false;
    isEditing["password"] = false;
    isEditing["phone"] = false;
    isEditing["email"] = false;
    isEditing["gender"] = false;
  }

  Future<void> _fetchData() async {
    setState(() {
      isLoading = true;
    });

    // Simulate fetching data from local storage and AuthContext
    final cachedVehicles = AuthContext.getCachedVehicleInfo();
    final username = AuthContext.getUsername();
    final email = AuthContext.getEmail();
    final phone = AuthContext.getPhone();
    final gender = AuthContext.getGender();
    final ratings = AuthContext.getRatings();

    await Future.delayed(const Duration(seconds: 2)); // Simulate delay

    setState(() {
      driver.username = username ?? "Unknown";
      driver.email = email ?? "Unknown";
      driver.phone = phone ?? "Unknown";
      driver.gender = gender ?? "Unknown";
      driver.rating = ratings ?? 0.0;
      vehicleList = cachedVehicles
              ?.map((v) => Vehicle(
                    id: v['id'], // Include ID
                    name: v['name'],
                    type: v['type'],
                    regNumber: v['registration_number'],
                    capacity: v['capacity'],
                    hasAC: v['AC'],
                  ))
              .toList() ??
          [];
      isLoading = false;
    });
  }

  @override
  void dispose() {
    for (var controller in controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void toggleEdit(String field) {
    setState(() {
      isEditing[field] = !(isEditing[field] ?? false);
    });
  }

  void _showEditNameDialog(BuildContext context) {
    final usernameController = TextEditingController(text: driver.username);

    showDialog(
      context: context,
      barrierDismissible: false, // prevents dialog from closing on tap outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Username',
                        style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                        )),
                    const SizedBox(height: 5),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(
                          color: AppColors.textColor, fontFamily: 'Poppins'),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey[850],
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () async {
                          final newUsername = usernameController.text;
                          if (newUsername.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Username cannot be empty.')),
                            );
                            return;
                          }

                          final success =
                              await _updateUsername(context, newUsername);
                          if (success) {
                            setState(() {
                              driver.username = newUsername;
                            });
                            await AuthContext.setUsername(
                                newUsername); // Use setter
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _updateUsername(BuildContext context, String newUsername) async {
    final token = AuthContext.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      return false;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('BASE_URL is not defined in the .env file.')),
      );
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/edit/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'username': newUsername}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update username: $error')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      return false;
    }
  }

  void _showEditPasswordDialog(BuildContext context) {
    final passwordController = TextEditingController(text: "");
    final confirmPasswordController = TextEditingController();
    bool isPasswordVisible = false;
    bool isConfirmPasswordVisible = false;

    showDialog(
      context: context,
      barrierDismissible: false, // prevents dialog from closing on tap outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Password',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: passwordController,
                          obscureText: !isPasswordVisible,
                          style: const TextStyle(
                              color: Colors.grey, fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[850],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  isPasswordVisible = !isPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Confirm Password',
                          style: TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: confirmPasswordController,
                          obscureText: !isConfirmPasswordVisible,
                          style: const TextStyle(
                              color: Colors.white, fontFamily: 'Poppins'),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[850],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.white70,
                              ),
                              onPressed: () {
                                setState(() {
                                  isConfirmPasswordVisible =
                                      !isConfirmPasswordVisible;
                                });
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text(
                              "Cancel",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                            ),
                            onPressed: () {
                              if (passwordController.text ==
                                  confirmPasswordController.text) {
                                setState(() {
                                  driver.password = passwordController.text;
                                });
                                this.setState(() {}); // Refresh the page
                                Navigator.pop(context);
                              } else {
                                // Handle password mismatch (optional)
                              }
                            },
                            child: const Text(
                              "Confirm",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showEditPhoneDialog(BuildContext context) {
    final phoneController = TextEditingController(text: driver.phone);

    showDialog(
      context: context,
      barrierDismissible: false, // prevents dialog from closing on tap outside
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Phone number',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: phoneController,
                            style: const TextStyle(
                                color: Colors.grey, fontFamily: 'Poppins'),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.grey[850],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey,
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueAccent,
                        ),
                        onPressed: () async {
                          final newPhone = phoneController.text;
                          if (newPhone.length != 11) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Phone number must be exactly 11 digits.')),
                            );
                            return;
                          }

                          final success =
                              await _updatePhoneNumber(context, newPhone);
                          if (success) {
                            setState(() {
                              driver.phone = newPhone;
                            });
                            await AuthContext.setPhone(newPhone); // Use setter
                            Navigator.pop(context);
                          }
                        },
                        child: const Text(
                          "Confirm",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future<bool> _updatePhoneNumber(BuildContext context, String newPhone) async {
    final token = AuthContext.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      return false;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('BASE_URL is not defined in the .env file.')),
      );
      return false;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/profile/edit/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'phone': newPhone}),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update phone number: $error')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      return false;
    }
  }

  void _showVehicleInfoDialog(BuildContext context, {int? index}) {
    final nameController = TextEditingController(
        text: index != null ? vehicleList[index].name : "");
    final regController = TextEditingController(
        text: index != null ? vehicleList[index].regNumber : "");
    String selectedType = index != null ? vehicleList[index].type : "Car";
    String selectedAC =
        index != null && vehicleList[index].hasAC ? 'AC' : 'Non-AC';
    int capacity = index != null ? vehicleList[index].capacity : 4;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black.withOpacity(0.8), // Match background
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Vehicles Info',
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(
                            color: Colors.grey,
                            fontFamily:
                                'Poppins'), // Updated inside text to grey
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[850], // Match fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Reg #',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: regController,
                        style: const TextStyle(
                            color: AppColors.textColor,
                            fontFamily: 'Poppins'), // Match text color
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[850], // Match fill color
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Type',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Car',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          const Text(
                            'Car',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'Bike',
                            groupValue: selectedType,
                            onChanged: (value) {
                              setState(() {
                                selectedType = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          const Text(
                            'Bike',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Capacity',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                if (capacity > 1) capacity--;
                              });
                            },
                            icon: const Icon(Icons.remove, color: Colors.white),
                          ),
                          Text(
                            '$capacity',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                capacity++;
                              });
                            },
                            icon: const Icon(Icons.add, color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'AC',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: "Poppins"), // Match text color
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'AC',
                            groupValue: selectedAC,
                            onChanged: (value) {
                              setState(() {
                                selectedAC = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          const Text(
                            'AC',
                            style: TextStyle(color: Colors.white),
                          ),
                          const SizedBox(width: 20),
                          Radio<String>(
                            value: 'Non-AC',
                            groupValue: selectedAC,
                            onChanged: (value) {
                              setState(() {
                                selectedAC = value!;
                              });
                            },
                            activeColor: Colors.white,
                          ),
                          const Text(
                            'Non-AC',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.grey, // Match button color
                              ),
                              onPressed: () => Navigator.pop(context),
                              child: const Text(
                                "Cancel",
                                style: TextStyle(
                                    color:
                                        Colors.white), // Button text is white
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.blue, // Match button color
                              ),
                              onPressed: () async {
                                if (nameController.text.isEmpty ||
                                    regController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Please fill all fields before submitting.')),
                                  );
                                  return;
                                }

                                final success = await _registerVehicle(
                                  context,
                                  nameController.text,
                                  regController.text,
                                  selectedType,
                                  capacity,
                                  selectedAC == 'AC',
                                );

                                if (success) {
                                  Navigator.pop(context);
                                  await _fetchData(); // Add this line to refresh the UI
                                }
                              },
                              child: const Text(
                                "Confirm",
                                style: TextStyle(
                                    color:
                                        Colors.white), // Button text is white
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _registerVehicle(
    BuildContext context,
    String name,
    String regNumber,
    String type,
    int capacity,
    bool hasAC,
  ) async {
    final token = AuthContext.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Authentication token is missing.')),
      );
      return false;
    }

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    if (baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('BASE_URL is not defined in the .env file.')),
      );
      return false;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/drivers/vehicles/register/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': name,
          'registration_number': regNumber,
          'type': type,
          'capacity': capacity,
          'AC': hasAC,
        }),
      );
      print('before if');
      if (response.statusCode == 201) {
        print(response.body.toString());
        print('yahi');
        final resp = json.decode(response.body);
        final newVehicle = resp['data'];
        print(newVehicle);

        // Update the vehicle list in the UI
        print(newVehicle);
        setState(() {
          vehicleList.add(Vehicle(
            id: newVehicle['id'],
            name: newVehicle['name'],
            type: newVehicle['type'],
            regNumber: newVehicle['registration_number'],
            capacity: newVehicle['capacity'],
            hasAC: newVehicle['AC'],
          ));
        });

        // Update the cached vehicles
        final cachedVehicles = AuthContext.getCachedVehicleInfo() ?? [];
        cachedVehicles.add(newVehicle);
        await AuthContext.cacheVehicleInfo(cachedVehicles);

        return true;
      } else {
        final error = json.decode(response.body)['error'] ?? 'Unknown error';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to register vehicle: $error')),
        );
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
      return false;
    }
  }

  void editVehicle(BuildContext context, int index) {
    _showVehicleInfoDialog(context, index: index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blueAccent,
              ),
            )
          : SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  await _fetchData(); // Re-fetch data when pulled down
                },
                child: SingleChildScrollView(
                  physics:
                      const AlwaysScrollableScrollPhysics(), // Ensure pull-to-refresh works
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      // Profile Picture & Stats
                      Column(
                        children: [
                          CircleAvatar(
                            radius: 45,
                            backgroundImage: AssetImage(driver.profileImage),
                          ),
                          const SizedBox(height: 10),
                          Text(driver.username, // Update to use username
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontFamily: "Poppins")),
                          const SizedBox(height: 6),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("${driver.rides} Rides",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontFamily: "Poppins")),
                              const SizedBox(width: 20),
                              const Icon(Icons.star,
                                  color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text("${driver.rating}",
                                  style: const TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontFamily: "Poppins")),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Profile Info Card
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 8,
                          margin: EdgeInsets.zero,
                          child: Container(
                            decoration: const BoxDecoration(
                              color:
                                  Color(0xFF282828), // Updated to solid color
                              borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  // Adjusted spacing to ensure uniformity between all fields
                                  Row(children: [
                                    Icon(
                                      Icons.person,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Username:",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins")),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 45),
                                        child: Text(driver.username,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontFamily: "Poppins")),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () =>
                                            _showEditNameDialog(context),
                                        icon: Icon(Icons.edit,
                                            color: Colors.white38, size: 18)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Icon(
                                      Icons.lock,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Password:",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins")),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 20),
                                        child: Text(driver.password,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontFamily: "Poppins")),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () =>
                                            _showEditPasswordDialog(context),
                                        icon: Icon(Icons.edit,
                                            color: Colors.white38, size: 18)),
                                  ]),
                                  const SizedBox(height: 12),
                                  Row(children: [
                                    Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Phone:",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins")),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 41),
                                        child: Text(driver.phone,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontFamily: "Poppins")),
                                      ),
                                    ),
                                    IconButton(
                                        onPressed: () =>
                                            _showEditPhoneDialog(context),
                                        icon: Icon(Icons.edit,
                                            color: Colors.white38, size: 18)),
                                  ]),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.mail,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(width: 12),
                                      Text("Email:",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: "Poppins")),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 47),
                                          child: Text(driver.email,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                  fontFamily: "Poppins")),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Row(children: [
                                    Icon(
                                      driver.gender.toLowerCase() == "male"
                                          ? Icons.male
                                          : Icons.female,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 12),
                                    Text("Gender:",
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: "Poppins")),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(left: 38),
                                        child: Text(driver.gender,
                                            style: const TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                                fontFamily: "Poppins")),
                                      ),
                                    ),
                                  ]),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Divider between Profile Info and Vehicle Info
                      const Divider(
                        color: Colors.white24,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),

                      const SizedBox(height: 16),

                      // Vehicle Info Card
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 16.0),
                            child: Text(
                              "Vehicles Info",
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: "Poppins"),
                            ),
                          ),
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: vehicleList.length,
                            itemBuilder: (context, index) {
                              final vehicle = vehicleList[index];
                              return VehicleCard(
                                vehicle: vehicle,
                                onDelete: () {
                                  setState(() {
                                    vehicleList.removeAt(index);
                                  });
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 20),
                          Center(
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    _showVehicleInfoDialog(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Consistent padding
                                    minimumSize: const Size(200,
                                        50), // Consistent size for all buttons
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Add Vehicle",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontFamily: "Poppins"),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () async {
                                    await AuthContext.logout(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Consistent padding
                                    minimumSize: const Size(200,
                                        50), // Consistent size for all buttons
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Logout',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: "Poppins"),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: () {
                                    // Add delete account functionality here
                                    print('Delete Account button clicked');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14), // Consistent padding
                                    minimumSize: const Size(200,
                                        50), // Consistent size for all buttons
                                    backgroundColor: Colors
                                        .red, // Red color for delete button
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Delete Account',
                                    style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                        fontFamily: "Poppins"),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: DriverNavbar(initialIndex: 4),
    );
  }

  String capitalize(String input) =>
      input.isNotEmpty ? '${input[0].toUpperCase()}${input.substring(1)}' : '';
}

import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';

class Vehicle {
  String name;
  String type;
  String regNumber;
  int capacity;
  bool hasAC;

  Vehicle({
    required this.name,
    required this.type,
    required this.regNumber,
    required this.capacity,
    required this.hasAC,
  });
}

class VehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  final VoidCallback onEdit;

  const VehicleCard({
    super.key,
    required this.vehicle,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      color: Colors.white.withOpacity(0.05), // glassy effect
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _vehicleRow("Name", vehicle.name),
                const SizedBox(height: 8),
                _vehicleRow("Type", vehicle.type),
                const SizedBox(height: 8),
                _vehicleRow("Reg #", vehicle.regNumber),
                const SizedBox(height: 8),
                _vehicleRow("Capacity", vehicle.capacity.toString()),
                const SizedBox(height: 8),
                _vehicleRow("A.C", vehicle.hasAC ? "Yes" : "No"),
              ],
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white70),
                onPressed: onEdit,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _vehicleRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(_getIcon(label), size: 18, color: Colors.white60),
        const SizedBox(width: 10),
        Text(
          label,
          style: const TextStyle(
              color: Colors.white70, fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          value,
          style:
              const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
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
  String firstName;
  String lastName;
  String password;
  String phone;
  String email;
  String gender;
  String profileImage;
  int rides;
  double rating;
  Vehicle vehicle;

  Driver({
    required this.firstName,
    required this.lastName,
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
  final Driver driver = Driver(
    firstName: "Shariq",
    lastName: "Munir",
    password: "********",
    phone: "03123456789",
    email: "l226680@lhr.nu.edu.pk",
    gender: "Male",
    profileImage: "assets/images/Sign-up.png",
    rides: 1900,
    rating: 4.8,
    vehicle: Vehicle(
      name: "Honda City",
      type: "Car",
      regNumber: "ABC-123",
      capacity: 4,
      hasAC: true,
    ),
  );

  List<Vehicle> vehicleList = [
    Vehicle(
        name: "Honda City",
        type: "Car",
        regNumber: "ABC-123",
        capacity: 4,
        hasAC: true),
    Vehicle(
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

    // Initialize driver

    // Create controllers
    controllers["firstname"] = TextEditingController(text: driver.firstName);
    controllers["lastName"] = TextEditingController(text: driver.lastName);
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
    final firstNameController = TextEditingController(text: driver.firstName);
    final lastNameController = TextEditingController(text: driver.lastName);

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
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('First Name',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: firstNameController,
                            style: const TextStyle(color: AppColors.textColor),
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Last Name',
                              style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 5),
                          TextField(
                            controller: lastNameController,
                            style: const TextStyle(color: AppColors.textColor),
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
                        onPressed: () {
                          setState(() {
                            driver.firstName = firstNameController.text;
                            driver.lastName = lastNameController.text;
                          });
                          Navigator.pop(context);
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
                          style: const TextStyle(color: Colors.grey),
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
                          style: const TextStyle(color: Colors.white),
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
                            style: const TextStyle(color: Colors.grey),
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
                        onPressed: () {
                          setState(() {
                            driver.phone = phoneController.text;
                          });
                          Navigator.pop(context);
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

  void _showVehicleInfoDialog(BuildContext context, int index) {
    final vehicle = vehicleList[index];
    final nameController = TextEditingController(text: vehicle.name);
    final regController = TextEditingController(text: vehicle.regNumber);
    String selectedType = vehicle.type;
    String selectedAC = vehicle.hasAC ? 'AC' : 'Non-AC';
    int capacity = vehicle.capacity;

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
                            color: Colors.white), // Match text color
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Name',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white), // Match text color
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: nameController,
                        style: const TextStyle(
                            color: Colors.grey), // Updated inside text to grey
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
                            color: Colors.white), // Match text color
                      ),
                      const SizedBox(height: 5),
                      TextField(
                        controller: regController,
                        style: const TextStyle(
                            color: AppColors.textColor), // Match text color
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
                            color: Colors.white), // Match text color
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
                            color: Colors.white), // Match text color
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
                            color: Colors.white), // Match text color
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
                              onPressed: () {
                                setState(() {
                                  vehicleList[index] = Vehicle(
                                    name: nameController.text,
                                    type: selectedType,
                                    regNumber: regController.text,
                                    capacity: capacity,
                                    hasAC: selectedAC == 'AC',
                                  );
                                });
                                this.setState(() {}); // Refresh the page
                                Navigator.pop(context);
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

  void editVehicle(BuildContext context, int index) {
    _showVehicleInfoDialog(context, index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
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
                    Text(driver.firstName + " " + driver.lastName,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 22)),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("${driver.rides} Rides",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                        const SizedBox(width: 20),
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text("${driver.rating}",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 14)),
                      ],
                    )
                  ],
                ),
                const SizedBox(height: 20),

                // Profile Info Card
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 8,
                    margin: EdgeInsets.zero,
                    child: Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF3A3A3A),
                            Color(0xFF1F1F1F),
                          ],
                        ),
                        borderRadius: BorderRadius.all(Radius.circular(16)),
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
                              Text("Name:",
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 45),
                                  child: Text(
                                      driver.firstName + " " + driver.lastName,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14)),
                                ),
                              ),
                              IconButton(
                                  onPressed: () => _showEditNameDialog(context),
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
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 20),
                                  child: Text(driver.password,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14)),
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
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 41),
                                  child: Text(driver.phone,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14)),
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
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 47),
                                    child: Text(driver.email,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14)),
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
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 38),
                                  child: Text(driver.gender,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 14)),
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
                            color: Colors.white),
                      ),
                    ),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: vehicleList.length,
                      itemBuilder: (context, index) {
                        final vehicle = vehicleList[index];
                        return StatefulBuilder(
                          builder: (context, setState) {
                            return Padding(
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
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        Color(0xFF3A3A3A),
                                        Color(0xFF1F1F1F),
                                      ],
                                    ),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      children: [
                                        // Adjusted spacing to ensure uniformity between all fields
                                        Row(children: [
                                          Text("Name:",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 80),
                                              child: Text(vehicle.name,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                          IconButton(
                                              onPressed: () =>
                                                  _showVehicleInfoDialog(
                                                      context, index),
                                              icon: Icon(Icons.edit,
                                                  color: Colors.white38,
                                                  size: 18)),
                                        ]),
                                        const SizedBox(height: 12),
                                        Row(children: [
                                          Text("Type:",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 87),
                                              child: Text(vehicle.type,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                        ]),
                                        const SizedBox(height: 12),
                                        Row(children: [
                                          Text("Reg #:",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 81),
                                              child: Text(vehicle.regNumber,
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                        ]),
                                        const SizedBox(height: 16),
                                        Row(
                                          children: [
                                            Text("Capacity:",
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 63),
                                                child: Text(
                                                    vehicle.capacity.toString(),
                                                    style: const TextStyle(
                                                        color: Colors.white70,
                                                        fontSize: 14)),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 20),
                                        Row(children: [
                                          Text("A.C:",
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold)),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 95),
                                              child: Text(
                                                  vehicle.hasAC ? "Yes" : "No",
                                                  style: const TextStyle(
                                                      color: Colors.white70,
                                                      fontSize: 14)),
                                            ),
                                          ),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
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
                              setState(() {
                                vehicleList.add(Vehicle(
                                  name: "New Vehicle",
                                  type: "Car",
                                  regNumber: "NEW-123",
                                  capacity: 4,
                                  hasAC: false,
                                ));
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14), // Consistent padding
                              minimumSize: const Size(
                                  200, 50), // Consistent size for all buttons
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Add Vehicle",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Add logout functionality here
                              print('Logout button clicked');
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 14), // Consistent padding
                              minimumSize: const Size(
                                  200, 50), // Consistent size for all buttons
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Logout',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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
                              minimumSize: const Size(
                                  200, 50), // Consistent size for all buttons
                              backgroundColor:
                                  Colors.red, // Red color for delete button
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Delete Account',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
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

        // Bottom Navigation Bar
        bottomNavigationBar: DriverNavbar(initial_index: 4));
  }

  String capitalize(String input) =>
      input.isNotEmpty ? '${input[0].toUpperCase()}${input.substring(1)}' : '';
}

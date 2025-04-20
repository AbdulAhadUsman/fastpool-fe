import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';

class Driver {
  String name;
  String password;
  String phone;
  String email;
  String gender;
  String profileImage;
  int rides;
  double rating;
  Vehicle vehicle;

  Driver({
    required this.name,
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

class DriverProfileScreen extends StatefulWidget {
  const DriverProfileScreen({super.key});

  @override
  State<DriverProfileScreen> createState() => _DriverProfileScreenState();
}

class _DriverProfileScreenState extends State<DriverProfileScreen> {
  final Driver driver = Driver(
    name: "Shariq Munir",
    password: "********",
    phone: "1234–5678911",
    email: "l226680@lhr.nu.edu.pk",
    gender: "Male",
    profileImage: "",
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

  // Text controllers
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isEditing = {};

  @override
  void initState() {
    super.initState();

    // Initialize driver

    // Create controllers
    controllers["name"] = TextEditingController(text: driver.name);
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

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/Sign-up.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent,
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
                      Text(driver.name,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22)),
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
                                    child: Text(driver.name,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14)),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
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
                                            color: Colors.white70,
                                            fontSize: 14)),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
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
                                            color: Colors.white70,
                                            fontSize: 14)),
                                  ),
                                ),
                                IconButton(
                                    onPressed: () {},
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
                  ),
                  const SizedBox(height: 16),

                  // Vehicle Info Card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      color: const Color(0xFF1E1E1E),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Vehicles Info",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            _buildVehicleRow("Name", driver.vehicle.name),
                            _buildVehicleRow("Type", driver.vehicle.type),
                            _buildVehicleRow("Reg #", driver.vehicle.regNumber),
                            _buildVehicleRow(
                                "Capacity", driver.vehicle.capacity.toString()),
                            _buildVehicleRow(
                                "A.C", driver.vehicle.hasAC ? "Yes" : "No"),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {},
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12))),
                                child: const Text("Add Vehicle"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Navigation Bar
          bottomNavigationBar: BottomNavigationBar(
            backgroundColor: const Color(0xFF1A1A1A),
            selectedItemColor: Colors.blueAccent,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
              BottomNavigationBarItem(
                  icon: Icon(Icons.directions_car), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.add), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.message), label: ""),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
            ],
          ),
        ));
  }

  Widget _buildEditableRow(String key, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text("${capitalize(key)}:",
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(width: 20),
          Expanded(
            child: isEditing[key] == true
                ? TextField(
                    controller: controllers[key],
                    style: const TextStyle(color: Colors.white),
                    cursorColor: Colors.white,
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.white24)),
                      focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.blueAccent)),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.only(left: 20),
                    child: Text(
                      controllers[key]!.text,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
          ),
          IconButton(
            onPressed: () => toggleEdit(key),
            icon: Icon(
              isEditing[key] == true ? Icons.check : Icons.edit,
              color: Colors.white38,
              size: 18,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildVehicleRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text("$title:",
              style: const TextStyle(color: Colors.white70, fontSize: 14)),
          const SizedBox(width: 8),
          Expanded(
              child: Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14))),
        ],
      ),
    );
  }

  String capitalize(String input) =>
      input.isNotEmpty ? '${input[0].toUpperCase()}${input.substring(1)}' : '';
}

import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:fastpool_fe/context/AuthContext.dart';

class Rider {
  String username;
  String password;
  String phone;
  String email;
  String gender;
  String profileImage;
  double rating;

  Rider({
    required this.username,
    required this.password,
    required this.phone,
    required this.email,
    required this.gender,
    required this.profileImage,
    required this.rating,
  });
}

class RiderProfile extends StatefulWidget {
  const RiderProfile({super.key});

  @override
  State<RiderProfile> createState() => _RiderProfileState();
}

class _RiderProfileState extends State<RiderProfile> {
  bool isLoading = true; // Add loading state

  Rider rider = Rider(
    username: "",
    password: "",
    phone: "",
    email: "",
    gender: "",
    profileImage: "assets/images/Sign-up.png",
    rating: 4.8,
  );

  // final ImagePicker _picker = ImagePicker();

  // Text controllers
  final Map<String, TextEditingController> controllers = {};
  final Map<String, bool> isEditing = {};

  @override
  void initState() {
    super.initState();
    _loadRiderData();
    // Initialize controllers
    controllers["username"] = TextEditingController(text: rider.username);
    controllers["password"] = TextEditingController(text: rider.password);
    controllers["phone"] = TextEditingController(text: rider.phone);
    controllers["email"] = TextEditingController(text: rider.email);
    controllers["gender"] = TextEditingController(text: rider.gender);

    // Initial edit states
    isEditing["name"] = false;
    isEditing["password"] = false;
    isEditing["phone"] = false;
    isEditing["email"] = false;
    isEditing["gender"] = false;
  }

  Future<void> _loadRiderData() async {
    setState(() {
      isLoading = true; // Set loading state to true
    });

    // Simulate fetching data from local storage and AuthContext
    final username = AuthContext.getUsername();
    final email = AuthContext.getEmail();
    final phone = AuthContext.getPhone();
    final gender = AuthContext.getGender();
    final ratings = AuthContext.getRatings();

    await Future.delayed(const Duration(seconds: 2)); // Simulate delay

    setState(() {
      rider.username = username ?? "Unknown";
      rider.email = email ?? "Unknown";
      rider.phone = phone ?? "Unknown";
      rider.gender = gender ?? "Unknown";
      rider.rating = ratings ?? 0.0;
      isLoading = false; // Set loading state to false
    });

    print("Rider data loaded: $username, $email, $phone, $gender, $ratings");
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
    final usernameController = TextEditingController(text: rider.username);

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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Username',
                      style: TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: usernameController,
                      style: const TextStyle(color: Colors.white),
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
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            rider.username = usernameController.text;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Confirm"),
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
    final passwordController = TextEditingController(text: rider.password);
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
                          style: const TextStyle(color: Colors.white),
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
                            child: const Text("Cancel"),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              if (passwordController.text ==
                                  confirmPasswordController.text) {
                                setState(() {
                                  rider.password = passwordController.text;
                                });
                                this.setState(() {}); // Refresh the page
                                Navigator.pop(context);
                              } else {
                                // Handle password mismatch (optional)
                              }
                            },
                            child: const Text("Confirm"),
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
    final phoneController = TextEditingController(text: rider.phone);

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
                            style: const TextStyle(color: Colors.white),
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
                        child: const Text("Cancel"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            rider.phone = phoneController.text;
                          });
                          Navigator.pop(context);
                        },
                        child: const Text("Confirm"),
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

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(
              color: Colors.blueAccent,
            ),
          )
        : RefreshIndicator(
            onRefresh: _loadRiderData, // Add pull-to-refresh functionality
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/Sign-up.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Scaffold(
                backgroundColor: AppColors.backgroundColor,
                body: SafeArea(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        // Profile Picture & Stats
                        Column(
                          children: [
                            Stack(
                              alignment: Alignment.bottomRight,
                              children: [
                                CircleAvatar(
                                  radius: 45,
                                  backgroundImage:
                                      AssetImage(rider.profileImage),
                                ),
                                IconButton(
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(rider.username,
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 22)),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 16),
                                const SizedBox(width: 4),
                                Text("${rider.rating}",
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    // Adjusted spacing to ensure uniformity between all fields
                                    Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left:
                                                8.0), // Consistent padding for icons
                                        child: Icon(
                                          Icons.person,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text("Name:",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 45),
                                          child: Text(rider.username,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14)),
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left:
                                                8.0), // Consistent padding for icons
                                        child: Icon(
                                          Icons.lock,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text("Password:",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 20),
                                          child: Text(rider.password,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14)),
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
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left:
                                                8.0), // Consistent padding for icons
                                        child: Icon(
                                          Icons.phone,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text("Phone:",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 41),
                                          child: Text(rider.phone,
                                              style: const TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14)),
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
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              left:
                                                  8.0), // Consistent padding for icons
                                          child: Icon(
                                            Icons.mail,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text("Email:",
                                            style: const TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.bold)),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 47),
                                            child: Text(rider.email,
                                                style: const TextStyle(
                                                    color: Colors.white70,
                                                    fontSize: 14)),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 20),
                                    Row(children: [
                                      Padding(
                                        padding: const EdgeInsets.only(
                                            left:
                                                8.0), // Consistent padding for icons
                                        child: Icon(
                                          rider.gender.toLowerCase() == "male"
                                              ? Icons.male
                                              : Icons.female,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text("Gender:",
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Padding(
                                          padding:
                                              const EdgeInsets.only(left: 38),
                                          child: Text(rider.gender,
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

                        // Vehicle Info Card
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () async {
                            await AuthContext.logout(context);
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(200, 50),
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
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Add delete account functionality here
                            print('Delete Account button clicked');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            minimumSize: const Size(200, 50),
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                bottomNavigationBar: RiderNavbar(
                  initialIndex: 4,
                ),
              ),
            ),

          );

  }
}

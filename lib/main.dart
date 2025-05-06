import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:fastpool_fe/pages/NewRide.dart';
import 'package:fastpool_fe/pages/driverHome.dart';
import 'package:fastpool_fe/pages/driverProfile.dart';
import 'package:fastpool_fe/pages/loading.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:fastpool_fe/pages/riderHome.dart';
import 'package:fastpool_fe/pages/riderProfile.dart';
import 'package:fastpool_fe/pages/roleSelection.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:fastpool_fe/pages/selectVehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AuthContext.init(); // Initialize Hive
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  Future<void> _checkLoginStatus() async {
    if (AuthContext.isLoggedIn()) {
      await AuthContext.navigateUserBasedOnRole(context);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => SignUp()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Show a loading indicator
      ),
    );
  }
}

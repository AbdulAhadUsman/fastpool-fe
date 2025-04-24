import 'package:fastpool_fe/pages/NewRide.dart';
import 'package:fastpool_fe/pages/driverProfile.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:fastpool_fe/pages/riderProfile.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:fastpool_fe/pages/selectVehicle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';

// void checkEnvFile() async {
//   final scriptDir = File(Platform.resolvedExecutable).parent.path;
//   final file = File('$scriptDir/.env');

//   if (await file.exists()) {
//     print('.env file exists at ${file.path}');
//   } else {
//     print('.env file NOT FOUND at ${file.path}');
//   }
// }

// void checkWorkingDirectory() {
//   print('Current working directory: ${Directory.current.path}');
// }

Future<void> main() async {
  // checkEnvFile();
  // checkWorkingDirectory();
  // await dotenv.load(fileName: ".env"); // Load .env file
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: NewRide());
  }
}

import 'dart:convert';

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class verifyAccount extends StatefulWidget {
  final String username;
  final String gender;
  final String phone;
  final String email;
  final String password;
  const verifyAccount({
    super.key,
    required this.username,
    required this.gender,
    required this.phone,
    required this.email,
    required this.password,
  });

  @override
  State<verifyAccount> createState() => _verifyAccountState();
}

class _verifyAccountState extends State<verifyAccount> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

  void postData() async {
    String current_api = api + 'users/verify/';

    try {
      http.Response response = await http.post(Uri.parse(current_api),
          headers: <String, String>{
            'Content-Type': 'application/json; charset=UTF-8',
          },
          body: jsonEncode({
            'username': widget.username,
            'email': widget.email,
            'gender': widget.gender,
            'phone': widget.phone,
            'password': widget.password,
            'otp': otpController.text,
          }));
      if (response.statusCode == 201) {
        print('Account created successfully');
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => Login()));
      } else {
        print('different status code');
        print(response.body);
        print(response.statusCode);
      }
    } catch (e) {
      print('in the catch block');
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/forgotPassword.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 90),
                        child: Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // Center the text
                          children: [
                            Text(
                              "Verify Account",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: MediaQuery.of(context).size.width *
                                    0.08, // Dynamic font size
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Proza Libre',
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              softWrap: false,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Text(
                        'You have been emailed a code on the provided email. Please enter it below to verify yourself',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Poppins',
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: screenHeight * 0.04),
                      MyTextField(
                        controller: otpController,
                        hintText: 'Code',
                        obscureText: false,
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () => postData(),
                            child: Container(
                              height: screenHeight * 0.06,
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.09),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: AppColors.buttonColor,
                                    stops: AppColors.gradientStops),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Verify",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ))));
  }
}

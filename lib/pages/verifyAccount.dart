import 'dart:convert';

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fastpool_fe/context/AuthContext.dart';

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
  bool _isVerifying = false; // Flag to track verification state

  void verify() async {
    // Only proceed if not already verifying
    if (_isVerifying) return;

    // Validate form first
    if (!_formKey.currentState!.validate()) return;

    // Set verifying state to true
    setState(() {
      _isVerifying = true;
    });

    try {
      final success = await AuthContext.verify(
        username: widget.username,
        email: widget.email,
        gender: widget.gender,
        phone: widget.phone,
        password: widget.password,
        otp: otpController.text.toString(),
      );

      // Set verifying state back to false
      setState(() {
        _isVerifying = false;
      });

      if (success) {
        // Navigate to the login page on successful verification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Account verified successfully!')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Login()),
        );
      } else {
        // Show error message if verification fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Verification failed. Please try again.')),
        );
      }
    } catch (e) {
      // Handle exceptions and show error message
      setState(() {
        _isVerifying = false; // Ensure button is re-enabled on error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
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
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter the verification code';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _isVerifying ? null : () => verify(),
                            child: Container(
                              height: screenHeight * 0.06,
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.09),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: _isVerifying
                                      ? [
                                          Colors.grey.shade400,
                                          Colors.grey.shade600
                                        ] // Disabled gradient
                                      : AppColors
                                          .buttonColor, // Normal gradient
                                  stops: _isVerifying
                                      ? [
                                          0.0,
                                          1.0
                                        ] // Stops for disabled gradient
                                      : AppColors
                                          .gradientStops, // Normal gradient stops
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: _isVerifying
                                    ? Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                            width: 20,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: Colors.white,
                                            ),
                                          ),
                                          SizedBox(width: 10),
                                          Text(
                                            "Verifying...",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: screenWidth * 0.045,
                                              fontFamily: 'Poppins',
                                            ),
                                          ),
                                        ],
                                      )
                                    : Text(
                                        "Verify",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: screenWidth * 0.045,
                                          fontFamily: 'Poppins',
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      // Add resend code option
                      SizedBox(height: screenHeight * 0.02),
                      TextButton(
                        onPressed: _isVerifying
                            ? null
                            : () {
                                // Implement resend code functionality here
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'A new verification code has been sent to your email')),
                                );
                              },
                        child: Text(
                          "Resend Code",
                          style: TextStyle(
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ),
                    ],
                  ),
                ))));
  }
}

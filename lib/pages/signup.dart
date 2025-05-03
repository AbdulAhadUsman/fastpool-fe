import 'dart:convert';

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/gender_selection.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/constants/api.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:fastpool_fe/pages/login.dart';
import 'package:fastpool_fe/pages/verifyAccount.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SignUp extends StatefulWidget {
  SignUp({super.key});

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  String selectedGender = "";
  bool _validateGender = false;
  bool _isSubmitting = false; // Add a flag to track submission state


  void registerUser({
    required String username,
    required String email,
    required String gender,
    required String phone,
    required String password,
  }) async {
    try {
      final success = await AuthContext.register(
        username: username,
        email: email,
        gender: gender,
        phoneNumber: phone,
        password: password,
      );

      if (success) {
        // Navigate to the verification page on successful registration
        Navigator.pushReplacement(

          context,
          MaterialPageRoute(
            builder: (context) => verifyAccount(
              username: username,
              gender: gender,
              phone: phone,
              email: email,
              password: password,
            ),
          ),
        );
      } else {
        // Show error message if registration fails
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Registration failed. Please try again.')),
        );
      }
    } catch (e) {
      // Handle exceptions and show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );

    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isValidUsername = false;
    bool isValidEmail = false;
    bool isValidPhone = false;
    bool isValidPassword = false;
    bool isValidConfirmPassword = false;

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Sign-up.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        resizeToAvoidBottomInset: true,
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // first adding the get started and create an account text
                Padding(
                  padding: EdgeInsets.only(top: screenHeight * 0.15),
                  child: Center(
                    child: Column(
                      children: [
                        Text(
                          'Get Started',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.08,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Create an account to continue!',
                          style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenWidth * 0.04,
                              color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.03),
                // adding the username text fields
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: MyTextField(
                    controller: usernameController,
                    hintText: 'Username',
                    obscureText: false,
                    hasPrefixIcon: true,
                    prefixIcon: Icon(Icons.person, color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      isValidUsername = true;
                      return null;
                    },
                  ),
                ),
                // adding the gender fields
                SizedBox(height: screenHeight * 0.02),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: Row(
                    children: [
                      Expanded(
                        child: GenderSelection(
                          selectedGender: selectedGender,
                          onGenderSelected: (value) {
                            setState(() {
                              selectedGender = value;
                            });
                          },
                          validator: (value) {
                            if (_validateGender &&
                                (selectedGender == null ||
                                    selectedGender!.isEmpty)) {
                              return 'Please select your gender';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // SizedBox(height: screenHeight * 0.02),
                // adding the email text field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    hasPrefixIcon: true,
                    prefixIcon: Icon(Icons.mail, color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                      isValidEmail = true;
                      return null;
                    },
                  ),
                ),

                SizedBox(height: screenHeight * 0.02),

                // adding the phone number text field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: MyTextField(
                    controller: phoneController,
                    hintText: 'Phone',
                    obscureText: false,
                    hasPrefixIcon: true,
                    prefixIcon: Icon(Icons.phone, color: Colors.white),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      isValidPhone = true;
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // adding the password text field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: MyTextField(
                    controller: passwordController,
                    hintText: 'Password',
                    obscureText: true,
                    hasPrefixIcon: true,
                    prefixIcon: Icon(Icons.key, color: Colors.white),
                    hasSuffixIconButton: true,
                    suffixIconButton: IconButton(
                      icon: Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          passwordController.text = passwordController.text;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      isValidPassword = true;
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // adding the confirm password text field
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                  child: MyTextField(
                    controller: confirmPasswordController,
                    hintText: 'Confirm Password',
                    obscureText: true,
                    hasPrefixIcon: true,
                    prefixIcon: Icon(Icons.key, color: Colors.white),
                    hasSuffixIconButton: true,
                    suffixIconButton: IconButton(
                      icon: Icon(Icons.visibility, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          confirmPasswordController.text =
                              confirmPasswordController.text;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != passwordController.text) {
                        return 'Passwords do not match';
                      }
                      isValidConfirmPassword = true;
                      return null;
                    },
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // adding the sign up button
                GestureDetector(

                  onTap: () {
                    setState(() {
                      _validateGender = true;
                    });
                    if (_formKey.currentState!.validate()) {
                      if (isValidUsername &&
                          isValidEmail &&
                          isValidPhone &&
                          isValidPassword &&
                          isValidConfirmPassword &&
                          _validateGender) {
                        registerUser(
                          username: usernameController.text,
                          email: emailController.text,
                          gender: selectedGender,
                          phone: phoneController.text,
                          password: passwordController.text,
                        );
                      }
                    }
                  },

                  child: Container(
                    height: screenHeight * 0.06,
                    margin:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    padding:
                        EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                          colors: _isSubmitting
                              ? [Colors.grey, Colors.grey] // Disabled gradient
                              : AppColors.buttonColor, // Normal gradient
                          stops: _isSubmitting
                              ? [
                                  0.0,
                                  1.0
                                ] // Ensure equal length for disabled gradient
                              : AppColors
                                  .gradientStops), // Normal gradient stops
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        _isSubmitting ? "Submitting..." : "Sign Up",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.045,
                            fontFamily: 'Poppins'),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
                // adding the sign in prompt
                Padding(
                  padding: EdgeInsets.only(bottom: screenWidth * 0.02),
                  child: Row(
                    children: [
                      // Left Divider
                      Expanded(
                          child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.transparent, Color(0xA4A4A4A4)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          left: screenWidth * 0.05,
                          right: screenWidth * 0.025,
                        ),
                      )),
                      // Text
                      RichText(
                        text: TextSpan(
                          text: "Already have an account? ",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: screenWidth * 0.04),
                          children: [
                            TextSpan(
                              text: "Sign-in",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  print("Sign-in");
                                  //routing to signin
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => Login()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                      // Right Divider
                      Expanded(
                          child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xA4A4A4A4), Colors.transparent],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                        ),
                        margin: EdgeInsets.only(
                          left: screenWidth * 0.025,
                          right: screenWidth * 0.05,
                        ),
                      )),
                    ],
                  ),
                ),
                SizedBox(height: screenHeight * 0.02),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

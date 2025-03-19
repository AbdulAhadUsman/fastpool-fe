import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:fastpool_fe/pages/forgotPassword.dart';
import 'package:fastpool_fe/pages/verifyAccount.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();

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
                              "Forgot Password?",
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
                      Text('Enter your Email to get a reset link',
                          style: TextStyle(
                            color: AppColors.textColor,
                            fontSize: screenWidth * 0.035,
                            fontFamily: 'Poppins',
                          )),
                      SizedBox(height: screenHeight * 0.04),
                      MyTextField(
                        controller: emailController,
                        hintText: 'Email',
                        obscureText: false,
                        hasPrefixIcon: true,
                        prefixIcon: Icon(
                          Icons.mail,
                          color: const Color.fromARGB(255, 186, 186, 186),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: screenHeight * 0.03),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              print("cancel");
                              Navigator.pop(context); //go back to login
                            },
                            child: Container(
                              height: screenHeight * 0.06,
                              margin: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.01),
                              padding: EdgeInsets.symmetric(
                                  horizontal: screenWidth * 0.09),
                              decoration: BoxDecoration(
                                color: AppColors.CancelButton,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: screenWidth * 0.045,
                                      fontFamily: 'Poppins'),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              if (_formKey.currentState!.validate()) {
                                print("Reset");
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => resetAccount()),
                                );
                              }
                            },
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
                                  "Reset",
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

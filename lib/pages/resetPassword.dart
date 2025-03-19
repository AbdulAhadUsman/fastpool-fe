import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:fastpool_fe/pages/forgotPassword.dart';
import 'package:fastpool_fe/pages/verifyAccount.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Resetpassword extends StatefulWidget {
  const Resetpassword({super.key});

  @override
  State<Resetpassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<Resetpassword> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final usernameController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isValidPassword = false;
    bool isValidConfirmPassword = false;
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
                // padding: EdgeInsets.symmetric(horizontal: 20),
                child: Form(
              key: _formKey,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 90),
                      child: Row(
                        mainAxisAlignment:
                            MainAxisAlignment.center, // Center the text
                        children: [
                          Text(
                            "Reset Password",
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
                    Text('Set your new password to login',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontSize: screenWidth * 0.035,
                          fontFamily: 'Poppins',
                        )),
                    SizedBox(height: screenHeight * 0.04),

                    SizedBox(height: screenHeight * 0.03),
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                      padding:
                          EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
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
                    GestureDetector(
                      onTap: () {
                        if (_formKey.currentState!.validate()) {
                          print("Before Validation: ${_formKey.currentState}");
                          print("Login");
                          bool check = _formKey.currentState!.validate();
                          print(check);
                          // return;
                          if (isValidPassword) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => SignUp()),
                            );
                          }
                        }
                      },
                      child: Container(
                        height: screenHeight * 0.06,
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.03),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: AppColors.buttonColor,
                              stops: AppColors.gradientStops),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            "Confirm",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: screenWidth * 0.045,
                                fontFamily: 'Poppins'),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ))));
  }
}

import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/pages/roleSelection.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:fastpool_fe/pages/forgotPassword.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:fastpool_fe/pages/roleSelection.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false; // Loading state flag

  void login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true; // Disable the button
      });
      try {
        final success = await AuthContext.login(
          emailController.text,
          passwordController.text,
        );

        if (success) {
          // Navigate the user to the RoleSelectionPage
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RoleSelection()),
          );
        } else {
          // Show error message if login fails
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Login failed. Please check your credentials.')),
          );
        }
      } catch (e) {
        // Handle exceptions and show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          isLoading = false; // Re-enable the button
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isValidEmail = false;
    bool isValidPassword = false;
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/Login.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 90),
                child: Row(
                  children: [
                    // Left Divider
                    Expanded(
                        child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Color.fromARGB(255, 255, 255, 255),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        left: screenWidth * 0.001,
                        right: screenWidth * 0.0025,
                      ),
                    )),
                    // Text
                    RichText(
                      text: TextSpan(
                        text: "FASTPOOL",
                        style: TextStyle(
                            color: AppColors.logoColor,
                            fontSize: screenWidth * 0.12,
                            fontFamily: 'Proza Libre',
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Right Divider
                    Expanded(
                        child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Color.fromARGB(255, 255, 255, 255),
                            Colors.transparent
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      margin: EdgeInsets.only(
                        left: screenWidth * 0.0025,
                        right: screenWidth * 0.001,
                      ),
                    )),
                  ],
                ),
              ),
              SizedBox(
                height: 120,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Form(
                  key: _formKey,
                  child: Column(children: [
                    Text('Welcome Back!',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.08,
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold)),
                    Text('welcome back we missed you',
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
                        isValidEmail = true;
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                      prefixIcon: Icon(
                        Icons.key,
                        color: const Color.fromARGB(255, 186, 186, 186),
                      ),
                      hasPrefixIcon: true,
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
                        isValidPassword = true;
                        return null;
                      },
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            text: "Forgot Password?",
                            style: TextStyle(
                                color: AppColors.textColor,
                                fontSize: screenWidth * 0.04),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ForgotPassword()),
                                );
                              },
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    GestureDetector(
                      onTap: isLoading
                          ? null
                          : () => login(), // Disable tap if loading
                      child: Container(
                        height: screenHeight * 0.06,
                        margin: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.01),
                        padding: EdgeInsets.symmetric(
                            horizontal: screenWidth * 0.05),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isLoading
                                ? [
                                    Colors.grey.shade400,
                                    Colors.grey.shade600
                                  ] // Disabled gradient
                                : AppColors.buttonColor, // Active gradient
                            stops: isLoading
                                ? [0.0, 1.0] // Stops for disabled gradient
                                : AppColors
                                    .gradientStops, // Normal gradient stops
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: isLoading
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
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
                                      "Logging in...",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: screenWidth * 0.045,
                                        fontFamily: 'Poppins',
                                      ),
                                    ),
                                  ],
                                )
                              : Text(
                                  "Login",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: screenWidth * 0.045,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),
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
                                colors: [Colors.transparent, Colors.white],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            margin: EdgeInsets.only(
                              left: screenWidth * 0.001,
                              right: screenWidth * 0.025,
                            ),
                          )),
                          // Text
                          RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: screenWidth * 0.04),
                              children: [
                                TextSpan(
                                  text: "Sign up",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      print("Sign up");
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SignUp()),
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
                                colors: [Colors.white, Colors.transparent],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            margin: EdgeInsets.only(
                              left: screenWidth * 0.02,
                              right: screenWidth * 0.001,
                            ),
                          )),
                        ],
                      ),
                    ),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

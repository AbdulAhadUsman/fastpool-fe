import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/my_textField.dart';
import 'package:fastpool_fe/pages/signup.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class resetAccount extends StatefulWidget {
  const resetAccount({super.key});

  @override
  State<resetAccount> createState() => _resetAccountState();
}

class _resetAccountState extends State<resetAccount> {
  final _formKey = GlobalKey<FormState>();
  final otpController = TextEditingController();

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
                        'You been emailed a code on the provided email. Please enter it below to verify yourself',
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
                            onTap: () {
                              print("Verify");
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

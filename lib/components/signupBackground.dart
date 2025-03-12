import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class Signupbackground extends StatelessWidget {
  const Signupbackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: SvgPicture.asset("lib/images/signup.svg", fit: BoxFit.cover),
    );
  }
}

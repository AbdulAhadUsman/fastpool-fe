import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';

class MyTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final String? Function(String?)? validator;
  final bool hasPrefixIcon;
  final Icon? prefixIcon;
  final bool hasSuffixIconButton;
  final IconButton? suffixIconButton;

  const MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.validator,
    this.hasPrefixIcon = false,
    this.prefixIcon,
    this.hasSuffixIconButton = false,
    this.suffixIconButton,
  });

  @override
  _MyTextFieldState createState() => _MyTextFieldState();
}

class _MyTextFieldState extends State<MyTextField> {
  late bool _obscureText;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.hintText,
          style: TextStyle(
              color: AppColors.textColor,
              fontFamily: 'Poppins',
              fontSize: screenWidth * 0.04),
        ),
        SizedBox(height: 5),
        Container(
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: AppColors.textFieldColor,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextFormField(
            controller: widget.controller,
            cursorColor: AppColors.cursorColor,
            obscureText: _obscureText,
            style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontFamily: 'Poppins'),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 7),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: AppColors.focusedBorderColor),
              ),
              fillColor: Color(0xFF282828), // Updated background color
              filled: true, // Enable the fill color
              prefixIcon: widget.hasPrefixIcon ? widget.prefixIcon : null,
              suffixIcon: widget.hasSuffixIconButton
                  ? IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    )
                  : null,
            ),
            validator: (value) {
              final error = widget.validator?.call(value);
              setState(() {
                _errorMessage = error;
              });
              return null; // Prevents default error message display inside the field
            },
          ),
        ),
        if (_errorMessage != null) ...[
          SizedBox(height: 5),
          Text(
            _errorMessage!,
            style: TextStyle(
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';

class GenderSelection extends StatefulWidget {
  final String? selectedGender;
  final void Function(String) onGenderSelected; // Callback function
  final String? Function(String?)? validator;

  GenderSelection({
    super.key,
    required this.selectedGender,
    required this.onGenderSelected, // Required callback
    this.validator,
  });

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
  int? selectedIndex; // Track the selected index
  final List<String> genderOptions = ["Male", "Female", "Other"];

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
              color: Colors.white,
              fontSize: screenWidth * 0.04,
              fontFamily: 'Poppins'),
        ),
        SizedBox(height: screenWidth * 0.02), // Add spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(genderOptions.length, (index) {
            return Padding(
              padding: EdgeInsets.only(right: screenWidth * 0.02),
              child: Container(
                height: screenWidth * 0.12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: AppColors.textFieldColor,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedIndex = index;
                    });

                    widget.onGenderSelected(genderOptions[index]); // Callback
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: selectedIndex == index
                        ? Colors.blue // Selected color
                        : Color(0x1E1E1E1E), // Default color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color:
                            selectedIndex == index ? Colors.blue : Colors.grey,
                      ),
                    ),
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.05,
                        vertical: screenWidth * 0.025),
                  ),
                  child: Center(
                    child: Text(
                      genderOptions[index],
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.04,
                          fontFamily: 'Poppins'),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
        if (widget.validator != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.validator!(widget.selectedGender) ?? '',
              style: TextStyle(color: Colors.red, fontSize: screenWidth * 0.03),
            ),
          ),
      ],
    );
  }
}

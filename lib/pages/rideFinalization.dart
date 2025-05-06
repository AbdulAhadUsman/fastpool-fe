import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/progressBar.dart';
import 'package:flutter/material.dart';

class RideFinalization extends StatefulWidget {
  const RideFinalization({super.key});

  @override
  State<RideFinalization> createState() => _RideFinalizationState();
}

class _RideFinalizationState extends State<RideFinalization> {
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _isAM = true;
  DateTime _selectedDate = DateTime.now();
  int _seats = 4;
  bool _acEnabled = true;
  String _preferredGender = 'All';
  bool _isFree = false;
  double _amount = 100;
  String _paymentOption = 'Cash';

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isAfter(DateTime.now())
          ? _selectedDate
          : DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2026),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Finalization",
          style: TextStyle(color: Colors.white, fontFamily: "Poppins"),
        ),
        backgroundColor: AppColors.backgroundColor,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(
            color: Colors.white), // Set back button color to white
      ),
      backgroundColor: AppColors.backgroundColor,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              color: Colors.white24, // Divider color
              thickness: 1, // Divider thickness
              height: 1, // Space occupied by the divider
            ),
            const SizedBox(height: 20),
            const Text(
              'ENTER TIME',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    controller: TextEditingController(
                      text:
                          '${_selectedTime.hour}:${_selectedTime.minute.toString().padLeft(2, '0')}',
                    ),
                    onTap: () => _selectTime(context),
                    decoration: const InputDecoration(
                      labelText: 'Hour Minute',
                      labelStyle: TextStyle(
                          color: AppColors.textColor), // Updated label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColors
                                .backgroundColor), // Match border color to background
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Set border color to blue when focused
                      ),
                      hintStyle: TextStyle(
                          color: AppColors
                              .textColor), // Explicitly set hint color to AppColors.textColor
                      fillColor: Color(0xFF282828), // Updated background color
                      filled: true,
                    ),
                    style: TextStyle(
                        color: AppColors
                            .textColor), // Set text color to AppColors.textColor
                  ),
                ),
                const SizedBox(width: 16),
                ToggleButtons(
                  isSelected: [_isAM, !_isAM],
                  onPressed: (index) {
                    setState(() {
                      _isAM = index == 0;
                    });
                  },
                  color: AppColors.textColor, // Default text color
                  selectedColor: Colors.white, // Text color when selected
                  fillColor: Colors.blue, // Background color when selected
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('AM'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text('PM'),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 40),
            const Text(
              'Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              readOnly: true,
              controller: TextEditingController(
                text:
                    '${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}',
              ),
              onTap: () => _selectDate(context),
              decoration: const InputDecoration(
                labelText: 'Date',
                labelStyle: TextStyle(
                    color: AppColors.textColor), // Updated label color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors
                          .backgroundColor), // Match border color to background
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.blue), // Set border color to blue when focused
                ),
                hintStyle:
                    TextStyle(color: AppColors.textColor), // Updated hint color
                fillColor: Color(0xFF282828), // Updated background color
                filled: true,
              ),
              style: TextStyle(
                  color: AppColors
                      .textColor), // Set text color to AppColors.textColor
            ),
            const Divider(height: 40),
            const Text(
              'Seats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              value: _seats,
              items: List.generate(8, (index) => index + 1)
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text('$value'),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _seats = value!;
                });
              },
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors
                          .backgroundColor), // Match border color to background
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.blue), // Set border color to blue when focused
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                labelStyle: TextStyle(
                    color: AppColors.textColor), // Updated label color
                hintStyle:
                    TextStyle(color: AppColors.textColor), // Updated hint color
                fillColor: Color(0xFF282828), // Updated background color
                filled: true,
              ),
              style: TextStyle(
                  color: AppColors
                      .textColor), // Set text color to AppColors.textColor
              dropdownColor: Color(
                  0xFF282828), // Match dropdown menu background to text field box
            ),
            const Divider(height: 40),
            const Text(
              'AC',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            ToggleButtons(
              isSelected: [_acEnabled, !_acEnabled],
              onPressed: (index) {
                setState(() {
                  _acEnabled = index == 0;
                });
              },
              color: AppColors.textColor, // Default text color
              selectedColor: Colors.white, // Text color when selected
              fillColor: Colors.blue, // Background color when selected
              children: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('On'),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text('Off'),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text(
              'Preferred Gender',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _preferredGender,
              items: ['Male', 'Female', 'All']
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _preferredGender = value!;
                });
              },
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors
                          .backgroundColor), // Match border color to background
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.blue), // Set border color to blue when focused
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                labelStyle: TextStyle(
                    color: AppColors.textColor), // Updated label color
                hintStyle:
                    TextStyle(color: AppColors.textColor), // Updated hint color
                fillColor: Color(0xFF282828), // Updated background color
                filled: true,
              ),
              style: TextStyle(
                  color: AppColors
                      .textColor), // Set text color to AppColors.textColor
              dropdownColor: Color(
                  0xFF282828), // Match dropdown menu background to text field box
            ),
            const Divider(height: 40),
            const Text(
              'Amount',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Text('Rs',
                    style: TextStyle(
                        fontSize: 16,
                        fontFamily: "Poppins",
                        color: AppColors.textColor)),
                const SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    enabled: !_isFree,
                    controller: TextEditingController(text: _amount.toString()),
                    onChanged: (value) {
                      setState(() {
                        _amount = double.tryParse(value) ?? 0;
                      });
                    },
                    decoration: const InputDecoration(
                      labelText: 'Amount',
                      labelStyle: TextStyle(
                          color: AppColors.textColor), // Updated label color
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: AppColors
                                .backgroundColor), // Match border color to background
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                            color: Colors
                                .blue), // Set border color to blue when focused
                      ),
                      hintStyle: TextStyle(
                          color: AppColors.textColor), // Updated hint color
                      fillColor: Color(0xFF282828), // Updated background color
                      filled: true,
                    ),
                    style: TextStyle(
                        color: AppColors
                            .textColor), // Set text color to AppColors.textColor
                  ),
                ),
                const SizedBox(width: 16),
                Checkbox(
                  value: _isFree,
                  onChanged: (value) {
                    setState(() {
                      _isFree = value ?? false;
                    });
                  },
                ),
                const Text(
                  'Free',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    color: AppColors.textColor, // Updated text color
                  ),
                ),
              ],
            ),
            const Divider(height: 40),
            const Text(
              'Payment Option',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
                fontFamily: "Poppins",
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _paymentOption,
              items: ['Cash', 'Online']
                  .map((value) => DropdownMenuItem(
                        value: value,
                        child: Text(value),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _paymentOption = value!;
                });
              },
              decoration: const InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color: AppColors
                          .backgroundColor), // Match border color to background
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                      color:
                          Colors.blue), // Set border color to blue when focused
                ),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
                labelStyle: TextStyle(
                    color: AppColors.textColor), // Updated label color
                hintStyle:
                    TextStyle(color: AppColors.textColor), // Updated hint color
                fillColor: Color(0xFF282828), // Updated background color
                filled: true,
              ),
              style: TextStyle(
                  color: AppColors
                      .textColor), // Set text color to AppColors.textColor
              dropdownColor: Color(
                  0xFF282828), // Match dropdown menu background to text field box
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  // Submit the finalization
                  print('''
                    Time: ${_selectedTime.hour}:${_selectedTime.minute} ${_isAM ? 'AM' : 'PM'}
                    Date: ${_selectedDate.day}-${_selectedDate.month}-${_selectedDate.year}
                    Seats: $_seats
                    AC: ${_acEnabled ? 'On' : 'Off'}
                    Preferred Gender: $_preferredGender
                    Amount: ${_isFree ? 'Free' : 'Rs $_amount'}
                    Payment Option: $_paymentOption
                  ''');
                },
                child: const Text(
                  'Confirm Ride',
                  style: TextStyle(
                    fontFamily: "Poppins",
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Set text color to white
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: ProgressBar(initialStep: 2),
    );
  }
}

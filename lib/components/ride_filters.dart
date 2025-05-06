import 'package:flutter/material.dart';
import 'colors.dart';

class RideFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;

  const RideFilters({
    super.key,
    required this.onApplyFilters,
  });

  @override
  State<RideFilters> createState() => _RideFiltersState();
}

class _RideFiltersState extends State<RideFilters> {
  // Filter state variables
  String selectedType = 'Car';
  int capacity = 4;
  bool hasAC = true;
  RangeValues amountRange = const RangeValues(0, 1000);
  String preferredGender = 'All';
  String paymentOption = 'Cash';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        children: [
          // Title section - stays fixed
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const Center(
                  child: Text(
                    'Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  height: 1,
                  color: Colors.grey[800],
                ),
              ],
            ),
          ),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    // Type Filter
                    const Text(
                      'Type',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildTypeOption('Car'),
                        const SizedBox(width: 12),
                        _buildTypeOption('Bike'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Capacity Filter
                    const Text(
                      'Capacity',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            if (capacity > 1) {
                              setState(() => capacity--);
                            }
                          },
                        ),
                        const SizedBox(width: 16),
                        Text(
                          '$capacity',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(width: 16),
                        IconButton(
                          icon: const Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() => capacity++);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // AC Filter
                    const Text(
                      'AC',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildACOption('Yes'),
                        const SizedBox(width: 12),
                        _buildACOption('No'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount Range Filter
                    const Text(
                      'Amount',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildAmountInput('Min'),
                        const SizedBox(width: 12),
                        const Text(
                          '~',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                        const SizedBox(width: 12),
                        _buildAmountInput('Max'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Preferred Gender Filter
                    const Text(
                      'Preferred Gender',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildGenderOption('Male'),
                        const SizedBox(width: 12),
                        _buildGenderOption('Female'),
                        const SizedBox(width: 12),
                        _buildGenderOption('All'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Payment Option Filter
                    const Text(
                      'Payment Option',
                      style: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPaymentOption('Cash'),
                        const SizedBox(width: 12),
                        _buildPaymentOption('Online'),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: const BorderSide(color: Colors.white),
                              ),
                            ),
                            child: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              widget.onApplyFilters({
                                'type': selectedType,
                                'capacity': capacity,
                                'hasAC': hasAC,
                                'amountRange': amountRange,
                                'preferredGender': preferredGender,
                                'paymentOption': paymentOption,
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2196F3),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text(
                              'OK',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeOption(String type) {
    final isSelected = selectedType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              type,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildACOption(String option) {
    final isSelected = (option == 'Yes' && hasAC) || (option == 'No' && !hasAC);
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => hasAC = option == 'Yes'),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAmountInput(String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.primaryGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFA4A4A4),
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender) {
    final isSelected = preferredGender == gender;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => preferredGender = gender),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              gender,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String option) {
    final isSelected = paymentOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => paymentOption = option),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              option,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'colors.dart';
import 'package:flutter/services.dart';

class ActiveFilter {
  final String type;
  final String value;

  ActiveFilter({required this.type, required this.value});
}

class ActiveFilters extends StatelessWidget {
  final List<ActiveFilter> filters;
  final Function(String type) onRemove;

  const ActiveFilters({
    super.key,
    required this.filters,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (filters.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: filters.map((filter) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primaryBlue),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${filter.type}: ${filter.value}',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontFamily: 'Poppins',
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => onRemove(filter.type),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class RideFilters extends StatefulWidget {
  final Function(Map<String, dynamic>) onApplyFilters;
  final Map<String, dynamic>? initialFilters;
  final VoidCallback onClose;

  const RideFilters({
    super.key,
    required this.onApplyFilters,
    required this.onClose,
    this.initialFilters,
  });

  @override
  State<RideFilters> createState() => _RideFiltersState();
}

class _RideFiltersState extends State<RideFilters> {
  // Filter state variables
  late String selectedType;
  late String capacityOption;
  late int? customCapacity;
  late String? acPreference;
  late bool isAmountFilterEnabled;
  late double? minAmount;
  late double? maxAmount;
  late String amountFilterType;
  late String costType;
  late String paymentOption;
  late DateTime? selectedDate;
  late TimeOfDay? selectedTime;

  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize with provided values or defaults
    selectedType = widget.initialFilters?['type'] ?? 'Any';
    capacityOption = widget.initialFilters?['capacityOption'] ?? 'Any';
    customCapacity = widget.initialFilters?['customCapacity'];
    acPreference = widget.initialFilters?['acPreference'] ?? 'Any';
    isAmountFilterEnabled =
        widget.initialFilters?['isAmountFilterEnabled'] ?? false;
    minAmount = widget.initialFilters?['minAmount'];
    maxAmount = widget.initialFilters?['maxAmount'];
    amountFilterType = widget.initialFilters?['amountFilterType'] ?? 'Any';
    costType = widget.initialFilters?['costType'] ?? 'Any';
    paymentOption = widget.initialFilters?['paymentOption'] ?? 'Any';
    selectedDate = widget.initialFilters?['date'];
    selectedTime = widget.initialFilters?['time'];

    if (customCapacity != null) {
      _capacityController.text = customCapacity.toString();
    }
    if (minAmount != null) {
      _minAmountController.text = minAmount.toString();
    }
    if (maxAmount != null) {
      _maxAmountController.text = maxAmount.toString();
    }
  }

  @override
  void dispose() {
    _capacityController.dispose();
    _minAmountController.dispose();
    _maxAmountController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      selectableDayPredicate: (DateTime date) {
        // Return false for past dates
        return date.isAfter(DateTime.now().subtract(const Duration(days: 1)));
      },
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.backgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.primaryGray,
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
        // If selected date is today, ensure time is not in the past
        if (picked.year == DateTime.now().year &&
            picked.month == DateTime.now().month &&
            picked.day == DateTime.now().day) {
          final now = TimeOfDay.now();
          if (selectedTime != null &&
              (selectedTime!.hour < now.hour ||
                  (selectedTime!.hour == now.hour &&
                      selectedTime!.minute < now.minute))) {
            selectedTime = null; // Reset time if it's in the past
          }
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    // Get current time
    final now = TimeOfDay.now();
    final isToday = selectedDate?.year == DateTime.now().year &&
        selectedDate?.month == DateTime.now().month &&
        selectedDate?.day == DateTime.now().day;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.dark(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.backgroundColor,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: AppColors.primaryGray,
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      // For today, validate that selected time is not in the past
      if (isToday) {
        if (picked.hour < now.hour ||
            (picked.hour == now.hour && picked.minute < now.minute)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a future time'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Add this method to validate numeric input
  String? _validateNumericInput(String? value) {
    if (value == null || value.isEmpty) return null;
    if (double.tryParse(value) == null) return 'Please enter a valid number';
    return null;
  }

  Widget _buildDateTimeFilter() {
    String dateText = selectedDate != null
        ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
        : 'Select Date';

    String timeText =
        selectedTime != null ? selectedTime!.format(context) : 'Select Time';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date & Time',
          style: TextStyle(
            color: Color(0xFFA4A4A4),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: selectedDate != null
                            ? AppColors.primaryBlue
                            : const Color(0xFFA4A4A4),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        dateText,
                        style: TextStyle(
                          color: selectedDate != null
                              ? Colors.white
                              : const Color(0xFFA4A4A4),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGray,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.access_time,
                        color: selectedTime != null
                            ? AppColors.primaryBlue
                            : const Color(0xFFA4A4A4),
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        timeText,
                        style: TextStyle(
                          color: selectedTime != null
                              ? Colors.white
                              : const Color(0xFFA4A4A4),
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
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

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          children: [
            _buildCapacityOption('Any'),
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primaryGray,
                  borderRadius: BorderRadius.circular(8),
                  border: capacityOption == 'Custom'
                      ? Border.all(color: AppColors.primaryBlue, width: 1)
                      : null,
                ),
                child: Center(
                  child: TextField(
                    controller: _capacityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 14,
                    ),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      border: InputBorder.none,
                      hintText: 'Enter number',
                      hintStyle: TextStyle(
                        color: Color(0xFFA4A4A4),
                        fontFamily: 'Poppins',
                        fontSize: 14,
                      ),
                    ),
                    onTap: () {
                      setState(() => capacityOption = 'Custom');
                    },
                    onChanged: (value) {
                      setState(() {
                        capacityOption = 'Custom';
                        if (value.isNotEmpty) {
                          final number = int.tryParse(value);
                          if (number != null && number > 0) {
                            customCapacity = number;
                          }
                        } else {
                          customCapacity = null;
                        }
                      });
                    },
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildACOption(String option) {
    final isSelected = acPreference == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          acPreference = option;
        }),
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

  Widget _buildAmountSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            _buildAmountOption('Any'),
            const SizedBox(width: 8),
            _buildAmountOption('Range'),
            const SizedBox(width: 8),
            _buildAmountOption('At Least'),
            const SizedBox(width: 8),
            _buildAmountOption('At Most'),
          ],
        ),
        if (amountFilterType != 'Any') ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (amountFilterType == 'Range') ...[
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGray,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primaryBlue, width: 1),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _minAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: 'Min',
                          prefixText: 'Rs. ',
                          prefixStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final newMin = double.tryParse(value);
                          setState(() {
                            minAmount = newMin;
                            if (newMin != null &&
                                maxAmount != null &&
                                newMin > maxAmount!) {
                              _maxAmountController.text = value;
                              maxAmount = newMin;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '~',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGray,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primaryBlue, width: 1),
                    ),
                    child: Center(
                      child: TextField(
                        controller: _maxAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: 'Max',
                          prefixText: 'Rs. ',
                          prefixStyle: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          hintStyle: TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final newMax = double.tryParse(value);
                          setState(() {
                            maxAmount = newMax;
                            if (newMax != null &&
                                minAmount != null &&
                                newMax < minAmount!) {
                              _minAmountController.text = value;
                              minAmount = newMax;
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ] else ...[
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryGray,
                      borderRadius: BorderRadius.circular(8),
                      border:
                          Border.all(color: AppColors.primaryBlue, width: 1),
                    ),
                    child: Center(
                      child: TextField(
                        controller: amountFilterType == 'At Least'
                            ? _minAmountController
                            : _maxAmountController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Poppins',
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          contentPadding:
                              const EdgeInsets.symmetric(horizontal: 12),
                          border: InputBorder.none,
                          hintText: amountFilterType == 'At Least'
                              ? 'Minimum amount'
                              : 'Maximum amount',
                          prefixText: 'Rs. ',
                          prefixStyle: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                          hintStyle: const TextStyle(
                            color: Color(0xFFA4A4A4),
                            fontFamily: 'Poppins',
                            fontSize: 14,
                          ),
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        onChanged: (value) {
                          final amount = double.tryParse(value);
                          setState(() {
                            if (amountFilterType == 'At Least') {
                              minAmount = amount;
                              maxAmount = null;
                              _maxAmountController.clear();
                            } else {
                              maxAmount = amount;
                              minAmount = null;
                              _minAmountController.clear();
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildAmountOption(String option) {
    final isSelected = amountFilterType == option;
    String displayValue = '';

    if (isSelected && option != 'Any') {
      switch (option) {
        case 'Range':
          if (minAmount != null && maxAmount != null) {
            displayValue =
                'Rs. ${minAmount!.toStringAsFixed(0)} - Rs. ${maxAmount!.toStringAsFixed(0)}';
          }
          break;
        case 'At Least':
          if (minAmount != null) {
            displayValue = '≥ Rs. ${minAmount!.toStringAsFixed(0)}';
          }
          break;
        case 'At Most':
          if (maxAmount != null) {
            displayValue = '≤ Rs. ${maxAmount!.toStringAsFixed(0)}';
          }
          break;
      }
    }

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (amountFilterType == option) {
              amountFilterType = 'Any';
              _minAmountController.clear();
              _maxAmountController.clear();
              minAmount = null;
              maxAmount = null;
            } else {
              amountFilterType = option;
            }
          });
        },
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              displayValue.isNotEmpty ? displayValue : option,
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

  Widget _buildCostTypeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cost Type',
          style: TextStyle(
            color: Color(0xFFA4A4A4),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildCostTypeOption('Any'),
            const SizedBox(width: 12),
            _buildCostTypeOption('Free'),
            const SizedBox(width: 12),
            _buildCostTypeOption('Paid'),
          ],
        ),
      ],
    );
  }

  Widget _buildCostTypeOption(String option) {
    final isSelected = costType == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => costType = option),
        child: Container(
          height: 48,
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

  Widget _buildCapacityOption(String option) {
    final isSelected = capacityOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          if (option == 'Any') {
            capacityOption = 'Any';
            customCapacity = null;
            _capacityController.clear();
          }
        }),
        child: Container(
          height: 48,
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

  Map<String, dynamic> _getActiveFilters() {
    final Map<String, dynamic> activeFilters = {};

    // Type filter
    if (selectedType != 'Any') {
      activeFilters['type'] = selectedType;
    }

    // Capacity filter
    if (capacityOption != 'Any') {
      activeFilters['capacityOption'] = capacityOption;
      if (customCapacity != null) {
        activeFilters['customCapacity'] = customCapacity;
      }
    }

    // AC filter
    if (acPreference != 'Any') {
      activeFilters['acPreference'] = acPreference;
    }

    // Amount filter
    if (amountFilterType != 'Any') {
      activeFilters['amountFilterType'] = amountFilterType;
      if (minAmount != null) {
        activeFilters['minAmount'] = minAmount;
      }
      if (maxAmount != null) {
        activeFilters['maxAmount'] = maxAmount;
      }
    }

    // Cost type filter
    if (costType != 'Any') {
      activeFilters['costType'] = costType;
    }

    // Payment option filter
    if (paymentOption != 'Any') {
      activeFilters['paymentOption'] = paymentOption;
    }

    // Date and time filters
    if (selectedDate != null) {
      activeFilters['date'] = selectedDate;
    }
    if (selectedTime != null) {
      activeFilters['time'] = selectedTime;
    }

    return activeFilters;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  List<ActiveFilter> _getActiveFilterBubbles() {
    final List<ActiveFilter> filters = [];

    if (selectedType != 'Any') {
      filters.add(ActiveFilter(type: 'Type', value: selectedType));
    }

    if (capacityOption != 'Any') {
      filters.add(ActiveFilter(
        type: 'Capacity',
        value: customCapacity?.toString() ?? capacityOption,
      ));
    }

    if (acPreference != 'Any') {
      filters.add(ActiveFilter(type: 'AC', value: acPreference!));
    }

    if (amountFilterType != 'Any') {
      String value = '';
      switch (amountFilterType) {
        case 'Range':
          if (minAmount != null && maxAmount != null) {
            value =
                '\$${minAmount!.toStringAsFixed(0)} - \$${maxAmount!.toStringAsFixed(0)}';
          }
          break;
        case 'At Least':
          if (minAmount != null) {
            value = '≥ \$${minAmount!.toStringAsFixed(0)}';
          }
          break;
        case 'At Most':
          if (maxAmount != null) {
            value = '≤ \$${maxAmount!.toStringAsFixed(0)}';
          }
          break;
      }
      if (value.isNotEmpty) {
        filters.add(ActiveFilter(type: 'Amount', value: value));
      }
    }

    if (costType != 'Any') {
      filters.add(ActiveFilter(type: 'Cost', value: costType));
    }

    if (paymentOption != 'Any') {
      filters.add(ActiveFilter(type: 'Payment', value: paymentOption));
    }

    if (selectedDate != null) {
      filters.add(ActiveFilter(
        type: 'Date',
        value:
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
      ));
    }

    if (selectedTime != null) {
      filters.add(ActiveFilter(
        type: 'Time',
        value: _formatTimeOfDay(selectedTime!),
      ));
    }

    return filters;
  }

  void _removeFilter(String type) {
    setState(() {
      switch (type) {
        case 'Type':
          selectedType = 'Any';
          break;
        case 'Capacity':
          capacityOption = 'Any';
          customCapacity = null;
          _capacityController.clear();
          break;
        case 'AC':
          acPreference = 'Any';
          break;
        case 'Amount':
          amountFilterType = 'Any';
          minAmount = null;
          maxAmount = null;
          _minAmountController.clear();
          _maxAmountController.clear();
          break;
        case 'Cost':
          costType = 'Any';
          break;
        case 'Payment':
          paymentOption = 'Any';
          break;
        case 'Date':
          selectedDate = null;
          break;
        case 'Time':
          selectedTime = null;
          break;
      }
    });

    // Update filters
    widget.onApplyFilters(_getActiveFilters());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.75,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title section - stays fixed
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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

          // Active Filters
          ActiveFilters(
            filters: _getActiveFilterBubbles(),
            onRemove: _removeFilter,
          ),

          // Scrollable content
          Flexible(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),

                    // Date & Time Filter
                    _buildDateTimeFilter(),
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
                        _buildTypeOption('Any'),
                        const SizedBox(width: 12),
                        _buildTypeOption('Car'),
                        const SizedBox(width: 12),
                        _buildTypeOption('Bike'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Capacity Filter
                    _buildCapacitySection(),
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
                        _buildACOption('Any'),
                        const SizedBox(width: 12),
                        _buildACOption('Yes'),
                        const SizedBox(width: 12),
                        _buildACOption('No'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Amount Filter
                    _buildAmountSection(),
                    const SizedBox(height: 24),

                    // Cost Type Filter
                    _buildCostTypeSection(),
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
                        _buildPaymentOption('Any'),
                        const SizedBox(width: 12),
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
                              // Reset all filters to default
                              setState(() {
                                selectedType = 'Any';
                                capacityOption = 'Any';
                                customCapacity = null;
                                acPreference = 'Any';
                                amountFilterType = 'Any';
                                minAmount = null;
                                maxAmount = null;
                                costType = 'Any';
                                paymentOption = 'Any';
                                selectedDate = null;
                                selectedTime = null;
                                _capacityController.clear();
                                _minAmountController.clear();
                                _maxAmountController.clear();
                              });
                              widget.onApplyFilters({});
                              widget.onClose();
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
                              widget.onApplyFilters(_getActiveFilters());
                              widget.onClose();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
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
}

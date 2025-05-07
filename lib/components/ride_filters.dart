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
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.8 -
                    44, // Account for padding and spacing
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Flexible(
                    child: Text(
                      '${filter.type}: ${filter.value}',
                      style: const TextStyle(
                        color: AppColors.primaryBlue,
                        fontFamily: 'Poppins',
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
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
  late String capacityValue;
  late String genderPreference;
  late String amountFilterType;
  double? minAmount;
  double? maxAmount;
  late String paymentOption;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  late String sortOption;

  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _minAmountController = TextEditingController();
  final TextEditingController _maxAmountController = TextEditingController();

  // Sorting options
  final Map<String, String> sortOptions = {
    'Newest First': '-date',
    'Oldest First': 'date',
    'Time: Early to Late': 'time',
    'Time: Late to Early': '-time',
    'Price: Low to High': 'amount',
    'Price: High to Low': '-amount',
  };

  // Add activeFilters state variable
  List<ActiveFilter> activeFilters = [];

  @override
  void initState() {
    super.initState();
    _initializeState();
  }

  void _initializeState() {
    // Initialize with provided values or defaults
    selectedType = widget.initialFilters?['vehicle_type'] ?? 'Any';
    capacityValue = widget.initialFilters?['min_seats']?.toString() ?? '';
    genderPreference = widget.initialFilters?['preferred_gender'] ?? 'Any';
    paymentOption = widget.initialFilters?['payment_option'] ?? 'Any';
    sortOption = widget.initialFilters?['ordering'] ?? '-date';

    // Initialize amount filter type and values
    minAmount = widget.initialFilters?['min_amount'];
    maxAmount = widget.initialFilters?['max_amount'];
    if (minAmount != null || maxAmount != null) {
      if (minAmount != null && maxAmount != null) {
        amountFilterType = 'Range';
        _minAmountController.text = minAmount!.toString();
        _maxAmountController.text = maxAmount!.toString();
      } else if (minAmount != null) {
        amountFilterType = 'At Least';
        _minAmountController.text = minAmount!.toString();
      } else if (maxAmount != null) {
        amountFilterType = 'At Most';
        _maxAmountController.text = maxAmount!.toString();
      }
    } else {
      amountFilterType = 'Any';
    }

    // Initialize capacity controller if value exists
    if (capacityValue.isNotEmpty) {
      _capacityController.text = capacityValue;
    }

    // Handle date and time
    if (widget.initialFilters?['date_after'] != null) {
      try {
        selectedDate = DateTime.parse(widget.initialFilters!['date_after']);
      } catch (e) {
        selectedDate = null;
      }
    }

    if (widget.initialFilters?['time_after'] != null) {
      try {
        final timeStr = widget.initialFilters!['time_after'];
        final parts = timeStr.split(':');
        if (parts.length >= 2) {
          selectedTime = TimeOfDay(
            hour: int.parse(parts[0]),
            minute: int.parse(parts[1]),
          );
        }
      } catch (e) {
        selectedTime = null;
      }
    }

    // Initialize active filters
    _updateActiveFilters();
  }

  void _updateActiveFilters() {
    setState(() {
      activeFilters = _getActiveFilterBubbles();
    });
  }

  List<ActiveFilter> _getActiveFilterBubbles() {
    final List<ActiveFilter> filters = [];

    // Vehicle Type filter
    if (selectedType != 'Any') {
      filters.add(ActiveFilter(
        type: 'Vehicle',
        value: selectedType,
      ));
    }

    // Minimum Seats filter
    if (capacityValue.isNotEmpty) {
      filters.add(ActiveFilter(
        type: 'Seats',
        value: '≥ $capacityValue',
      ));
    }

    // Gender Preference filter
    if (genderPreference != 'Any') {
      filters.add(ActiveFilter(
        type: 'Gender',
        value: genderPreference,
      ));
    }

    // Amount Range filters
    if (amountFilterType != 'Any') {
      String value = '';
      if (minAmount != null && maxAmount != null) {
        value =
            'Rs. ${minAmount!.toStringAsFixed(0)} - ${maxAmount!.toStringAsFixed(0)}';
      } else if (minAmount != null) {
        value = '≥ Rs. ${minAmount!.toStringAsFixed(0)}';
      } else if (maxAmount != null) {
        value = '≤ Rs. ${maxAmount!.toStringAsFixed(0)}';
      }
      if (value.isNotEmpty) {
        filters.add(ActiveFilter(type: 'Amount', value: value));
      }
    }

    // Payment Option filter
    if (paymentOption != 'Any') {
      filters.add(ActiveFilter(
        type: 'Payment',
        value: paymentOption,
      ));
    }

    // Date filter
    if (selectedDate != null) {
      filters.add(ActiveFilter(
        type: 'Date',
        value:
            '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
      ));
    }

    // Time filter
    if (selectedTime != null) {
      filters.add(ActiveFilter(
        type: 'Time',
        value: selectedTime!.format(context),
      ));
    }

    // Sort filter
    if (sortOption != '-date') {
      String sortValue = '';
      switch (sortOption) {
        case '-date':
          sortValue = 'Newest First';
          break;
        case 'date':
          sortValue = 'Oldest First';
          break;
        case 'time':
          sortValue = 'Early to Late';
          break;
        case '-time':
          sortValue = 'Late to Early';
          break;
        case 'amount':
          sortValue = 'Price: Low to High';
          break;
        case '-amount':
          sortValue = 'Price: High to Low';
          break;
      }
      if (sortValue.isNotEmpty) {
        filters.add(ActiveFilter(type: 'Sort', value: sortValue));
      }
    }

    return filters;
  }

  void _removeFilter(String type) {
    setState(() {
      switch (type) {
        case 'Vehicle':
          selectedType = 'Any';
          break;
        case 'Seats':
          capacityValue = '';
          _capacityController.clear();
          break;
        case 'Gender':
          genderPreference = 'Any';
          break;
        case 'Amount':
          amountFilterType = 'Any';
          minAmount = null;
          maxAmount = null;
          _minAmountController.clear();
          _maxAmountController.clear();
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
        case 'Sort':
          sortOption = '-date';
          break;
      }
      _updateActiveFilters();
    });
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
    _updateActiveFilters();
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
    _updateActiveFilters();
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

  Widget _buildTypeOption(String option) {
    final isSelected = selectedType == option;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedType = option;
            _updateActiveFilters();
          });
        },
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

  Widget _buildCapacitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Minimum Seats',
          style: TextStyle(
            color: Color(0xFFA4A4A4),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryBlue, width: 1),
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
                hintText: 'Enter minimum seats required',
                hintStyle: TextStyle(
                  color: Color(0xFFA4A4A4),
                  fontFamily: 'Poppins',
                  fontSize: 14,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  capacityValue = value;
                });
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderPreferenceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender Preference',
          style: TextStyle(
            color: Color(0xFFA4A4A4),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _buildGenderOption('Any'),
            const SizedBox(width: 12),
            _buildGenderOption('Male'),
            const SizedBox(width: 12),
            _buildGenderOption('Female'),
          ],
        ),
      ],
    );
  }

  Widget _buildGenderOption(String option) {
    final isSelected = genderPreference == option;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            genderPreference = option;
            _updateActiveFilters();
          });
        },
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

  Widget _buildSortingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sort By',
          style: TextStyle(
            color: Color(0xFFA4A4A4),
            fontFamily: 'Poppins',
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.primaryGray,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.primaryBlue, width: 1),
          ),
          child: DropdownButton<String>(
            value: sortOptions.entries
                .firstWhere((e) => e.value == sortOption)
                .key,
            isExpanded: true,
            dropdownColor: AppColors.primaryGray,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
            underline: const SizedBox(),
            items: sortOptions.keys.map((String key) {
              return DropdownMenuItem<String>(
                value: key,
                child: Text(key),
              );
            }).toList(),
            onChanged: (String? newValue) {
              if (newValue != null) {
                setState(() {
                  sortOption = sortOptions[newValue]!;
                });
              }
            },
          ),
        ),
      ],
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

  Widget _buildPaymentOption(String option) {
    final isSelected = paymentOption == option;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            paymentOption = option;
            _updateActiveFilters();
          });
        },
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

  Map<String, dynamic> _getActiveFilters() {
    final Map<String, dynamic> activeFilters = {};

    // Type filter
    if (selectedType != 'Any') {
      activeFilters['vehicle_type'] = selectedType;
    }

    // Capacity filter
    if (capacityValue.isNotEmpty) {
      activeFilters['min_seats'] = int.parse(capacityValue);
    }

    // Gender preference filter
    if (genderPreference != 'Any') {
      activeFilters['preferred_gender'] = genderPreference;
    }

    // Amount filter
    if (amountFilterType != 'Any') {
      if (minAmount != null) {
        activeFilters['min_amount'] = minAmount;
      }
      if (maxAmount != null) {
        activeFilters['max_amount'] = maxAmount;
      }
    }

    // Payment option filter
    if (paymentOption != 'Any') {
      activeFilters['payment_option'] = paymentOption;
    }

    // Date and time filters
    if (selectedDate != null) {
      activeFilters['date_after'] =
          '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
    }
    if (selectedTime != null) {
      activeFilters['time_after'] =
          '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}:00';
    }

    // Sorting
    if (sortOption != '-date') {
      // Only add if not default
      activeFilters['ordering'] = sortOption;
    }

    return activeFilters;
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
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
          if (activeFilters.isNotEmpty)
            ActiveFilters(
              filters: activeFilters,
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

                    // Sorting Section (New)
                    _buildSortingSection(),
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

                    // Capacity Filter (Modified)
                    _buildCapacitySection(),
                    const SizedBox(height: 24),

                    // Gender Preference Filter (New)
                    _buildGenderPreferenceSection(),
                    const SizedBox(height: 24),

                    // Amount Filter
                    _buildAmountSection(),
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
                                capacityValue = '';
                                genderPreference = 'Any';
                                amountFilterType = 'Any';
                                minAmount = null;
                                maxAmount = null;
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

import 'package:fastpool_fe/components/colors.dart';
import 'package:flutter/material.dart';

class ProgressBar extends StatefulWidget {
  final int initialStep; // Initial step index
  const ProgressBar({super.key, required this.initialStep});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

class _ProgressBarState extends State<ProgressBar> {
  int _currentStep = 0; // Current step index

  @override
  void initState() {
    super.initState();
    _currentStep = widget.initialStep; // Set current index to initial index
  }

  @override
  Widget build(BuildContext context) {
    print('Current Step: $_currentStep'); // Debugging line
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
      decoration: BoxDecoration(
        color: Colors.transparent,
        boxShadow: [
          BoxShadow(
            color: AppColors.backgroundColor,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(0, 'Start'),
          _buildConnector(0),
          _buildStep(1, 'Vehicle'),
          _buildConnector(1),
          _buildStep(2, 'Confirm'),
        ],
      ),
    );
  }

  Widget _buildStep(int stepIndex, String label) {
    bool isPast = stepIndex < _currentStep;
    bool isCurrent = stepIndex == _currentStep;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isPast
                ? Colors.blue
                : (isCurrent ? Colors.blue : Colors.grey[300]),
            border: isCurrent
                ? Border.all(color: Colors.blue.shade700, width: 2)
                : null,
          ),
          child: isPast
              ? const Icon(Icons.check, size: 16, color: Colors.white)
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: isPast || isCurrent ? Colors.blue : Colors.grey,
            fontSize: 12,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector(int stepIndex) {
    bool isCompleted = stepIndex < _currentStep;

    return Expanded(
      child: Container(
        height: 2,
        color: isCompleted ? Colors.blue : Colors.grey[300],
      ),
    );
  }
}

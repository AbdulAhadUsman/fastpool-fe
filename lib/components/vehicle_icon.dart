import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/colors.dart';

class VehicleIcon extends StatelessWidget {
  final String vehicleType;
  final double size;

  const VehicleIcon({
    super.key,
    required this.vehicleType,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which icon to show based on vehicle type
    IconData iconData = vehicleType.toLowerCase().contains('bike')
        ? Icons.motorcycle
        : Icons.directions_car;

    return Icon(
      iconData,
      size: size,
      color: AppColors.primaryBlue,
    );
  }
}

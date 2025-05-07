import 'package:flutter/material.dart';
import '../models/past_trip.dart';
import 'package:intl/intl.dart';
import 'shimmer_loading.dart';

class PastTripCard extends StatelessWidget {
  final PastTrip trip;

  const PastTripCard({super.key, required this.trip});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xff1E1C1F),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLocationRow(
              Icons.radio_button_checked,
              trip.isLoadingAddresses
                  ? const ShimmerLoading(width: 200, height: 16)
                  : Text(
                      trip.sourceAddress ?? 'Unknown location',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
              iconColor: const Color(0xFFA4A4A4),
            ),
            const SizedBox(height: 8),
            _buildLocationRow(
              Icons.location_on,
              trip.isLoadingAddresses
                  ? const ShimmerLoading(width: 200, height: 16)
                  : Text(
                      trip.destinationAddress ?? 'Unknown location',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                        fontSize: 13,
                      ),
                    ),
              iconColor: const Color(0xFFA4A4A4),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Color(0xFF007AFF),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('MMM d, h:mm a').format(trip.dateTime),
                    style: const TextStyle(
                      color: Color(0xFF007AFF),
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationRow(IconData icon, Widget content, {Color? iconColor}) {
    return Row(
      children: [
        Icon(
          icon,
          color: iconColor ?? Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(child: content),
      ],
    );
  }
}

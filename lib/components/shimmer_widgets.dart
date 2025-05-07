import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:fastpool_fe/components/colors.dart';

class ShimmerContainer extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerContainer({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFF2C2C2C),
      highlightColor: const Color(0xFF3D3D3D),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class WelcomeCardShimmer extends StatelessWidget {
  const WelcomeCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const ShimmerContainer(
              width: 48,
              height: 48,
              borderRadius: 24,
            ),
            const SizedBox(width: 12),
            ShimmerContainer(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}

class StatCardShimmer extends StatelessWidget {
  const StatCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            ShimmerContainer(width: 24, height: 24),
            SizedBox(height: 2),
            ShimmerContainer(width: 80, height: 14),
            SizedBox(height: 4),
            ShimmerContainer(width: 40, height: 26),
          ],
        ),
      ),
    );
  }
}

class UpcomingRideShimmer extends StatelessWidget {
  const UpcomingRideShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: List.generate(
            6,
            (index) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  ShimmerContainer(
                    width: 130,
                    height: 14,
                  ),
                  const SizedBox(width: 10),
                  ShimmerContainer(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: 14,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RideCardShimmer extends StatelessWidget {
  const RideCardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF282828),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Left section with vehicle icon and price
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                ShimmerContainer(
                  width: 40,
                  height: 40,
                  borderRadius: 8,
                ),
                SizedBox(height: 8),
                ShimmerContainer(
                  width: 50,
                  height: 14,
                ),
              ],
            ),
            // Vertical divider
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 1,
              height: 60,
              color: const Color(0xFF404040),
            ),
            // Right section with addresses
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const ShimmerContainer(
                        width: 20,
                        height: 20,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShimmerContainer(
                          width: double.infinity,
                          height: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const ShimmerContainer(
                        width: 20,
                        height: 20,
                        borderRadius: 10,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ShimmerContainer(
                          width: double.infinity,
                          height: 14,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Shimmer for dropdown arrow
            const Padding(
              padding: EdgeInsets.only(left: 8),
              child: ShimmerContainer(
                width: 24,
                height: 24,
                borderRadius: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

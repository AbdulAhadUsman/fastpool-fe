import 'package:flutter/material.dart';
import '../models/ride.dart';
import '../components/colors.dart';

class RideDetailsPage extends StatelessWidget {
  final Ride ride;

  const RideDetailsPage({
    super.key,
    required this.ride,
  });

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF282828),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(16),
          child: content,
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: Color(0xFFA4A4A4),
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImage(String imageUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        image: DecorationImage(
          image: NetworkImage(imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Ride Details',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Driver Section
            _buildSection(
              'Driver Information',
              Column(
                children: [
                  Row(
                    children: [
                      _buildProfileImage(ride.driver.profilePicUrl),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ride.driver.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'Poppins',
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  ride.driver.rating.toString(),
                                  style: const TextStyle(
                                    color: Colors.amber,
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInfoRow('Email', ride.driver.email),
                  _buildInfoRow('Contact', ride.driver.contactNumber),
                ],
              ),
            ),

            // Vehicle Section
            _buildSection(
              'Vehicle Information',
              Column(
                children: [
                  _buildInfoRow('Model', ride.vehicle.model),
                  _buildInfoRow('Number', ride.vehicle.number),
                  _buildInfoRow('Type', ride.vehicle.type.toUpperCase()),
                  _buildInfoRow('AC', ride.vehicle.hasAC ? 'Yes' : 'No'),
                  _buildInfoRow('Total Seats', '${ride.availableSeats}'),
                  _buildInfoRow('Available Seats', '${ride.unbookedSeats}'),
                ],
              ),
            ),

            // Ride Details Section
            _buildSection(
              'Ride Details',
              Column(
                children: [
                  _buildInfoRow('Pickup', ride.pickup),
                  _buildInfoRow('Destination', ride.destination),
                  _buildInfoRow(
                    'Time',
                    '${ride.time.hour}:${ride.time.minute.toString().padLeft(2, '0')}',
                  ),
                  _buildInfoRow('Duration', '${ride.duration} mins'),
                  _buildInfoRow('Distance', '${ride.distance} km'),
                  _buildInfoRow('Amount', 'Rs ${ride.amount}'),
                  _buildInfoRow('Payment Method', ride.paymentOption),
                  _buildInfoRow('Preferred Gender', ride.preferredGender),
                ],
              ),
            ),

            // Book Ride Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement booking functionality
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Book Ride',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

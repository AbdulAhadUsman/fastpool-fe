import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';
import 'package:fastpool_fe/services/api_client.dart';
import '../helper-functions/reverseGeoLoc.dart';
import '../pages/route_map_view.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RiderPendingRequestsPage extends StatefulWidget {
  const RiderPendingRequestsPage({super.key});

  @override
  State<RiderPendingRequestsPage> createState() =>
      _RiderPendingRequestsPageState();
}

class _RiderPendingRequestsPageState extends State<RiderPendingRequestsPage> {
  bool isLoading = true;
  List<Map<String, dynamic>> pendingRequests = [];
  String? errorMessage;
  Set<int> expandedCards = {};
  final ApiClient _apiClient = ApiClient();
  Map<int, bool> cancellingRequests =
      {}; // Track cancellation state for each request

  @override
  void initState() {
    super.initState();
    _fetchRequests();
  }

  Future<void> _fetchRequests() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });

      final requests = await _apiClient.fetchRiderRequests();

      // Fetch addresses for each request
      for (var request in requests) {
        try {
          if (request['pickup_lat'] != null && request['pickup_lng'] != null) {
            request['pickup_address'] = await getAddressFromLatLng(
              request['pickup_lat'],
              request['pickup_lng'],
            );
          }

          if (request['ride_details'] != null) {
            if (request['ride_details']['source_lat'] != null &&
                request['ride_details']['source_lng'] != null) {
              request['ride_details']['source_address'] =
                  await getAddressFromLatLng(
                request['ride_details']['source_lat'],
                request['ride_details']['source_lng'],
              );
            }

            if (request['ride_details']['destination_lat'] != null &&
                request['ride_details']['destination_lng'] != null) {
              request['ride_details']['destination_address'] =
                  await getAddressFromLatLng(
                request['ride_details']['destination_lat'],
                request['ride_details']['destination_lng'],
              );
            }
          }
        } catch (e) {
          print('Error fetching address for request ${request['id']}: $e');
          // Continue with next request even if this one fails
          continue;
        }
      }

      setState(() {
        pendingRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load requests: $e';
        isLoading = false;
      });
    }
  }

  String _formatTime(String time) {
    final parts = time.split(':');
    if (parts.length < 2) return time;

    int hour = int.parse(parts[0]);
    final minute = parts[1];
    final period = hour >= 12 ? 'PM' : 'AM';

    if (hour > 12) {
      hour -= 12;
    } else if (hour == 0) {
      hour = 12;
    }

    return '$hour:$minute $period';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _handleCancelRequest(Map<String, dynamic> request) async {
    // Show confirmation dialog
    final bool? shouldCancel = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF2C2C2C),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: const Text(
            'Cancel Request',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Poppins',
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Are you sure you want to cancel this ride request?',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Poppins',
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                'No',
                style: TextStyle(
                  color: Colors.white70,
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text(
                'Yes, Cancel',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldCancel != true) return;

    // Start cancellation process
    setState(() {
      cancellingRequests[request['id']] = true;
    });

    try {
      await _apiClient.cancelRideRequest(request['id']);

      setState(() {
        // Remove the request from the list
        pendingRequests.removeWhere((r) => r['id'] == request['id']);
        // Remove from cancelling state
        cancellingRequests.remove(request['id']);
        // Remove from expanded cards if it was expanded
        expandedCards.remove(request['id']);
      });
    } catch (e) {
      setState(() {
        cancellingRequests.remove(request['id']);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to cancel request: ${e.toString()}',
              style: const TextStyle(
                fontFamily: 'Poppins',
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Update the button in the card to show loading state
  Widget _buildCancelButton(Map<String, dynamic> request) {
    final bool isCancelling = cancellingRequests[request['id']] ?? false;

    return ElevatedButton(
      onPressed: isCancelling ? null : () => _handleCancelRequest(request),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCC0000),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: isCancelling
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Text(
              'Cancel Request',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Text(
                    'Pending Requests',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 1,
                color: Colors.grey[800],
              ),
              const SizedBox(height: 20),
              if (isLoading)
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryBlue,
                    ),
                  ),
                )
              else if (errorMessage != null)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _fetchRequests,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryBlue,
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              else if (pendingRequests.isEmpty)
                const Expanded(
                  child: Center(
                    child: Text(
                      'No pending requests found',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Poppins',
                        fontSize: 16,
                      ),
                    ),
                  ),
                )
              else
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _fetchRequests,
                    color: AppColors.primaryBlue,
                    backgroundColor: AppColors.backgroundColor,
                    child: ListView.builder(
                      itemCount: pendingRequests.length,
                      itemBuilder: (context, index) {
                        final request = pendingRequests[index];
                        final isExpanded =
                            expandedCards.contains(request['id']);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: const Color(0xFF2C2C2C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                if (isExpanded) {
                                  expandedCards.remove(request['id']);
                                } else {
                                  expandedCards.add(request['id']);
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color:
                                              _getStatusColor(request['status'])
                                                  .withOpacity(0.2),
                                          borderRadius:
                                              BorderRadius.circular(16),
                                        ),
                                        child: Text(
                                          request['status'].toUpperCase(),
                                          style: TextStyle(
                                            color: _getStatusColor(
                                                request['status']),
                                            fontFamily: 'Poppins',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  _buildInfoRow(
                                    'Pickup At',
                                    request['pickup_address'] ??
                                        'Address not available',
                                  ),
                                  _buildInfoRow(
                                    'Time',
                                    _formatTime(request['pickup_time']),
                                  ),
                                  if (isExpanded) ...[
                                    _buildInfoRow(
                                      'Ride Information',
                                      '',
                                      isHeader: true,
                                    ),
                                    _buildInfoRow(
                                      'From',
                                      request['ride_details']
                                              ?['source_address'] ??
                                          'Address not available',
                                    ),
                                    _buildInfoRow(
                                      'To',
                                      request['ride_details']
                                              ?['destination_address'] ??
                                          'Address not available',
                                    ),
                                    _buildInfoRow(
                                      'Departure',
                                      _formatTime(request['ride_details']
                                              ?['time'] ??
                                          ''),
                                    ),
                                    _buildInfoRow(
                                      'Date',
                                      request['ride_details']?['date'] ??
                                          'Date not available',
                                    ),
                                    _buildInfoRow(
                                      'Fare',
                                      request['ride_details']?['amount'] != null
                                          ? 'Rs. ${request['ride_details']!['amount']}'
                                          : 'Amount not available',
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton(
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      RouteMapView(
                                                    pickupLocation: LatLng(
                                                      request['ride_details']
                                                          ['source_lat'],
                                                      request['ride_details']
                                                          ['source_lng'],
                                                    ),
                                                    destinationLocation: LatLng(
                                                      request['ride_details']
                                                          ['destination_lat'],
                                                      request['ride_details']
                                                          ['destination_lng'],
                                                    ),
                                                    pickupAddress: request[
                                                                'ride_details'][
                                                            'source_address'] ??
                                                        'Source Location',
                                                    destinationAddress: request[
                                                                'ride_details'][
                                                            'destination_address'] ??
                                                        'Destination Location',
                                                    requestPickupLocation:
                                                        LatLng(
                                                      request['pickup_lat'],
                                                      request['pickup_lng'],
                                                    ),
                                                    requestPickupAddress:
                                                        request[
                                                            'pickup_address'],
                                                  ),
                                                ),
                                              );
                                            },
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  AppColors.primaryBlue,
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 10),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                            ),
                                            child: const Text(
                                              'View on Map',
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 13,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  if (request['status'] == 'pending') ...[
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildCancelButton(request),
                                        ),
                                      ],
                                    ),
                                  ],
                                  const SizedBox(height: 4),
                                  Center(
                                    child: Icon(
                                      isExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: AppColors.primaryBlue,
                                      size: 20,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 2),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHeader = false}) {
    if (isHeader) {
      return Column(
        children: [
          const SizedBox(height: 4),
          Container(
            height: 1,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              label,
              style: TextStyle(
                color: AppColors.primaryBlue,
                fontFamily: 'Poppins',
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            height: 1,
            color: Colors.grey[800],
          ),
          const SizedBox(height: 4),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white54,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontFamily: 'Poppins',
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fastpool_fe/context/AuthContext.dart';
import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/colors.dart';
import 'package:fastpool_fe/components/DriverNavBar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Rider {
  final String username;
  final String email;
  final String gender;
  final String phone;
  final String profilePic;
  final double riderRating;

  Rider({
    required this.username,
    required this.email,
    required this.gender,
    required this.phone,
    required this.profilePic,
    required this.riderRating,
  });
}

class Request {
  final int id;
  final int rideId; // Added ride_id attribute
  final String pickup;
  final String pickupTime;
  String status;
  final Rider rider;

  Request({
    required this.id,
    required this.rideId, // Added ride_id to constructor
    required this.pickup,
    required this.pickupTime,
    required this.status,
    required this.rider,
  });
}

class DriverRideRequests extends StatefulWidget {
  const DriverRideRequests({Key? key}) : super(key: key);

  @override
  State<DriverRideRequests> createState() => _DriverRideRequestsState();
}

class _DriverRideRequestsState extends State<DriverRideRequests> {
  bool isLoading = true;
  List<Request> requests = [];

  @override
  void initState() {
    super.initState();
    fetchRequests();
  }

  Future<void> fetchRequests() async {
    setState(() {
      isLoading = true;
    });

    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final token = AuthContext.getToken();

    if (token == null || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Authentication token or BASE_URL is missing.')),
      );
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/ride/requests/?role=driver'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final results = data['results'] ?? [];

        if (results.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No requests available.')),
          );
        } else {
          List<Request> tempRequests = [];
          for (var req in results) {
            final riderData = req['rider'];
            final rider = Rider(
              username: riderData['username'] ?? 'Unknown',
              email: riderData['email'] ?? 'Unknown',
              gender: riderData['gender'] ?? 'Unknown',
              phone: riderData['phone'] ?? 'Unknown',
              profilePic: riderData['profile_pic'] ?? '',
              riderRating: (riderData['rider_rating'] ?? 0).toDouble(),
            );

            tempRequests.add(Request(
              id: req['id'] ?? 0,
              rideId: req['ride'] ?? 0, // Added ride_id
              pickup: req['pickup'] ?? 'Unknown',
              pickupTime: req['pickup_time'] ?? 'Unknown',
              status: req['status'] ?? 'Unknown',
              rider: rider,
            ));
          }

          setState(() {
            requests = tempRequests;
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text('Failed to fetch requests: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundColor,
        elevation: 0,
        title: const Text(
          'Ride Requests',
          style: TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.blue),
            )
          : RefreshIndicator(
              onRefresh: fetchRequests, // Add pull-to-refresh functionality
              child: requests.isEmpty
                  ? const Center(
                      child: Text(
                        'No requests available',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: requests.length,
                      itemBuilder: (context, index) {
                        final request = requests[index];
                        return RideRequestCard(request: request);
                      },
                    ),
            ),
      bottomNavigationBar: DriverNavbar(initialIndex: 3),
    );
  }
}

class RideRequestCard extends StatefulWidget {
  final Request request;

  const RideRequestCard({Key? key, required this.request}) : super(key: key);

  @override
  State<RideRequestCard> createState() => _RideRequestCardState();
}

class _RideRequestCardState extends State<RideRequestCard> {
  bool isExpanded = false;

  Future<void> handleRequest(String endpoint) async {
    final baseUrl = dotenv.env['BASE_URL'] ?? '';
    final token = AuthContext.getToken();

    if (token == null || baseUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Authentication token or BASE_URL is missing.')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/ride/requests/$endpoint/'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'id': widget.request.id}),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Request ${endpoint == 'accept' ? 'accepted' : 'declined'} successfully.')),
        );

        setState(() {
          widget.request.status =
              endpoint == 'accept' ? 'Accepted' : 'Declined'; // Update status
          isExpanded = false; // Shrink the card
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Failed to ${endpoint == 'accept' ? 'accept' : 'decline'} request: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: widget.request.status.toLowerCase() == 'pending'
                  ? () {
                      setState(() {
                        isExpanded = !isExpanded;
                      });
                    }
                  : null, // Disable tap if status is not "Pending"
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Name: ${widget.request.rider.username}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Email: ${widget.request.rider.email}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pickup: ${widget.request.pickup}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pickup Time: ${widget.request.pickupTime}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Status: ${widget.request.status}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),
            if (isExpanded) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => handleRequest('accept'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Accept',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => handleRequest('deny'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Decline',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:fastpool_fe/components/RiderNavBar.dart';
import '../models/past_trip.dart';
import '../components/past_trip_card.dart';
import '../services/api_client.dart';
import '../components/shimmer_loading.dart';

class RiderTripsPage extends StatefulWidget {
  const RiderTripsPage({super.key});

  @override
  State<RiderTripsPage> createState() => _RiderTripsPageState();
}

class _RiderTripsPageState extends State<RiderTripsPage> {
  final List<PastTrip> _pastTrips = [];
  bool _isLoading = false;
  bool _hasMore = true;
  String? _nextCursor;
  final ScrollController _scrollController = ScrollController();
  final ApiClient _apiClient = ApiClient();

  @override
  void initState() {
    super.initState();
    _loadTrips();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadTrips() async {
    if (_isLoading || !_hasMore) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _apiClient.fetchRiderHistory(cursor: _nextCursor);
      final List<PastTrip> newTrips = (response['results'] as List)
          .map((json) => PastTrip.fromJson(json))
          .toList();

      if (mounted) {
        setState(() {
          _pastTrips.addAll(newTrips);
          _nextCursor = response['next'];
          _hasMore = _nextCursor != null;
          _isLoading = false;
        });

        // Load addresses for new trips
        for (var trip in newTrips) {
          await trip.loadAddresses();
          if (mounted) setState(() {});
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading trips: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.6) {
      _loadTrips();
    }
  }

  Widget _buildLoadingCard() {
    return Card(
      color: const Color(0xff1E1C1F),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(Icons.radio_button_checked,
                    color: Color(0xFFA4A4A4), size: 16),
                SizedBox(width: 8),
                ShimmerLoading(width: 200, height: 16),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: const [
                Icon(Icons.location_on, color: Color(0xFFA4A4A4), size: 16),
                SizedBox(width: 8),
                ShimmerLoading(width: 200, height: 16),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF282828),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const ShimmerLoading(width: 100, height: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff151316),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Column(
                children: [
                  const Text(
                    'Ride History',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Poppins',
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Container(height: 1, color: Colors.grey[800]),
                ],
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _pastTrips.isEmpty && !_isLoading
                    ? const Center(
                        child: Text(
                          'No trips yet',
                          style: TextStyle(
                            color: Colors.white54,
                            fontFamily: 'Poppins',
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _pastTrips.length + (_isLoading ? 2 : 0),
                        itemBuilder: (context, index) {
                          if (index < _pastTrips.length) {
                            return PastTripCard(trip: _pastTrips[index]);
                          } else {
                            return _buildLoadingCard();
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const RiderNavbar(initialIndex: 3),
    );
  }
}

import 'package:fastpool_fe/models/ride.dart';

class SearchResponse {
  final String? next;
  final String? previous;
  final List<Ride> results;

  SearchResponse({
    this.next,
    this.previous,
    required this.results,
  });

  String? get nextCursor {
    if (next == null) return null;
    try {
      final uri = Uri.parse(next!);
      return uri.queryParameters['cursor'];
    } catch (e) {
      return null;
    }
  }

  factory SearchResponse.fromJson(Map<String, dynamic> json) {
    return SearchResponse(
      next: json['next'],
      previous: json['previous'],
      results: (json['results'] as List)
          .map((rideJson) => Ride.fromJson(rideJson))
          .toList(),
    );
  }
}

class Driver {
  final String name;
  final double rating;
  final String email;
  final String contactNumber;
  final String profilePicUrl;

  Driver({
    required this.name,
    required this.rating,
    required this.email,
    required this.contactNumber,
    required this.profilePicUrl,
  });
}

class Vehicle {
  final String model;
  final String number;
  final String type; // 'car' or 'bike'
  final bool hasAC;

  Vehicle({
    required this.model,
    required this.number,
    required this.type,
    required this.hasAC,
  });
}

class Ride {
  final Driver driver;
  final double sourceLat;
  final double sourceLng;
  final double destinationLat;
  final double destinationLng;
  final Vehicle vehicle;
  final DateTime time;
  final int capacity;
  final int availableSeats; // Total seats in vehicle
  final int unbookedSeats; // Currently available/unbooked seats
  final int amount;
  final String preferredGender;
  final String paymentOption;
  final DateTime expirationTime;
  final DateTime date;
  final String? description;
  final List<String> riders;
  final String pickup; // For display purposes
  final String destination; // For display purposes
  final int duration; // in minutes
  final double distance; // in kilometers

  Ride({
    required this.driver,
    required this.sourceLat,
    required this.sourceLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicle,
    required this.time,
    required this.capacity,
    required this.availableSeats,
    required this.unbookedSeats,
    required this.amount,
    required this.preferredGender,
    required this.paymentOption,
    required this.expirationTime,
    required this.date,
    this.description,
    required this.riders,
    required this.pickup,
    required this.destination,
    required this.duration,
    required this.distance,
  });
}

class Driver {
  final String username;
  final String email;
  final String gender;
  final String phone;
  final String profilePic;
  final double riderRating;
  final double driverRating;

  Driver({
    required this.username,
    required this.email,
    required this.gender,
    required this.phone,
    required this.profilePic,
    required this.riderRating,
    required this.driverRating,
  });

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      gender: json['gender'] ?? '',
      phone: json['phone'] ?? '',
      profilePic: json['profile_pic'] ?? '',
      riderRating: (json['rider_rating'] ?? 0.0).toDouble(),
      driverRating: (json['driver_rating'] ?? 0.0).toDouble(),
    );
  }
}

class Vehicle {
  final int id;
  final int driver;
  final String name;
  final String registrationNumber;
  final String type;
  final int capacity;
  final bool hasAC;

  Vehicle({
    required this.id,
    required this.driver,
    required this.name,
    required this.registrationNumber,
    required this.type,
    required this.capacity,
    required this.hasAC,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      id: json['id'] ?? 0,
      driver: json['driver'] ?? 0,
      name: json['name'] ?? '',
      registrationNumber: json['registration_number'] ?? '',
      type: json['type'] ?? '',
      capacity: json['capacity'] ?? 0,
      hasAC: json['AC'] ?? false,
    );
  }
}

class Ride {
  final int id;
  final Driver driver;
  final double sourceLat;
  final double sourceLng;
  final double destinationLat;
  final double destinationLng;
  final Vehicle vehicle;
  final String time;
  final int capacity;
  final int availableSeats;
  final int amount;
  final String preferredGender;
  final String paymentOption;
  final String expirationTime;
  final String date;
  final String? description;
  final List<dynamic> riders;
  final String pickup; // For display purposes
  final String destination; // For display purposes
  final int duration; // in minutes
  final double distance; // in kilometers

  Ride({
    required this.id,
    required this.driver,
    required this.sourceLat,
    required this.sourceLng,
    required this.destinationLat,
    required this.destinationLng,
    required this.vehicle,
    required this.time,
    required this.capacity,
    required this.availableSeats,
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

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] ?? 0,
      driver: Driver.fromJson(json['driver'] ?? {}),
      sourceLat: (json['source_lat'] ?? 0.0).toDouble(),
      sourceLng: (json['source_lng'] ?? 0.0).toDouble(),
      destinationLat: (json['destination_lat'] ?? 0.0).toDouble(),
      destinationLng: (json['destination_lng'] ?? 0.0).toDouble(),
      vehicle: Vehicle.fromJson(json['vehicle'] ?? {}),
      time: json['time'] ?? '',
      capacity: json['capacity'] ?? 0,
      availableSeats: json['available_seats'] ?? 0,
      amount: json['amount'] ?? 0,
      preferredGender: json['preferred_gender'] ?? '',
      paymentOption: json['payment_option'] ?? '',
      expirationTime: json['expiration_time'] ?? '',
      date: json['date'] ?? '',
      description: json['description'],
      riders: json['riders'] ?? [],
      // These fields need to be computed or fetched separately
      pickup: 'Pickup Location', // This needs to be computed from coordinates
      destination:
          'Destination Location', // This needs to be computed from coordinates
      duration: 0, // This needs to be computed
      distance: 0.0, // This needs to be computed
    );
  }
}

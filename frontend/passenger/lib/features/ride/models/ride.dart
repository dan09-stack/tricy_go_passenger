// lib/features/ride/models/ride.dart
class Ride {
  final String? id;
  final String passengerId;
  final String? driverId;
  final Location pickupLocation;
  final Location dropoffLocation;
  final int passengerCount;
  final String paymentMethod;
  final double? totalFare;
  final String status;
  final double? rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Ride({
    this.id,
    required this.passengerId,
    this.driverId,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.passengerCount,
    required this.paymentMethod,
    this.totalFare,
    required this.status,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      id: json['id'] ?? json['_id'],
      passengerId: json['passengerId'] ?? '',
      driverId: json['driverId'],
      pickupLocation: Location.fromJson(json['pickupLocation'] ?? {}),
      dropoffLocation: Location.fromJson(json['dropoffLocation'] ?? {}),
      passengerCount: json['passengerCount'] ?? 1,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      totalFare: (json['totalFare'] ?? 0).toDouble(),
      status: json['status'] ?? 'searching',
      rating: (json['rating'] ?? 0).toDouble(),
      review: json['review'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'passengerCount': passengerCount,
      'paymentMethod': paymentMethod,
      'totalFare': totalFare,
      'status': status,
      'rating': rating,
      'review': review,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Ride copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    Location? pickupLocation,
    Location? dropoffLocation,
    int? passengerCount,
    String? paymentMethod,
    double? totalFare,
    String? status,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      passengerCount: passengerCount ?? this.passengerCount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      totalFare: totalFare ?? this.totalFare,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class Location {
  final double lat;
  final double lng;
  final String? address;

  Location({
    required this.lat,
    required this.lng,
    this.address,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      lat: (json['lat'] ?? 0.0).toDouble(),
      lng: (json['lng'] ?? 0.0).toDouble(),
      address: json['address'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': lat,
      'lng': lng,
      'address': address,
    };
  }
}
class RideModel {
  final String? id;
  final String passengerId;
  final String? driverId;
  final String status;
  final LocationModel pickupLocation;
  final LocationModel dropoffLocation;
  final int passengerCount;
  final String paymentMethod;
  final double? fare;
  final double? rating;
  final String? review;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  RideModel({
    this.id,
    required this.passengerId,
    this.driverId,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.passengerCount,
    required this.paymentMethod,
    this.fare,
    this.rating,
    this.review,
    this.createdAt,
    this.updatedAt,
  });

  factory RideModel.fromJson(Map<String, dynamic> json) {
    return RideModel(
      id: json['id'] ?? json['_id'],
      passengerId: json['passengerId'] ?? '',
      driverId: json['driverId'],
      status: json['status'] ?? 'requested',
      pickupLocation: LocationModel.fromJson(json['pickupLocation'] ?? {}),
      dropoffLocation: LocationModel.fromJson(json['dropoffLocation'] ?? {}),
      passengerCount: json['passengerCount'] ?? 1,
      paymentMethod: json['paymentMethod'] ?? 'cash',
      fare: (json['fare'] ?? 0).toDouble(),
      rating: (json['rating'] ?? 0).toDouble(),
      review: json['review'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'passengerId': passengerId,
      'driverId': driverId,
      'status': status,
      'pickupLocation': pickupLocation.toJson(),
      'dropoffLocation': dropoffLocation.toJson(),
      'passengerCount': passengerCount,
      'paymentMethod': paymentMethod,
      'fare': fare,
      'rating': rating,
      'review': review,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  RideModel copyWith({
    String? id,
    String? passengerId,
    String? driverId,
    String? status,
    LocationModel? pickupLocation,
    LocationModel? dropoffLocation,
    int? passengerCount,
    String? paymentMethod,
    double? fare,
    double? rating,
    String? review,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RideModel(
      id: id ?? this.id,
      passengerId: passengerId ?? this.passengerId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      passengerCount: passengerCount ?? this.passengerCount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      fare: fare ?? this.fare,
      rating: rating ?? this.rating,
      review: review ?? this.review,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class LocationModel {
  final double lat;
  final double lng;
  final String? address;

  LocationModel({
    required this.lat,
    required this.lng,
    this.address,
  });

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
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

  LocationModel copyWith({
    double? lat,
    double? lng,
    String? address,
  }) {
    return LocationModel(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }
}

import 'package:latlong2/latlong.dart';

class Ride {
  final String id;
  final LatLng pickupLocation;
  final LatLng dropoffLocation;
  final String pickupAddress;
  final String dropoffAddress;
  final int passengerCount;
  final double fare;
  final String status; // "requested", "matched", "en_route", "completed"
  final DateTime createdAt;
  final DateTime? startedAt;
  final DateTime? completedAt;

  Ride({
    required this.id,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.passengerCount,
    required this.fare,
    required this.status,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
  });

  Ride copyWith({
    String? id,
    LatLng? pickupLocation,
    LatLng? dropoffLocation,
    String? pickupAddress,
    String? dropoffAddress,
    int? passengerCount,
    double? fare,
    String? status,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      passengerCount: passengerCount ?? this.passengerCount,
      fare: fare ?? this.fare,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}


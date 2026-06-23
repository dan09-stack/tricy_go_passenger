
class Driver {
  final String id;
  final String name;
  final double rating;
  final String vehicle;
  final String plate;
  final bool isVerified;

  const Driver({
    required this.id,
    required this.name,
    required this.rating,
    required this.vehicle,
    required this.plate,
    this.isVerified = false,
  });

  Driver copyWith({
    String? id,
    String? name,
    double? rating,
    String? vehicle,
    String? plate,
    bool? isVerified,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      rating: rating ?? this.rating,
      vehicle: vehicle ?? this.vehicle,
      plate: plate ?? this.plate,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}


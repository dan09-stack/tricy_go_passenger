
import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:tricygo_passenger/features/home/models/driver.dart';
import 'package:tricygo_passenger/features/home/models/fare_tier.dart';


class RideService {
  List<FareTier> getFareTiers() {
    return [
      const FareTier(
        id: "eco_share",
        name: "TricyGo EcoShare",
        price: 45.00,
        eta: "2 mins away",
        icon: "people_outline",
        isSelected: true,
      ),
      const FareTier(
        id: "express",
        name: "TricyGo Express",
        price: 70.00,
        eta: "Immediate pickup",
        icon: "flash_on",
        isSelected: false,
      ),
      const FareTier(
        id: "comfort_xl",
        name: "TricyGo ComfortXL",
        price: 110.00,
        eta: "Heavy load / Luggage",
        icon: "bento_outlined",
        isSelected: false,
      ),
    ];
  }

  Future<void> requestRide({
    required String pickup,
    required String destination,
    required int passengers,
  }) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 3));
    // In real app, this would make an API call
  }

  Future<void> cancelRide() async {
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Future<List<Driver>> getNearbyDrivers(LatLng location) async {
    // Simulate nearby drivers
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      const Driver(
        id: "d1",
        name: "Speedy Tricycler",
        rating: 4.9,
        vehicle: "Yellow Bajaj RE 4S",
        plate: "TRI-7788",
        isVerified: true,
      ),
    ];
  }

  Future<void> rateDriver(String driverId, double rating, String? comment) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // In real app, this would send rating to backend
  }
}


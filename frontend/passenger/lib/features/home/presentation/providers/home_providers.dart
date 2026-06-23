
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/home/presentation/state/home_state.dart';
import 'package:tricygo_passenger/features/home/services/location_service.dart';
import 'package:tricygo_passenger/features/home/services/ride_service.dart';


final homeStateProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(
    ref.read(locationServiceProvider),
    ref.read(rideServiceProvider),
  );
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final rideServiceProvider = Provider<RideService>((ref) {
  return RideService();
});

class HomeNotifier extends StateNotifier<HomeState> {
  final LocationService _locationService;
  final RideService _rideService;

  HomeNotifier(this._locationService, this._rideService) : super(const HomeState());

  void setState(AppState newState) {
    state = state.copyWith(currentState: newState);
  }

  void setPassengerCount(int count) {
    state = state.copyWith(passengerCount: count);
  }

  void setPickupLocation(String location) {
    state = state.copyWith(pickupLocation: location);
  }

  void setDestinationLocation(String location) {
    state = state.copyWith(destinationLocation: location);
  }

  void setSelectedFareTier(String tier) {
    state = state.copyWith(selectedFareTier: tier);
  }

  void updateDriverProgress(double progress) {
    state = state.copyWith(driverProgress: progress);
    if (progress >= 1.0) {
      state = state.copyWith(currentState: AppState.tripCompleted);
    }
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }

  Future<void> requestRide() async {
    try {
      state = state.copyWith(isLoading: true);
      state = state.copyWith(currentState: AppState.matching);
      
      await _rideService.requestRide(
        pickup: state.pickupLocation,
        destination: state.destinationLocation,
        passengers: state.passengerCount,
      );
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> cancelRide() async {
    try {
      state = state.copyWith(isLoading: true);
      await _rideService.cancelRide();
      state = state.copyWith(
        currentState: AppState.destinationSelect,
        driverProgress: 0.0,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
      rethrow;
    }
  }

  void resetToDestinationSelect() {
    state = state.copyWith(
      currentState: AppState.destinationSelect,
      driverProgress: 0.0,
    );
  }

  void completeTrip() {
    state = state.copyWith(currentState: AppState.tripCompleted);
  }
}


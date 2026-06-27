import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tricygo_passenger/features/home/models/ride_model.dart';
import 'package:tricygo_passenger/features/home/services/home_service.dart';

enum HomeState {
  destinationSelect,
  fareSelect,
  matching,
  driverEnRoute,
  tripCompleted,
}

class HomeNotifier extends StateNotifier<HomeState> {
  final HomeService _homeService;

  HomeNotifier(this._homeService) : super(HomeState.destinationSelect);

  RideModel? _currentRide;
  bool _isLoading = false;
  String? _errorMessage;

  RideModel? get currentRide => _currentRide;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  void setState(HomeState newState) {
    state = newState;
  }

  void setLoading(bool loading) {
    _isLoading = loading;
  }

  void setError(String? error) {
    _errorMessage = error;
  }

  void clearError() {
    _errorMessage = null;
  }

  Future<void> requestRide({
    required LocationModel pickupLocation,
    required LocationModel dropoffLocation,
    required int passengerCount,
    required String paymentMethod,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;

      final ride = await _homeService.requestRide(
        pickupLocation: pickupLocation,
        dropoffLocation: dropoffLocation,
        passengerCount: passengerCount,
        paymentMethod: paymentMethod,
      );

      _currentRide = ride;
      _isLoading = false;
      state = HomeState.matching;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> cancelRide() async {
    if (_currentRide?.id == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;

      await _homeService.cancelRide(_currentRide!.id!);
      _currentRide = null;
      _isLoading = false;
      state = HomeState.destinationSelect;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      rethrow;
    }
  }

  Future<void> completeRide() async {
    if (_currentRide?.id == null) return;

    try {
      await _homeService.rateRide(
        rideId: _currentRide!.id!,
        rating: 4.5,
        review: 'Great ride!',
      );
      _currentRide = null;
      state = HomeState.tripCompleted;
    } catch (e) {
      _errorMessage = e.toString();
    }
  }

  void reset() {
    state = HomeState.destinationSelect;
    _currentRide = null;
    _isLoading = false;
    _errorMessage = null;
  }

  void updateRideStatus(RideModel ride) {
    _currentRide = ride;
  }
}

final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  return HomeNotifier(HomeService());
});

final currentRideProvider = Provider<RideModel?>((ref) {
  return ref.watch(homeProvider.notifier).currentRide;
});

final isLoadingProvider = Provider<bool>((ref) {
  return ref.watch(homeProvider.notifier).isLoading;
});

final errorMessageProvider = Provider<String?>((ref) {
  return ref.watch(homeProvider.notifier).errorMessage;
});

enum AppState { 
  destinationSelect, 
  fareSelect, 
  matching, 
  driverEnRoute, 
  tripCompleted 
}

class HomeState {
  final AppState currentState;
  final int passengerCount;
  final String pickupLocation;
  final String destinationLocation;
  final double driverProgress;
  final bool isLoading;
  final String? errorMessage;
  final String selectedFareTier;

  const HomeState({
    this.currentState = AppState.destinationSelect,
    this.passengerCount = 1,
    this.pickupLocation = "My Current Location (7th Ave)",
    this.destinationLocation = "Central Terminal Market",
    this.driverProgress = 0.0,
    this.isLoading = false,
    this.errorMessage,
    this.selectedFareTier = "EcoShare",
  });

  HomeState copyWith({
    AppState? currentState,
    int? passengerCount,
    String? pickupLocation,
    String? destinationLocation,
    double? driverProgress,
    bool? isLoading,
    String? errorMessage,
    String? selectedFareTier,
  }) {
    return HomeState(
      currentState: currentState ?? this.currentState,
      passengerCount: passengerCount ?? this.passengerCount,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      driverProgress: driverProgress ?? this.driverProgress,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      selectedFareTier: selectedFareTier ?? this.selectedFareTier,
    );
  }
}


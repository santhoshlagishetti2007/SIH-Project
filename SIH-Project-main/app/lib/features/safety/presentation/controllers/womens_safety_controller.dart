import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/womens_safety_remote_data_source.dart';
import '../../data/repositories/womens_safety_repository_impl.dart';
import '../../domain/models/womens_safety_models.dart';
import '../../domain/repositories/womens_safety_repository.dart';

class WomensSafetyState {
  final String selectedCity;
  final WomensSafetyGuide? guide;
  final List<EmergencyStation> emergencyStations;
  final List<WomenVerifiedListing> verifiedListings;
  final bool isLoading;
  final String? errorMessage;
  final List<String> supportedCities;

  const WomensSafetyState({
    this.selectedCity = 'Jaipur',
    this.guide,
    this.emergencyStations = const [],
    this.verifiedListings = const [],
    this.isLoading = false,
    this.errorMessage,
    this.supportedCities = const ['Jaipur', 'Delhi', 'Goa', 'Mumbai', 'Udaipur'],
  });

  WomensSafetyState copyWith({
    String? selectedCity,
    WomensSafetyGuide? guide,
    List<EmergencyStation>? emergencyStations,
    List<WomenVerifiedListing>? verifiedListings,
    bool? isLoading,
    String? errorMessage,
    List<String>? supportedCities,
  }) {
    return WomensSafetyState(
      selectedCity: selectedCity ?? this.selectedCity,
      guide: guide ?? this.guide,
      emergencyStations: emergencyStations ?? this.emergencyStations,
      verifiedListings: verifiedListings ?? this.verifiedListings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      supportedCities: supportedCities ?? this.supportedCities,
    );
  }
}

final womensSafetyRepositoryProvider = Provider<WomensSafetyRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = WomensSafetyRemoteDataSourceImpl(apiClient);
  return WomensSafetyRepositoryImpl(remoteDataSource);
});

final womensSafetyControllerProvider =
    StateNotifierProvider<WomensSafetyNotifier, WomensSafetyState>((ref) {
  final repo = ref.watch(womensSafetyRepositoryProvider);
  return WomensSafetyNotifier(repo);
});

class WomensSafetyNotifier extends StateNotifier<WomensSafetyState> {
  final WomensSafetyRepository _repository;

  WomensSafetyNotifier(this._repository) : super(const WomensSafetyState()) {
    loadSafetyData(state.selectedCity);
  }

  Future<void> loadSafetyData(String city) async {
    state = state.copyWith(isLoading: true, errorMessage: null, selectedCity: city);

    final guideResult = await _repository.getCitySafetyGuide(city);
    final stationsResult = await _repository.getNearestEmergencyServices(city: city);
    final verifiedResult = await _repository.getWomenVerifiedStaysAndGuides(city: city);

    WomensSafetyGuide? guide;
    List<EmergencyStation> stations = [];
    List<WomenVerifiedListing> verified = [];

    guideResult.when(
      success: (data) => guide = data,
      failure: (_) {},
    );

    stationsResult.when(
      success: (data) => stations = data,
      failure: (_) {},
    );

    verifiedResult.when(
      success: (data) => verified = data,
      failure: (_) {},
    );

    state = state.copyWith(
      guide: guide,
      emergencyStations: stations,
      verifiedListings: verified,
      isLoading: false,
    );
  }

  void setCity(String city) {
    if (state.selectedCity != city) {
      loadSafetyData(city);
    }
  }

  void refresh() {
    loadSafetyData(state.selectedCity);
  }
}

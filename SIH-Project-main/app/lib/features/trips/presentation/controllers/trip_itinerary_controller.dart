import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../data/datasources/trip_remote_data_source.dart';
import '../../data/repositories/trip_repository_impl.dart';
import '../../domain/models/eatery_model.dart';
import '../../domain/models/place_models.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';

/// State of the Trip Itinerary, Transport & Eat Nearby Screen
class TripItineraryState {
  final bool isLoading;
  final bool isSaving;
  final bool isSwapping;
  final bool isSearching;
  final TripModel? trip;
  final int selectedDayIndex;
  final List<PlaceAlternative> swapAlternatives;
  final List<PlaceAutocompletePrediction> autocompleteResults;
  final Map<String, List<NearbyEatery>> stopEatNearby;
  final Map<String, bool> loadingEateryStops;
  final String? errorMessage;

  const TripItineraryState({
    this.isLoading = false,
    this.isSaving = false,
    this.isSwapping = false,
    this.isSearching = false,
    this.trip,
    this.selectedDayIndex = 0,
    this.swapAlternatives = const [],
    this.autocompleteResults = const [],
    this.stopEatNearby = const {},
    this.loadingEateryStops = const {},
    this.errorMessage,
  });

  ItineraryDay? get currentDay {
    if (trip == null || trip!.itinerary.isEmpty) return null;
    if (selectedDayIndex < 0 || selectedDayIndex >= trip!.itinerary.length) {
      return trip!.itinerary.first;
    }
    return trip!.itinerary[selectedDayIndex];
  }

  TripItineraryState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isSwapping,
    bool? isSearching,
    TripModel? trip,
    int? selectedDayIndex,
    List<PlaceAlternative>? swapAlternatives,
    List<PlaceAutocompletePrediction>? autocompleteResults,
    Map<String, List<NearbyEatery>>? stopEatNearby,
    Map<String, bool>? loadingEateryStops,
    String? errorMessage,
  }) {
    return TripItineraryState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isSwapping: isSwapping ?? this.isSwapping,
      isSearching: isSearching ?? this.isSearching,
      trip: trip ?? this.trip,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      swapAlternatives: swapAlternatives ?? this.swapAlternatives,
      autocompleteResults: autocompleteResults ?? this.autocompleteResults,
      stopEatNearby: stopEatNearby ?? this.stopEatNearby,
      loadingEateryStops: loadingEateryStops ?? this.loadingEateryStops,
      errorMessage: errorMessage,
    );
  }
}

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = TripRemoteDataSourceImpl(apiClient);
  return TripRepositoryImpl(remoteDataSource);
});

final tripItineraryControllerProvider =
    StateNotifierProvider<TripItineraryNotifier, TripItineraryState>((ref) {
  final repository = ref.watch(tripRepositoryProvider);
  return TripItineraryNotifier(repository);
});

class TripItineraryNotifier extends StateNotifier<TripItineraryState> {
  final TripRepository _repository;

  TripItineraryNotifier(this._repository) : super(const TripItineraryState());

  /// Load trip details or user's active trip
  Future<void> loadTrip([String? tripId]) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final result = tripId != null && tripId.isNotEmpty
        ? await _repository.getTripById(tripId)
        : await _repository.getMyTrips().then((res) {
            return res.when(
              success: (trips) => trips.isNotEmpty
                  ? ApiResponseSuccess(trips.first)
                  : const ApiResponseSuccess<TripModel?>(null),
              failure: (err) => ApiResponseFailure<TripModel?>(err),
            );
          });

    result.when(
      success: (trip) {
        if (trip != null) {
          final recalculated = trip.recalculateCosts();
          state = state.copyWith(
            isLoading: false,
            trip: recalculated,
            selectedDayIndex: 0,
          );
          // Pre-fetch eat nearby for first day stops
          if (recalculated.itinerary.isNotEmpty) {
            _prefetchEatNearbyForDay(recalculated.itinerary.first, recalculated.destination);
          }
        } else {
          state = state.copyWith(
            isLoading: false,
            errorMessage: 'No trips found. Create one to begin!',
          );
        }
      },
      failure: (err) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Failed to load itinerary: ${err.message}',
        );
      },
    );
  }

  /// Select active itinerary day tab
  void selectDay(int index) {
    if (state.trip != null &&
        index >= 0 &&
        index < state.trip!.itinerary.length) {
      state = state.copyWith(selectedDayIndex: index);
      _prefetchEatNearbyForDay(state.trip!.itinerary[index], state.trip!.destination);
    }
  }

  /// Fetch authentic local eateries near a specific stop
  Future<void> fetchEatNearbyForStop(ItineraryStop stop, String city) async {
    if (state.stopEatNearby.containsKey(stop.id)) return;

    final updatedLoading = Map<String, bool>.from(state.loadingEateryStops);
    updatedLoading[stop.id] = true;
    state = state.copyWith(loadingEateryStops: updatedLoading);

    final result = await _repository.getEatNearby(
      lat: stop.location.lat != 0.0 ? stop.location.lat : 26.9855,
      lng: stop.location.lng != 0.0 ? stop.location.lng : 75.8513,
      stopId: stop.id,
      stopName: stop.name,
      city: city,
    );

    result.when(
      success: (eateries) {
        final updatedMap = Map<String, List<NearbyEatery>>.from(state.stopEatNearby);
        updatedMap[stop.id] = eateries;
        final finishLoading = Map<String, bool>.from(state.loadingEateryStops);
        finishLoading.remove(stop.id);
        state = state.copyWith(
          stopEatNearby: updatedMap,
          loadingEateryStops: finishLoading,
        );
      },
      failure: (_) {
        final finishLoading = Map<String, bool>.from(state.loadingEateryStops);
        finishLoading.remove(stop.id);
        state = state.copyWith(loadingEateryStops: finishLoading);
      },
    );
  }

  /// Pre-fetch eat nearby recommendations for all stops in an active day
  void _prefetchEatNearbyForDay(ItineraryDay day, String destinationCity) {
    for (final stop in day.stops) {
      fetchEatNearbyForStop(stop, destinationCity);
    }
  }

  /// Change preferred transit mode for a specific leg (e.g., switch Walk to Auto or Bus)
  Future<void> selectTransitMode({
    required int dayNumber,
    required String legFromStopId,
    required String mode,
  }) async {
    if (state.trip == null) return;

    final updatedItinerary = state.trip!.itinerary.map((day) {
      if (day.dayNumber != dayNumber) return day;

      final updatedLegs = day.transitLegs.map((leg) {
        if (leg.fromStopId == legFromStopId) {
          return leg.withSelectedMode(mode);
        }
        return leg;
      }).toList();

      return day.copyWith(transitLegs: updatedLegs);
    }).toList();

    final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
    state = state.copyWith(trip: updatedTrip);

    await _persistItinerary(updatedTrip);
  }

  /// Reorder stops within a day (drag-and-drop)
  Future<void> reorderStops({
    required int dayNumber,
    required int oldIndex,
    required int newIndex,
  }) async {
    if (state.trip == null) return;

    var targetNewIndex = newIndex;
    if (oldIndex < targetNewIndex) {
      targetNewIndex -= 1;
    }

    final updatedItinerary = state.trip!.itinerary.map((day) {
      if (day.dayNumber != dayNumber) return day;

      final reorderedStops = List<ItineraryStop>.from(day.stops);
      final item = reorderedStops.removeAt(oldIndex);
      reorderedStops.insert(targetNewIndex, item);

      // Re-assign sequence order
      for (int i = 0; i < reorderedStops.length; i++) {
        reorderedStops[i] = reorderedStops[i].copyWith(order: i);
      }

      return day.copyWith(stops: reorderedStops);
    }).toList();

    final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
    state = state.copyWith(trip: updatedTrip);

    // Refresh transit legs for the day with new sequence
    await _refreshTransitLegsForDay(dayNumber);
    await _persistItinerary(state.trip!);
  }

  /// Swap an existing stop with an alternative recommended by Places API
  Future<void> swapStop({
    required int dayNumber,
    required String stopId,
    required PlaceAlternative alternative,
  }) async {
    if (state.trip == null) return;

    final updatedItinerary = state.trip!.itinerary.map((day) {
      if (day.dayNumber != dayNumber) return day;

      final updatedStops = day.stops.map((stop) {
        if (stop.id == stopId) {
          return stop.copyWith(
            id: alternative.id.isNotEmpty ? alternative.id : 'swapped_${DateTime.now().millisecondsSinceEpoch}',
            placeId: alternative.placeId,
            name: alternative.name,
            category: alternative.category,
            costCategory: alternative.costCategory,
            description: alternative.description,
            cost: alternative.cost,
            rating: alternative.rating,
            userRatingsTotal: alternative.userRatingsTotal,
            location: alternative.location,
            imageUrl: alternative.imageUrl,
            notes: 'Swapped: ${alternative.swapReason}',
          );
        }
        return stop;
      }).toList();

      return day.copyWith(stops: updatedStops);
    }).toList();

    final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
    state = state.copyWith(trip: updatedTrip, swapAlternatives: []);

    await _refreshTransitLegsForDay(dayNumber);
    await _persistItinerary(state.trip!);
  }

  /// Remove a stop from a day
  Future<void> removeStop({
    required int dayNumber,
    required String stopId,
  }) async {
    if (state.trip == null) return;

    final updatedItinerary = state.trip!.itinerary.map((day) {
      if (day.dayNumber != dayNumber) return day;

      final updatedStops = day.stops.where((s) => s.id != stopId).toList();
      for (int i = 0; i < updatedStops.length; i++) {
        updatedStops[i] = updatedStops[i].copyWith(order: i);
      }

      return day.copyWith(stops: updatedStops);
    }).toList();

    final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
    state = state.copyWith(trip: updatedTrip);

    await _refreshTransitLegsForDay(dayNumber);
    await _persistItinerary(state.trip!);
  }

  /// Add custom stop to a day
  Future<void> addCustomStop({
    required int dayNumber,
    required ItineraryStop customStop,
  }) async {
    if (state.trip == null) return;

    final updatedItinerary = state.trip!.itinerary.map((day) {
      if (day.dayNumber != dayNumber) return day;

      final updatedStops = List<ItineraryStop>.from(day.stops);
      final newStopWithOrder = customStop.copyWith(order: updatedStops.length);
      updatedStops.add(newStopWithOrder);

      return day.copyWith(stops: updatedStops);
    }).toList();

    final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
    state = state.copyWith(trip: updatedTrip, autocompleteResults: []);

    await _refreshTransitLegsForDay(dayNumber);
    await _persistItinerary(state.trip!);
  }

  /// Query 3 similar alternatives matching stop's category for "Swap this stop"
  Future<void> fetchSwapAlternatives(ItineraryStop stop) async {
    state = state.copyWith(isSwapping: true, swapAlternatives: []);

    final result = await _repository.getSwapAlternatives(
      category: stop.category,
      lat: stop.location.lat,
      lng: stop.location.lng,
      city: state.trip?.destination ?? 'Jaipur',
      placeName: stop.name,
      excludePlaceId: stop.placeId,
    );

    result.when(
      success: (alternatives) {
        state = state.copyWith(
          isSwapping: false,
          swapAlternatives: alternatives,
        );
      },
      failure: (_) {
        state = state.copyWith(
          isSwapping: false,
          swapAlternatives: [],
        );
      },
    );
  }

  /// Search Places Autocomplete
  Future<void> searchPlacesAutocomplete(String input) async {
    if (input.trim().isEmpty) {
      state = state.copyWith(autocompleteResults: [], isSearching: false);
      return;
    }

    state = state.copyWith(isSearching: true);

    final result = await _repository.searchPlacesAutocomplete(
      input: input,
      city: state.trip?.destination ?? 'Jaipur',
    );

    result.when(
      success: (predictions) {
        state = state.copyWith(
          isSearching: false,
          autocompleteResults: predictions,
        );
      },
      failure: (_) {
        state = state.copyWith(
          isSearching: false,
          autocompleteResults: [],
        );
      },
    );
  }

  /// Update Admin Transport Rate Config in MongoDB
  Future<void> saveAdminTransportRates(CityTransportRateConfig config) async {
    state = state.copyWith(isSaving: true);

    final res = await _repository.updateCityTransportRates(config);
    res.when(
      success: (_) async {
        // Re-compute transit legs across all days with new rate tables
        if (state.trip != null) {
          for (final day in state.trip!.itinerary) {
            await _refreshTransitLegsForDay(day.dayNumber);
          }
          await _persistItinerary(state.trip!);
        }
        state = state.copyWith(isSaving: false);
      },
      failure: (err) {
        state = state.copyWith(
          isSaving: false,
          errorMessage: 'Failed to update transport rates: ${err.message}',
        );
      },
    );
  }

  /// Re-calculate transit legs for a single day using backend Routes API
  Future<void> _refreshTransitLegsForDay(int dayNumber) async {
    if (state.trip == null) return;

    final targetDay = state.trip!.itinerary.firstWhere((d) => d.dayNumber == dayNumber);
    if (targetDay.stops.length < 2) {
      final updatedItinerary = state.trip!.itinerary.map((d) {
        if (d.dayNumber == dayNumber) return d.copyWith(transitLegs: []);
        return d;
      }).toList();
      final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
      state = state.copyWith(trip: updatedTrip);
      return;
    }

    final result = await _repository.calculateTransitLegs(
      stops: targetDay.stops,
      city: state.trip!.destination,
    );

    result.when(
      success: (legs) {
        final updatedItinerary = state.trip!.itinerary.map((d) {
          if (d.dayNumber == dayNumber) {
            return d.copyWith(transitLegs: legs);
          }
          return d;
        }).toList();

        final updatedTrip = state.trip!.copyWith(itinerary: updatedItinerary).recalculateCosts();
        state = state.copyWith(trip: updatedTrip);
      },
      failure: (_) {
        // Keep existing legs if calculation network failed
      },
    );
  }

  /// Persist entire itinerary state to MongoDB via PATCH /api/trips/:tripId/itinerary
  Future<void> _persistItinerary(TripModel trip) async {
    state = state.copyWith(isSaving: true);

    final result = await _repository.updateItinerary(
      tripId: trip.id,
      itinerary: trip.itinerary,
      title: trip.title,
      budget: trip.budget,
    );

    result.when(
      success: (savedTrip) {
        state = state.copyWith(
          isSaving: false,
          trip: savedTrip.recalculateCosts(),
        );
      },
      failure: (_) {
        state = state.copyWith(isSaving: false);
      },
    );
  }
}

import '../../../../core/network/api_result.dart';
import '../../../../core/storage/local_cache_service.dart';
import '../../domain/models/eatery_model.dart';
import '../../domain/models/place_models.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;
  final LocalCacheService _cacheService;

  TripRepositoryImpl(
    this._remoteDataSource, [
    LocalCacheService? cacheService,
  ]) : _cacheService = cacheService ?? LocalCacheService();

  @override
  Future<ApiResult<List<TripModel>>> getMyTrips() async {
    final result = await _remoteDataSource.fetchTrips();
    result.when(
      success: (trips) {
        if (trips.isNotEmpty) {
          _cacheService.cacheActiveTrip(trips.first.id, trips.first.toJson());
        }
      },
      failure: (_) {},
    );
    return result;
  }

  @override
  Future<ApiResult<TripModel>> getTripById(String tripId) async {
    final result = await _remoteDataSource.fetchTripById(tripId);
    return result.when(
      success: (trip) {
        _cacheService.cacheActiveTrip(trip.id, trip.toJson());
        return ApiResult.success(trip);
      },
      failure: (err) {
        // Offline Fallback: Load from local cache
        final cached = _cacheService.getCachedActiveTrip(tripId);
        if (cached != null) {
          return ApiResult.success(TripModel.fromJson(cached));
        }
        return ApiResult.failure(err);
      },
    );
  }

  @override
  Future<ApiResult<TripModel>> createTrip(TripModel trip) async {
    final result = await _remoteDataSource.createTrip(trip);
    result.when(
      success: (created) => _cacheService.cacheActiveTrip(created.id, created.toJson()),
      failure: (_) {},
    );
    return result;
  }

  @override
  Future<ApiResult<TripModel>> updateItinerary({
    required String tripId,
    required List<ItineraryDay> itinerary,
    String? title,
    double? budget,
  }) async {
    final result = await _remoteDataSource.updateTripItinerary(
      tripId: tripId,
      itinerary: itinerary,
      title: title,
      budget: budget,
    );

    return result.when(
      success: (updatedTrip) {
        _cacheService.cacheActiveTrip(tripId, updatedTrip.toJson());
        return ApiResult.success(updatedTrip);
      },
      failure: (err) {
        // Offline Fallback: Construct optimistic trip, cache locally, and queue mutation
        final cached = _cacheService.getCachedActiveTrip(tripId);
        final base = cached != null ? TripModel.fromJson(cached) : null;

        final optimisticTrip = TripModel(
          id: tripId,
          title: title ?? base?.title ?? 'My Itinerary',
          destination: base?.destination ?? 'Jaipur, Rajasthan',
          startDate: base?.startDate ?? DateTime.now(),
          endDate: base?.endDate ?? DateTime.now().add(const Duration(days: 3)),
          budget: budget ?? base?.budget ?? 15000,
          itinerary: itinerary,
          notes: base?.notes ?? '',
        );

        _cacheService.cacheActiveTrip(tripId, optimisticTrip.toJson());

        // Queue mutation for automatic sync when online
        _cacheService.enqueueMutation({
          'id': 'mut_${DateTime.now().millisecondsSinceEpoch}',
          'action': 'update_itinerary',
          'endpoint': '/trips/$tripId/itinerary',
          'method': 'PATCH',
          'payload': {
            'itinerary': itinerary.map((d) => d.toJson()).toList(),
            if (title != null) 'title': title,
            if (budget != null) 'budget': budget,
          },
          'createdAt': DateTime.now().toIso8601String(),
        });

        return ApiResult.success(optimisticTrip);
      },
    );
  }

  @override
  Future<ApiResult<List<PlaceAlternative>>> getSwapAlternatives({
    required String category,
    double? lat,
    double? lng,
    String? city,
    String? placeName,
    String? excludePlaceId,
  }) {
    return _remoteDataSource.fetchSwapAlternatives(
      category: category,
      lat: lat,
      lng: lng,
      city: city,
      placeName: placeName,
      excludePlaceId: excludePlaceId,
    );
  }

  @override
  Future<ApiResult<List<PlaceAutocompletePrediction>>> searchPlacesAutocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
  }) {
    return _remoteDataSource.autocompletePlaces(
      input: input,
      lat: lat,
      lng: lng,
      city: city,
    );
  }

  @override
  Future<ApiResult<List<TransitLeg>>> calculateTransitLegs({
    required List<ItineraryStop> stops,
    String city = 'Jaipur',
  }) {
    return _remoteDataSource.calculateTransitLegs(stops: stops, city: city);
  }

  @override
  Future<ApiResult<CityTransportRateConfig>> getCityTransportRates(String city) {
    return _remoteDataSource.fetchCityTransportRates(city);
  }

  @override
  Future<ApiResult<CityTransportRateConfig>> updateCityTransportRates(CityTransportRateConfig config) {
    return _remoteDataSource.updateCityTransportRates(config);
  }

  @override
  Future<ApiResult<List<NearbyEatery>>> getEatNearby({
    double? lat,
    double? lng,
    String? stopId,
    String? stopName,
    String? city,
    int? radius,
  }) {
    return _remoteDataSource.fetchEatNearby(
      lat: lat,
      lng: lng,
      stopId: stopId,
      stopName: stopName,
      city: city,
      radius: radius,
    );
  }
}

import '../../../../core/network/api_result.dart';
import '../../domain/models/eatery_model.dart';
import '../../domain/models/place_models.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<TripModel>>> getMyTrips() {
    return _remoteDataSource.fetchTrips();
  }

  @override
  Future<ApiResult<TripModel>> getTripById(String tripId) {
    return _remoteDataSource.fetchTripById(tripId);
  }

  @override
  Future<ApiResult<TripModel>> createTrip(TripModel trip) {
    return _remoteDataSource.createTrip(trip);
  }

  @override
  Future<ApiResult<TripModel>> updateItinerary({
    required String tripId,
    required List<ItineraryDay> itinerary,
    String? title,
    double? budget,
  }) {
    return _remoteDataSource.updateTripItinerary(
      tripId: tripId,
      itinerary: itinerary,
      title: title,
      budget: budget,
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

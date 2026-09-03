import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/eatery_model.dart';
import '../../domain/models/place_models.dart';
import '../../domain/models/transport_models.dart';
import '../../domain/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<ApiResult<List<TripModel>>> fetchTrips();
  Future<ApiResult<TripModel>> fetchTripById(String tripId);
  Future<ApiResult<TripModel>> createTrip(TripModel trip);
  Future<ApiResult<TripModel>> updateTripItinerary({
    required String tripId,
    required List<ItineraryDay> itinerary,
    String? title,
    double? budget,
  });
  Future<ApiResult<List<PlaceAlternative>>> fetchSwapAlternatives({
    required String category,
    double? lat,
    double? lng,
    String? city,
    String? placeName,
    String? excludePlaceId,
  });
  Future<ApiResult<List<PlaceAutocompletePrediction>>> autocompletePlaces({
    required String input,
    double? lat,
    double? lng,
    String? city,
  });
  Future<ApiResult<List<TransitLeg>>> calculateTransitLegs({
    required List<ItineraryStop> stops,
    String city = 'Jaipur',
  });
  Future<ApiResult<CityTransportRateConfig>> fetchCityTransportRates(String city);
  Future<ApiResult<CityTransportRateConfig>> updateCityTransportRates(CityTransportRateConfig config);
  Future<ApiResult<List<NearbyEatery>>> fetchEatNearby({
    double? lat,
    double? lng,
    String? stopId,
    String? stopName,
    String? city,
    int? radius,
  });
}

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final ApiClient _apiClient;

  TripRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<List<TripModel>>> fetchTrips() async {
    return await _apiClient.get(
      ApiConstants.tripsEndpoint,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => TripModel.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <TripModel>[];
      },
    );
  }

  @override
  Future<ApiResult<TripModel>> fetchTripById(String tripId) async {
    return await _apiClient.get(
      '${ApiConstants.tripsEndpoint}/$tripId',
      decoder: (data) => TripModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<TripModel>> createTrip(TripModel trip) async {
    return await _apiClient.post(
      ApiConstants.tripsEndpoint,
      data: trip.toJson(),
      decoder: (data) => TripModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<TripModel>> updateTripItinerary({
    required String tripId,
    required List<ItineraryDay> itinerary,
    String? title,
    double? budget,
  }) async {
    final payload = <String, dynamic>{
      'itinerary': itinerary.map((d) => d.toJson()).toList(),
    };
    if (title != null) payload['title'] = title;
    if (budget != null) payload['budget'] = budget;

    return await _apiClient.patch(
      '${ApiConstants.tripsEndpoint}/$tripId/itinerary',
      data: payload,
      decoder: (data) => TripModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<List<PlaceAlternative>>> fetchSwapAlternatives({
    required String category,
    double? lat,
    double? lng,
    String? city,
    String? placeName,
    String? excludePlaceId,
  }) async {
    final queryParams = <String, dynamic>{
      'category': category,
    };
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (city != null) queryParams['city'] = city;
    if (placeName != null) queryParams['placeName'] = placeName;
    if (excludePlaceId != null) queryParams['excludePlaceId'] = excludePlaceId;

    return await _apiClient.get(
      '${ApiConstants.tripsEndpoint}/places/alternatives',
      queryParameters: queryParams,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => PlaceAlternative.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <PlaceAlternative>[];
      },
    );
  }

  @override
  Future<ApiResult<List<PlaceAutocompletePrediction>>> autocompletePlaces({
    required String input,
    double? lat,
    double? lng,
    String? city,
  }) async {
    final queryParams = <String, dynamic>{
      'input': input,
    };
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (city != null) queryParams['city'] = city;

    return await _apiClient.get(
      '${ApiConstants.tripsEndpoint}/places/autocomplete',
      queryParameters: queryParams,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) =>
                  PlaceAutocompletePrediction.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <PlaceAutocompletePrediction>[];
      },
    );
  }

  @override
  Future<ApiResult<List<TransitLeg>>> calculateTransitLegs({
    required List<ItineraryStop> stops,
    String city = 'Jaipur',
  }) async {
    return await _apiClient.post(
      '${ApiConstants.tripsEndpoint}/transport/calculate-legs',
      data: {
        'city': city,
        'stops': stops.map((s) => s.toJson()).toList(),
      },
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => TransitLeg.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <TransitLeg>[];
      },
    );
  }

  @override
  Future<ApiResult<CityTransportRateConfig>> fetchCityTransportRates(String city) async {
    return await _apiClient.get(
      '/admin/transport-rates/$city',
      decoder: (data) => CityTransportRateConfig.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<CityTransportRateConfig>> updateCityTransportRates(CityTransportRateConfig config) async {
    return await _apiClient.put(
      '/admin/transport-rates/${config.city}',
      data: config.toJson(),
      decoder: (data) => CityTransportRateConfig.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<List<NearbyEatery>>> fetchEatNearby({
    double? lat,
    double? lng,
    String? stopId,
    String? stopName,
    String? city,
    int? radius,
  }) async {
    final queryParams = <String, dynamic>{};
    if (lat != null) queryParams['lat'] = lat;
    if (lng != null) queryParams['lng'] = lng;
    if (stopId != null) queryParams['stopId'] = stopId;
    if (stopName != null) queryParams['stopName'] = stopName;
    if (city != null) queryParams['city'] = city;
    if (radius != null) queryParams['radius'] = radius;

    return await _apiClient.get(
      '${ApiConstants.tripsEndpoint}/places/eat-nearby',
      queryParameters: queryParams,
      decoder: (data) {
        if (data is List) {
          return data
              .map((e) => NearbyEatery.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        return <NearbyEatery>[];
      },
    );
  }
}

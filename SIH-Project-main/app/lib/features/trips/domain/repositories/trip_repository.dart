import '../../../../core/network/api_result.dart';
import '../models/eatery_model.dart';
import '../models/place_models.dart';
import '../models/transport_models.dart';
import '../models/trip_model.dart';

/// Abstract Domain Contract for Trip & Transport Management
abstract class TripRepository {
  Future<ApiResult<List<TripModel>>> getMyTrips();
  Future<ApiResult<TripModel>> getTripById(String tripId);
  Future<ApiResult<TripModel>> createTrip(TripModel trip);
  Future<ApiResult<TripModel>> updateItinerary({
    required String tripId,
    required List<ItineraryDay> itinerary,
    String? title,
    double? budget,
  });
  Future<ApiResult<List<PlaceAlternative>>> getSwapAlternatives({
    required String category,
    double? lat,
    double? lng,
    String? city,
    String? placeName,
    String? excludePlaceId,
  });
  Future<ApiResult<List<PlaceAutocompletePrediction>>> searchPlacesAutocomplete({
    required String input,
    double? lat,
    double? lng,
    String? city,
  });
  Future<ApiResult<List<TransitLeg>>> calculateTransitLegs({
    required List<ItineraryStop> stops,
    String city = 'Jaipur',
  });
  Future<ApiResult<CityTransportRateConfig>> getCityTransportRates(String city);
  Future<ApiResult<CityTransportRateConfig>> updateCityTransportRates(CityTransportRateConfig config);
  Future<ApiResult<List<NearbyEatery>>> getEatNearby({
    double? lat,
    double? lng,
    String? stopId,
    String? stopName,
    String? city,
    int? radius,
  });
}

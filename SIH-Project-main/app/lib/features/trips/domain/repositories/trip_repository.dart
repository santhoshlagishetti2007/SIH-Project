import '../../../../core/network/api_result.dart';
import '../models/trip_model.dart';

/// Abstract Domain Contract for Trip Management
abstract class TripRepository {
  Future<ApiResult<List<TripModel>>> getMyTrips();
  Future<ApiResult<TripModel>> getTripById(String tripId);
  Future<ApiResult<TripModel>> createTrip(TripModel trip);
}

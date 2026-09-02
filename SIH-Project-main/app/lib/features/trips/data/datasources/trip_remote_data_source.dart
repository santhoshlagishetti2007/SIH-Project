import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<ApiResult<List<TripModel>>> fetchTrips();
  Future<ApiResult<TripModel>> createTrip(TripModel trip);
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
  Future<ApiResult<TripModel>> createTrip(TripModel trip) async {
    return await _apiClient.post(
      ApiConstants.tripsEndpoint,
      data: trip.toJson(),
      decoder: (data) => TripModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

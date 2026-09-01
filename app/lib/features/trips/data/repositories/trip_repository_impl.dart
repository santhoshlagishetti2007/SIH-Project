import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/trip_model.dart';
import '../../domain/repositories/trip_repository.dart';
import '../datasources/trip_remote_data_source.dart';

final tripRepositoryProvider = Provider<TripRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = TripRemoteDataSourceImpl(apiClient);
  return TripRepositoryImpl(remoteDataSource);
});

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource _remoteDataSource;

  TripRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<List<TripModel>>> getMyTrips() async {
    return await _remoteDataSource.fetchTrips();
  }

  @override
  Future<ApiResult<TripModel>> getTripById(String tripId) async {
    // Scaffold implementation
    return ApiResult.failure('Trip $tripId not found');
  }

  @override
  Future<ApiResult<TripModel>> createTrip(TripModel trip) async {
    return await _remoteDataSource.createTrip(trip);
  }
}

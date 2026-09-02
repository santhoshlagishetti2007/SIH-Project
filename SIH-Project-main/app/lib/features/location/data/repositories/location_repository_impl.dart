import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/location_session.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/location_remote_data_source.dart';

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = LocationRemoteDataSourceImpl(apiClient);
  return LocationRepositoryImpl(remoteDataSource);
});

class LocationRepositoryImpl implements LocationRepository {
  final LocationRemoteDataSource _remoteDataSource;

  LocationRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<LocationSession>> createSession(String sessionName) async {
    return await _remoteDataSource.createLocationSession(sessionName);
  }

  @override
  Future<ApiResult<void>> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  }) async {
    // Scaffold implementation
    return const ApiResult.success(null);
  }

  @override
  Stream<LocationSession> streamSessionLocation(String sessionId) {
    // In production, this connects to Firestore snapshots:
    // FirebaseFirestore.instance.collection('location_sessions').doc(sessionId).snapshots()
    return const Stream.empty();
  }
}

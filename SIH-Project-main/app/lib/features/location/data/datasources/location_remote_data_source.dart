import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/location_session.dart';

abstract class LocationRemoteDataSource {
  Future<ApiResult<LocationSession>> createLocationSession(String sessionName);
}

class LocationRemoteDataSourceImpl implements LocationRemoteDataSource {
  final ApiClient _apiClient;

  LocationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<LocationSession>> createLocationSession(String sessionName) async {
    return await _apiClient.post(
      '${ApiConstants.locationEndpoint}/share-session',
      data: {'sessionName': sessionName},
      decoder: (data) => LocationSession.fromJson(data as Map<String, dynamic>),
    );
  }
}

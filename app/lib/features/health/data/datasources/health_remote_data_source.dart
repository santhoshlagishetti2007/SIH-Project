import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/health_status.dart';

abstract class HealthRemoteDataSource {
  Future<ApiResult<HealthStatus>> fetchHealthStatus();
}

class HealthRemoteDataSourceImpl implements HealthRemoteDataSource {
  final ApiClient _apiClient;

  HealthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<HealthStatus>> fetchHealthStatus() async {
    final stopwatch = Stopwatch()..start();
    final result = await _apiClient.get(
      ApiConstants.healthEndpoint,
      decoder: (data) {
        stopwatch.stop();
        if (data is Map<String, dynamic>) {
          return HealthStatus.fromJson(data, latencyMs: stopwatch.elapsedMilliseconds);
        }
        return HealthStatus.fromJson({}, latencyMs: stopwatch.elapsedMilliseconds);
      },
    );
    return result;
  }
}

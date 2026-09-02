import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/health_status.dart';
import '../../domain/repositories/health_repository.dart';
import '../datasources/health_remote_data_source.dart';

/// Riverpod provider for HealthRepository
final healthRepositoryProvider = Provider<HealthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = HealthRemoteDataSourceImpl(apiClient);
  return HealthRepositoryImpl(remoteDataSource);
});

class HealthRepositoryImpl implements HealthRepository {
  final HealthRemoteDataSource _remoteDataSource;

  HealthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<HealthStatus>> pingHealth() async {
    return await _remoteDataSource.fetchHealthStatus();
  }
}

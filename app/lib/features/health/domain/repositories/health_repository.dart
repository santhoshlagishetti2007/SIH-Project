import '../../../../core/network/api_result.dart';
import '../models/health_status.dart';

/// Abstract domain contract for health check operations
abstract class HealthRepository {
  Future<ApiResult<HealthStatus>> pingHealth();
}

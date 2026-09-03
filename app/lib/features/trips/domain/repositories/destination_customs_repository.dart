import '../../../../core/network/api_result.dart';
import '../models/destination_customs_models.dart';

abstract class DestinationCustomsRepository {
  Future<ApiResult<DestinationCustoms>> getDestinationCustoms(String destination);
}

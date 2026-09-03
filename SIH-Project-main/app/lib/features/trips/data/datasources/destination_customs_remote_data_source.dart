import '../../../../core/network/api_client.dart';
import '../../domain/models/destination_customs_models.dart';

abstract class DestinationCustomsRemoteDataSource {
  Future<DestinationCustoms> getDestinationCustoms(String destination);
}

class DestinationCustomsRemoteDataSourceImpl implements DestinationCustomsRemoteDataSource {
  final ApiClient _apiClient;

  DestinationCustomsRemoteDataSourceImpl(this._apiClient);

  @override
  Future<DestinationCustoms> getDestinationCustoms(String destination) async {
    final response = await _apiClient.get('/destinations/customs/$destination');
    return DestinationCustoms.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

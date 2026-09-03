import '../../../../core/network/api_client.dart';
import '../../domain/models/womens_safety_models.dart';

abstract class WomensSafetyRemoteDataSource {
  Future<WomensSafetyGuide> getCitySafetyGuide(String city);
  Future<List<EmergencyStation>> getNearestEmergencyServices({double? lat, double? lng, String? city, String? type});
  Future<List<WomenVerifiedListing>> getWomenVerifiedStaysAndGuides({String? city, String? category});
}

class WomensSafetyRemoteDataSourceImpl implements WomensSafetyRemoteDataSource {
  final ApiClient _apiClient;

  WomensSafetyRemoteDataSourceImpl(this._apiClient);

  @override
  Future<WomensSafetyGuide> getCitySafetyGuide(String city) async {
    final response = await _apiClient.get('/safety/women/guide/$city');
    return WomensSafetyGuide.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<List<EmergencyStation>> getNearestEmergencyServices({
    double? lat,
    double? lng,
    String? city,
    String? type,
  }) async {
    final response = await _apiClient.get(
      '/safety/women/emergency-nearby',
      queryParameters: {
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
        if (city != null) 'city': city,
        if (type != null) 'type': type,
      },
    );

    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => EmergencyStation.fromJson(e as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WomenVerifiedListing>> getWomenVerifiedStaysAndGuides({
    String? city,
    String? category,
  }) async {
    final response = await _apiClient.get(
      '/safety/women/verified-stays-guides',
      queryParameters: {
        if (city != null) 'city': city,
        if (category != null) 'category': category,
      },
    );

    final list = response.data['data'] as List<dynamic>? ?? [];
    return list.map((e) => WomenVerifiedListing.fromJson(e as Map<String, dynamic>)).toList();
  }
}

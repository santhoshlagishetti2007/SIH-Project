import '../../../../core/network/api_client.dart';
import '../../auth/domain/models/emergency_contact.dart';
import '../../domain/models/location_session.dart';
import '../../domain/models/safety_models.dart';

abstract class SafetyRemoteDataSource {
  Future<SosTriggerResult> triggerSos({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    String? autoDialNumber,
  });

  Future<Map<String, dynamic>> startTripShare({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    int durationHours,
  });

  Future<void> updateLiveLocation({
    required String sessionId,
    required double lat,
    required double lng,
    double speed,
    int battery,
    String address,
  });

  Future<void> stopSession(String sessionId);
  Future<LocationSession> getSession(String sessionId);
}

class SafetyRemoteDataSourceImpl implements SafetyRemoteDataSource {
  final ApiClient _apiClient;

  SafetyRemoteDataSourceImpl(this._apiClient);

  @override
  Future<SosTriggerResult> triggerSos({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    String? autoDialNumber,
  }) async {
    final response = await _apiClient.post(
      '/safety/sos-trigger',
      data: {
        'userName': userName,
        'userPhone': userPhone,
        'location': location.toJson(),
        'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
        'autoDialNumber': autoDialNumber ?? '112',
      },
    );

    return SosTriggerResult.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  @override
  Future<Map<String, dynamic>> startTripShare({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    int durationHours = 12,
  }) async {
    final response = await _apiClient.post(
      '/safety/share-trip/start',
      data: {
        'userName': userName,
        'userPhone': userPhone,
        'location': location.toJson(),
        'emergencyContacts': emergencyContacts.map((c) => c.toJson()).toList(),
        'durationHours': durationHours,
      },
    );

    return response.data['data'] as Map<String, dynamic>;
  }

  @override
  Future<void> updateLiveLocation({
    required String sessionId,
    required double lat,
    required double lng,
    double speed = 0,
    int battery = 85,
    String address = '',
  }) async {
    await _apiClient.post(
      '/safety/share-trip/update',
      data: {
        'sessionId': sessionId,
        'lat': lat,
        'lng': lng,
        'speed': speed,
        'battery': battery,
        'address': address,
      },
    );
  }

  @override
  Future<void> stopSession(String sessionId) async {
    await _apiClient.post(
      '/safety/share-trip/stop',
      data: {'sessionId': sessionId},
    );
  }

  @override
  Future<LocationSession> getSession(String sessionId) async {
    final response = await _apiClient.get('/safety/session/$sessionId');
    return LocationSession.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

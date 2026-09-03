import '../../../../core/network/api_result.dart';
import '../../auth/domain/models/emergency_contact.dart';
import '../../domain/models/location_session.dart';
import '../models/safety_models.dart';

abstract class SafetyRepository {
  Future<ApiResult<SosTriggerResult>> triggerSos({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    String? autoDialNumber,
  });

  Future<ApiResult<Map<String, dynamic>>> startTripShare({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    int durationHours,
  });

  Future<ApiResult<void>> updateLiveLocation({
    required String sessionId,
    required double lat,
    required double lng,
    double speed,
    int battery,
    String address,
  });

  Future<ApiResult<void>> stopSession(String sessionId);
  Future<ApiResult<LocationSession>> getSession(String sessionId);
}

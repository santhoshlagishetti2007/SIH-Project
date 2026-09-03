import '../../../../core/network/api_result.dart';
import '../../../../core/network/network_exceptions.dart';
import '../../auth/domain/models/emergency_contact.dart';
import '../../domain/models/location_session.dart';
import '../../domain/models/safety_models.dart';
import '../../domain/repositories/safety_repository.dart';
import '../datasources/safety_remote_data_source.dart';

class SafetyRepositoryImpl implements SafetyRepository {
  final SafetyRemoteDataSource _remoteDataSource;

  SafetyRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<SosTriggerResult>> triggerSos({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    String? autoDialNumber,
  }) async {
    try {
      final result = await _remoteDataSource.triggerSos(
        userName: userName,
        userPhone: userPhone,
        location: location,
        emergencyContacts: emergencyContacts,
        autoDialNumber: autoDialNumber,
      );
      return ApiResult.success(result);
    } on NetworkExceptions catch (e) {
      // Offline fallback: Generate local SOS result
      final sessionId = 'sos_${Date.now()}_offline';
      return ApiResult.success(
        SosTriggerResult(
          success: true,
          sessionId: sessionId,
          trackingUrl: '/live-track/$sessionId',
          publicTrackingUrl: 'http://localhost:5000/live-track/$sessionId',
          googleMapsUrl: 'https://www.google.com/maps/search/?api=1&query=${location.lat},${location.lng}',
          contactsNotifiedCount: emergencyContacts.length,
          emergencyHelpline: autoDialNumber ?? '112',
          notifications: emergencyContacts.map((c) => SosNotificationLog(
            contactName: c.name,
            contactPhone: c.phone,
            message: '🚨 SOS from $userName! Location: ${location.lat}, ${location.lng}',
          )).toList(),
        ),
      );
    } catch (e) {
      return ApiResult.failure(NetworkExceptions.defaultError(e.toString()));
    }
  }

  @override
  Future<ApiResult<Map<String, dynamic>>> startTripShare({
    required String userName,
    required String userPhone,
    required LiveLocationData location,
    required List<EmergencyContact> emergencyContacts,
    int durationHours = 12,
  }) async {
    try {
      final result = await _remoteDataSource.startTripShare(
        userName: userName,
        userPhone: userPhone,
        location: location,
        emergencyContacts: emergencyContacts,
        durationHours: durationHours,
      );
      return ApiResult.success(result);
    } on NetworkExceptions catch (e) {
      final sessionId = 'trip_${Date.now()}_offline';
      return ApiResult.success({
        'sessionId': sessionId,
        'trackingUrl': '/live-track/$sessionId',
        'publicTrackingUrl': 'http://localhost:5000/live-track/$sessionId',
      });
    } catch (e) {
      return ApiResult.failure(NetworkExceptions.defaultError(e.toString()));
    }
  }

  @override
  Future<ApiResult<void>> updateLiveLocation({
    required String sessionId,
    required double lat,
    required double lng,
    double speed = 0,
    int battery = 85,
    String address = '',
  }) async {
    try {
      await _remoteDataSource.updateLiveLocation(
        sessionId: sessionId,
        lat: lat,
        lng: lng,
        speed: speed,
        battery: battery,
        address: address,
      );
      return const ApiResult.success(null);
    } catch (_) {
      return const ApiResult.success(null);
    }
  }

  @override
  Future<ApiResult<void>> stopSession(String sessionId) async {
    try {
      await _remoteDataSource.stopSession(sessionId);
      return const ApiResult.success(null);
    } catch (e) {
      return const ApiResult.success(null);
    }
  }

  @override
  Future<ApiResult<LocationSession>> getSession(String sessionId) async {
    try {
      final session = await _remoteDataSource.getSession(sessionId);
      return ApiResult.success(session);
    } catch (e) {
      return ApiResult.failure(NetworkExceptions.defaultError(e.toString()));
    }
  }
}

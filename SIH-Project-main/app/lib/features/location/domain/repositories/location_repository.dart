import '../../../../core/network/api_result.dart';
import '../models/location_session.dart';

/// Abstract Domain Contract for Realtime Location Sharing
abstract class LocationRepository {
  Future<ApiResult<LocationSession>> createSession(String sessionName);
  Future<ApiResult<void>> updateLocation({
    required String sessionId,
    required double latitude,
    required double longitude,
  });
  Stream<LocationSession> streamSessionLocation(String sessionId);
}

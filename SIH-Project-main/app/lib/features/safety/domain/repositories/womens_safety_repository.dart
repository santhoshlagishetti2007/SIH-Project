import '../../../../core/network/api_result.dart';
import '../models/womens_safety_models.dart';

abstract class WomensSafetyRepository {
  Future<ApiResult<WomensSafetyGuide>> getCitySafetyGuide(String city);
  Future<ApiResult<List<EmergencyStation>>> getNearestEmergencyServices({double? lat, double? lng, String? city, String? type});
  Future<ApiResult<List<WomenVerifiedListing>>> getWomenVerifiedStaysAndGuides({String? city, String? category});
}

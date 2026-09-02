import '../../../../core/network/api_result.dart';
import '../models/companion_message.dart';

/// Abstract Domain Contract for AI Travel Companion
abstract class CompanionRepository {
  Future<ApiResult<CompanionMessage>> sendMessage(String prompt, {String? tripContextId});
  Future<ApiResult<List<String>>> getPlaceRecommendations({
    required double latitude,
    required double longitude,
    required String interest,
  });
}

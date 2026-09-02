import '../../../../core/constants/api_constants.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/companion_message.dart';

abstract class CompanionRemoteDataSource {
  Future<ApiResult<CompanionMessage>> sendChatPrompt(String prompt, {String? tripContextId});
}

class CompanionRemoteDataSourceImpl implements CompanionRemoteDataSource {
  final ApiClient _apiClient;

  CompanionRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<CompanionMessage>> sendChatPrompt(String prompt, {String? tripContextId}) async {
    return await _apiClient.post(
      '${ApiConstants.companionEndpoint}/chat',
      data: {'prompt': prompt, 'tripContextId': tripContextId},
      decoder: (data) => CompanionMessage.fromJson(data as Map<String, dynamic>),
    );
  }
}

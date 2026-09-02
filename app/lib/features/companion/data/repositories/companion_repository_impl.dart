import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/companion_message.dart';
import '../../domain/repositories/companion_repository.dart';
import '../datasources/companion_remote_data_source.dart';

final companionRepositoryProvider = Provider<CompanionRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = CompanionRemoteDataSourceImpl(apiClient);
  return CompanionRepositoryImpl(remoteDataSource);
});

class CompanionRepositoryImpl implements CompanionRepository {
  final CompanionRemoteDataSource _remoteDataSource;

  CompanionRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<CompanionMessage>> sendMessage(String prompt, {String? tripContextId}) async {
    return await _remoteDataSource.sendChatPrompt(prompt, tripContextId: tripContextId);
  }

  @override
  Future<ApiResult<List<String>>> getPlaceRecommendations({
    required double latitude,
    required double longitude,
    required String interest,
  }) async {
    // Scaffold implementation
    return const ApiResult.success([]);
  }
}

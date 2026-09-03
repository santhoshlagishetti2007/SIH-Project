import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user);
  Future<ApiResult<UserModel>> fetchCurrentProfile();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user) async {
    return await _apiClient.post(
      '/auth/sync-profile',
      data: user.toJson(),
      decoder: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }

  @override
  Future<ApiResult<UserModel>> fetchCurrentProfile() async {
    return await _apiClient.get(
      '/auth/me',
      decoder: (data) => UserModel.fromJson(data as Map<String, dynamic>),
    );
  }
}

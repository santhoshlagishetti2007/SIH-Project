import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  final remoteDataSource = AuthRemoteDataSourceImpl(apiClient);
  return AuthRepositoryImpl(remoteDataSource);
});

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<ApiResult<UserModel>> signInWithEmailPassword(String email, String password) async {
    // Scaffold implementation
    return ApiResult.failure('Not implemented yet - skeleton stage');
  }

  @override
  Future<ApiResult<UserModel>> signInWithGoogle() async {
    // Scaffold implementation
    return ApiResult.failure('Not implemented yet - skeleton stage');
  }

  @override
  Future<ApiResult<void>> signOut() async {
    return const ApiResult.success(null);
  }

  @override
  Stream<UserModel?> get authStateChanges => Stream.value(null);
}

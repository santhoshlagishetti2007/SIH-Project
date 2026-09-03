import '../../../../core/network/api_result.dart';
import '../models/user_model.dart';

/// Abstract Domain Contract for Authentication
abstract class AuthRepository {
  Future<ApiResult<UserModel>> signInWithEmailPassword(String email, String password);
  Future<ApiResult<UserModel>> signInWithGoogle();
  Future<ApiResult<void>> signOut();
  Stream<UserModel?> get authStateChanges;
}

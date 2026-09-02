import '../../../../core/network/api_result.dart';
import '../models/emergency_contact.dart';
import '../models/user_model.dart';

/// Abstract Domain Contract for Sanchari Authentication & Profile System
abstract class AuthRepository {
  /// Sign in with Email and Password
  Future<ApiResult<UserModel>> signInWithEmailPassword(String email, String password);

  /// Register new user with Email and Password
  Future<ApiResult<UserModel>> signUpWithEmailPassword(String email, String password, String displayName);

  /// Sign in with Google Account
  Future<ApiResult<UserModel>> signInWithGoogle();

  /// Initiate Phone OTP verification
  Future<ApiResult<void>> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
  });

  /// Complete Phone OTP verification with 6-digit SMS code
  Future<ApiResult<UserModel>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  });

  /// Quick developer login for offline / dev-mode testing
  Future<ApiResult<UserModel>> signInDevMock({
    required String email,
    required String displayName,
  });

  /// Fetch user profile from MongoDB
  Future<ApiResult<UserModel>> fetchCurrentProfile();

  /// Synchronize Firebase authenticated user with MongoDB
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user);

  /// Update user profile details (onboarding & personalization)
  Future<ApiResult<UserModel>> updateProfile(UserModel user);

  /// Batch update emergency contacts
  Future<ApiResult<List<EmergencyContact>>> saveEmergencyContacts(List<EmergencyContact> contacts);

  /// Add single emergency contact
  Future<ApiResult<List<EmergencyContact>>> addEmergencyContact(EmergencyContact contact);

  /// Delete emergency contact by ID
  Future<ApiResult<List<EmergencyContact>>> deleteEmergencyContact(String contactId);

  /// Sign out current session
  Future<ApiResult<void>> signOut();

  /// Stream of authentication state changes
  Stream<UserModel?> get authStateChanges;

  /// Current in-memory cached user
  UserModel? get currentUser;
}

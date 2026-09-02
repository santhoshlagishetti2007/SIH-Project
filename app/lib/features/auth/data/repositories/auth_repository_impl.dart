import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_result.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/emergency_contact.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../datasources/firebase_auth_data_source.dart';

final firebaseAuthDataSourceProvider = Provider<FirebaseAuthDataSource>((ref) {
  return FirebaseAuthDataSource();
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthDataSourceProvider);
  final remoteData = ref.watch(authRemoteDataSourceProvider);
  final apiClient = ref.watch(apiClientProvider);

  final repo = AuthRepositoryImpl(firebaseAuth, remoteData, apiClient);
  ref.onDispose(() => repo.dispose());
  return repo;
});

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _firebaseAuthDataSource;
  final AuthRemoteDataSource _remoteDataSource;
  final ApiClient _apiClient;

  final StreamController<UserModel?> _authStateController =
      StreamController<UserModel?>.broadcast();

  UserModel? _currentUser;
  StreamSubscription? _firebaseAuthSub;

  AuthRepositoryImpl(
    this._firebaseAuthDataSource,
    this._remoteDataSource,
    this._apiClient,
  ) {
    _initAuthListener();
  }

  void _initAuthListener() {
    _firebaseAuthSub = _firebaseAuthDataSource.authStateChanges.listen((fbUser) async {
      if (fbUser != null) {
        final token = await _firebaseAuthDataSource.getIdToken();
        if (token != null) {
          _apiClient.setAuthToken(token);
        }

        // Fetch user from MongoDB backend or sync
        final initialUser = _firebaseAuthDataSource.mapFirebaseUserToUserModel(fbUser);
        final syncResult = await _remoteDataSource.syncUserProfile(initialUser);

        switch (syncResult) {
          case ApiSuccess(:final data):
            _currentUser = data;
            _authStateController.add(data);
          case ApiFailure():
            _currentUser = initialUser;
            _authStateController.add(initialUser);
        }
      } else {
        if (_currentUser?.authProvider != 'dev_mock') {
          _currentUser = null;
          _apiClient.clearAuthToken();
          _authStateController.add(null);
        }
      }
    });
  }

  @override
  Stream<UserModel?> get authStateChanges => _authStateController.stream;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<ApiResult<UserModel>> signInWithEmailPassword(String email, String password) async {
    try {
      final fbUser = await _firebaseAuthDataSource.signInWithEmailPassword(email, password);
      final token = await _firebaseAuthDataSource.getIdToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final initialUser = _firebaseAuthDataSource.mapFirebaseUserToUserModel(fbUser);
      final syncResult = await _remoteDataSource.syncUserProfile(initialUser);

      switch (syncResult) {
        case ApiSuccess(:final data):
          _currentUser = data;
          _authStateController.add(data);
          return ApiResult.success(data);
        case ApiFailure(:final message):
          _currentUser = initialUser;
          _authStateController.add(initialUser);
          return ApiResult.success(initialUser);
      }
    } catch (e) {
      AppLogger.error('Email sign in error: $e', 'AUTH');
      return ApiResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<ApiResult<UserModel>> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    try {
      final fbUser = await _firebaseAuthDataSource.signUpWithEmailPassword(
        email,
        password,
        displayName,
      );

      final token = await _firebaseAuthDataSource.getIdToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final newUser = UserModel(
        uid: fbUser.uid,
        email: fbUser.email ?? email,
        displayName: displayName.isNotEmpty ? displayName : (fbUser.displayName ?? 'Traveler'),
        authProvider: 'password',
        isOnboarded: false,
      );

      final syncResult = await _remoteDataSource.syncUserProfile(newUser);

      switch (syncResult) {
        case ApiSuccess(:final data):
          _currentUser = data;
          _authStateController.add(data);
          return ApiResult.success(data);
        case ApiFailure():
          _currentUser = newUser;
          _authStateController.add(newUser);
          return ApiResult.success(newUser);
      }
    } catch (e) {
      AppLogger.error('Sign up error: $e', 'AUTH');
      return ApiResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<ApiResult<UserModel>> signInWithGoogle() async {
    try {
      final fbUser = await _firebaseAuthDataSource.signInWithGoogle();
      final token = await _firebaseAuthDataSource.getIdToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final user = _firebaseAuthDataSource.mapFirebaseUserToUserModel(fbUser);
      final syncResult = await _remoteDataSource.syncUserProfile(user);

      switch (syncResult) {
        case ApiSuccess(:final data):
          _currentUser = data;
          _authStateController.add(data);
          return ApiResult.success(data);
        case ApiFailure():
          _currentUser = user;
          _authStateController.add(user);
          return ApiResult.success(user);
      }
    } catch (e) {
      AppLogger.error('Google sign in error: $e', 'AUTH');
      return ApiResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<ApiResult<void>> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
  }) async {
    try {
      await _firebaseAuthDataSource.sendPhoneOtp(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onVerificationFailed: onVerificationFailed,
        onAutoVerification: (credential) async {
          // Auto-resolution on Android devices
          AppLogger.info('Phone auto-verified credential received', 'PHONE_AUTH');
        },
      );
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<ApiResult<UserModel>> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      final fbUser = await _firebaseAuthDataSource.verifyPhoneOtp(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final token = await _firebaseAuthDataSource.getIdToken();
      if (token != null) {
        _apiClient.setAuthToken(token);
      }

      final user = _firebaseAuthDataSource.mapFirebaseUserToUserModel(fbUser);
      final syncResult = await _remoteDataSource.syncUserProfile(user);

      switch (syncResult) {
        case ApiSuccess(:final data):
          _currentUser = data;
          _authStateController.add(data);
          return ApiResult.success(data);
        case ApiFailure():
          _currentUser = user;
          _authStateController.add(user);
          return ApiResult.success(user);
      }
    } catch (e) {
      AppLogger.error('OTP verification error: $e', 'AUTH');
      return ApiResult.failure(e.toString().replaceAll('Exception: ', ''));
    }
  }

  @override
  Future<ApiResult<UserModel>> signInDevMock({
    required String email,
    required String displayName,
  }) async {
    try {
      final devUid = 'dev-user-${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '-')}';
      final devToken = 'dev-token-$devUid';

      _apiClient.setAuthToken(devToken);

      final devUser = UserModel(
        uid: devUid,
        email: email,
        displayName: displayName.isNotEmpty ? displayName : 'Dev Explorer',
        authProvider: 'dev_mock',
        isOnboarded: false,
      );

      final syncResult = await _remoteDataSource.syncUserProfile(devUser);

      switch (syncResult) {
        case ApiSuccess(:final data):
          _currentUser = data;
          _authStateController.add(data);
          return ApiResult.success(data);
        case ApiFailure():
          _currentUser = devUser;
          _authStateController.add(devUser);
          return ApiResult.success(devUser);
      }
    } catch (e) {
      return ApiResult.failure('Dev sign in error: $e');
    }
  }

  @override
  Future<ApiResult<UserModel>> fetchCurrentProfile() async {
    final result = await _remoteDataSource.fetchCurrentProfile();
    if (result is ApiSuccess<UserModel>) {
      _currentUser = result.data;
      _authStateController.add(result.data);
    }
    return result;
  }

  @override
  Future<ApiResult<UserModel>> syncUserProfile(UserModel user) async {
    final result = await _remoteDataSource.syncUserProfile(user);
    if (result is ApiSuccess<UserModel>) {
      _currentUser = result.data;
      _authStateController.add(result.data);
    }
    return result;
  }

  @override
  Future<ApiResult<UserModel>> updateProfile(UserModel user) async {
    final result = await _remoteDataSource.updateProfile(user);
    if (result is ApiSuccess<UserModel>) {
      _currentUser = result.data;
      _authStateController.add(result.data);
    }
    return result;
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> saveEmergencyContacts(
    List<EmergencyContact> contacts,
  ) async {
    final result = await _remoteDataSource.saveEmergencyContacts(contacts);
    if (result is ApiSuccess<List<EmergencyContact>> && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(emergencyContacts: result.data);
      _authStateController.add(_currentUser);
    }
    return result;
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> addEmergencyContact(EmergencyContact contact) async {
    final result = await _remoteDataSource.addEmergencyContact(contact);
    if (result is ApiSuccess<List<EmergencyContact>> && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(emergencyContacts: result.data);
      _authStateController.add(_currentUser);
    }
    return result;
  }

  @override
  Future<ApiResult<List<EmergencyContact>>> deleteEmergencyContact(String contactId) async {
    final result = await _remoteDataSource.deleteEmergencyContact(contactId);
    if (result is ApiSuccess<List<EmergencyContact>> && _currentUser != null) {
      _currentUser = _currentUser!.copyWith(emergencyContacts: result.data);
      _authStateController.add(_currentUser);
    }
    return result;
  }

  @override
  Future<ApiResult<void>> signOut() async {
    try {
      await _firebaseAuthDataSource.signOut();
      _apiClient.clearAuthToken();
      _currentUser = null;
      _authStateController.add(null);
      return const ApiResult.success(null);
    } catch (e) {
      return ApiResult.failure('Sign out error: $e');
    }
  }

  void dispose() {
    _firebaseAuthSub?.cancel();
    _authStateController.close();
  }
}

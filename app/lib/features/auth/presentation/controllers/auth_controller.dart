import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_result.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/models/emergency_contact.dart';
import '../../domain/models/user_model.dart';
import '../../domain/repositories/auth_repository.dart';

/// Sealed class representing Sanchari Auth States
sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  final String message;
  const AuthLoading([this.message = 'Processing...']);
}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthErrorState extends AuthState {
  final String message;
  const AuthErrorState(this.message);
}

/// Riverpod StateNotifier for Authentication & User Session
final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  return AuthController(authRepository);
});

class AuthController extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthController(this._authRepository) : super(const AuthInitial()) {
    _init();
  }

  void _init() {
    // Listen to repository auth state changes
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        state = Authenticated(user);
      } else {
        state = const Unauthenticated();
      }
    });

    // Check existing cached user
    if (_authRepository.currentUser != null) {
      state = Authenticated(_authRepository.currentUser!);
    } else {
      state = const Unauthenticated();
    }
  }

  /// Sign In with Email & Password
  Future<bool> signInWithEmail(String email, String password) async {
    state = const AuthLoading('Signing into your travel hub...');
    final result = await _authRepository.signInWithEmailPassword(email, password);

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Register / Sign Up with Email & Password
  Future<bool> signUpWithEmail(String email, String password, String displayName) async {
    state = const AuthLoading('Creating your Sanchari passport...');
    final result = await _authRepository.signUpWithEmailPassword(email, password, displayName);

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Sign In with Google
  Future<bool> signInWithGoogle() async {
    state = const AuthLoading('Connecting with Google...');
    final result = await _authRepository.signInWithGoogle();

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Send Phone OTP
  Future<bool> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
  }) async {
    state = const AuthLoading('Sending verification code...');
    final result = await _authRepository.sendPhoneOtp(
      phoneNumber: phoneNumber,
      onCodeSent: onCodeSent,
      onVerificationFailed: (err) {
        state = AuthErrorState(err);
        onVerificationFailed(err);
      },
    );

    if (result is ApiFailure) {
      state = AuthErrorState(result.message);
      return false;
    }
    return true;
  }

  /// Verify Phone OTP
  Future<bool> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    state = const AuthLoading('Verifying OTP code...');
    final result = await _authRepository.verifyPhoneOtp(
      verificationId: verificationId,
      smsCode: smsCode,
    );

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Quick Dev Login Bypass for offline or testing without live Firebase credentials
  Future<bool> signInDevMock({
    required String email,
    required String displayName,
  }) async {
    state = const AuthLoading('Logging in as Dev Explorer...');
    final result = await _authRepository.signInDevMock(
      email: email,
      displayName: displayName,
    );

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Update User Profile (Onboarding completion & settings)
  Future<bool> updateProfile(UserModel updatedUser) async {
    state = const AuthLoading('Updating profile...');
    final result = await _authRepository.updateProfile(updatedUser);

    switch (result) {
      case ApiSuccess(:final data):
        state = Authenticated(data);
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Save Emergency Contacts
  Future<bool> saveEmergencyContacts(List<EmergencyContact> contacts) async {
    final result = await _authRepository.saveEmergencyContacts(contacts);
    switch (result) {
      case ApiSuccess():
        if (state is Authenticated) {
          final current = (state as Authenticated).user;
          state = Authenticated(current.copyWith(emergencyContacts: contacts));
        }
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Add single emergency contact
  Future<bool> addEmergencyContact(EmergencyContact contact) async {
    final result = await _authRepository.addEmergencyContact(contact);
    switch (result) {
      case ApiSuccess(:final data):
        if (state is Authenticated) {
          final current = (state as Authenticated).user;
          state = Authenticated(current.copyWith(emergencyContacts: data));
        }
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Delete emergency contact
  Future<bool> deleteEmergencyContact(String contactId) async {
    final result = await _authRepository.deleteEmergencyContact(contactId);
    switch (result) {
      case ApiSuccess(:final data):
        if (state is Authenticated) {
          final current = (state as Authenticated).user;
          state = Authenticated(current.copyWith(emergencyContacts: data));
        }
        return true;
      case ApiFailure(:final message):
        state = AuthErrorState(message);
        return false;
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    state = const AuthLoading('Signing out...');
    await _authRepository.signOut();
    state = const Unauthenticated();
  }

  /// Clear error state
  void clearError() {
    if (state is AuthErrorState) {
      if (_authRepository.currentUser != null) {
        state = Authenticated(_authRepository.currentUser!);
      } else {
        state = const Unauthenticated();
      }
    }
  }
}

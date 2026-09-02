import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/services/firebase_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/user_model.dart';

/// Firebase Auth Data Source with robust dev-mode fallback support
class FirebaseAuthDataSource {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  bool get _isFirebaseReady => FirebaseService.isInitialized;

  FirebaseAuth? get _auth => _isFirebaseReady ? FirebaseAuth.instance : null;

  /// Stream of Firebase Auth state changes
  Stream<User?> get authStateChanges {
    if (!_isFirebaseReady || _auth == null) {
      return Stream.value(null);
    }
    return _auth!.authStateChanges();
  }

  /// Current Firebase User
  User? get currentFirebaseUser {
    if (!_isFirebaseReady || _auth == null) return null;
    return _auth!.currentUser;
  }

  /// Get active Firebase ID Token
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    if (!_isFirebaseReady || _auth == null || _auth!.currentUser == null) {
      return 'mock-dev-token';
    }
    try {
      return await _auth!.currentUser!.getIdToken(forceRefresh);
    } catch (e) {
      AppLogger.warn('Failed to retrieve Firebase ID token: $e', 'AUTH');
      return 'mock-dev-token';
    }
  }

  /// Sign In with Email and Password
  Future<User> signInWithEmailPassword(String email, String password) async {
    if (!_isFirebaseReady || _auth == null) {
      throw Exception('Firebase is not initialized. Use Dev Mode login to test locally.');
    }

    try {
      final credential = await _auth!.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to retrieve user from authentication.');
      }

      return credential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthErrorCode(e.code, e.message));
    } catch (e) {
      throw Exception('Sign in failed: $e');
    }
  }

  /// Register / Sign Up with Email and Password
  Future<User> signUpWithEmailPassword(
    String email,
    String password,
    String displayName,
  ) async {
    if (!_isFirebaseReady || _auth == null) {
      throw Exception('Firebase is not initialized. Use Dev Mode login to test locally.');
    }

    try {
      final credential = await _auth!.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (credential.user == null) {
        throw Exception('Failed to create user account.');
      }

      // Set display name on Firebase User record
      await credential.user!.updateDisplayName(displayName.trim());
      await credential.user!.reload();

      return _auth!.currentUser ?? credential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthErrorCode(e.code, e.message));
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Sign in with Google Account
  Future<User> signInWithGoogle() async {
    if (!_isFirebaseReady || _auth == null) {
      throw Exception('Firebase is not initialized. Use Dev Mode login to test locally.');
    }

    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled by user.');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth!.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Google authentication failed to produce user.');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthErrorCode(e.code, e.message));
    } catch (e) {
      throw Exception('Google Sign-In failed: $e');
    }
  }

  /// Send Phone OTP
  Future<void> sendPhoneOtp({
    required String phoneNumber,
    required void Function(String verificationId, int? resendToken) onCodeSent,
    required void Function(String error) onVerificationFailed,
    required void Function(PhoneAuthCredential credential) onAutoVerification,
  }) async {
    if (!_isFirebaseReady || _auth == null) {
      throw Exception('Firebase is not initialized. Use Dev Mode login to test locally.');
    }

    try {
      await _auth!.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) {
          onAutoVerification(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          onVerificationFailed(_handleAuthErrorCode(e.code, e.message));
        },
        codeSent: (String verificationId, int? resendToken) {
          onCodeSent(verificationId, resendToken);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          AppLogger.info('SMS auto-retrieval timeout for: $verificationId', 'PHONE_AUTH');
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      onVerificationFailed('Phone verification initiation failed: $e');
    }
  }

  /// Verify Phone OTP Code
  Future<User> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
  }) async {
    if (!_isFirebaseReady || _auth == null) {
      throw Exception('Firebase is not initialized. Use Dev Mode login to test locally.');
    }

    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode.trim(),
      );

      final userCredential = await _auth!.signInWithCredential(credential);

      if (userCredential.user == null) {
        throw Exception('Failed to authenticate with provided OTP.');
      }

      return userCredential.user!;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthErrorCode(e.code, e.message));
    } catch (e) {
      throw Exception('OTP verification failed: $e');
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      if (_isFirebaseReady && _auth != null) {
        await _auth!.signOut();
      }
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
    } catch (e) {
      AppLogger.warn('Sign out error: $e', 'AUTH');
    }
  }

  /// Map Firebase User to Initial UserModel
  UserModel mapFirebaseUserToUserModel(User user) {
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName ?? (user.phoneNumber != null ? 'Traveler (${user.phoneNumber})' : 'Traveler'),
      phone: user.phoneNumber,
      photoUrl: user.photoURL,
      authProvider: user.providerData.isNotEmpty
          ? user.providerData.first.providerId
          : 'password',
      isOnboarded: false,
    );
  }

  String _handleAuthErrorCode(String code, String? message) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email address is already registered.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password should be at least 6 characters.';
      case 'invalid-verification-code':
        return 'Invalid OTP code. Please check and re-enter.';
      case 'invalid-verification-id':
        return 'Phone verification session expired. Please request a new OTP.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again later.';
      case 'user-disabled':
        return 'This user account has been disabled.';
      default:
        return message ?? 'Authentication failed ($code).';
    }
  }
}

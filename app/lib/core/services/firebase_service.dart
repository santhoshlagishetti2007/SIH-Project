import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import '../utils/logger.dart';

/// State of Firebase services
enum FirebaseStatus {
  uninitialized,
  connected,
  unavailable,
}

/// Riverpod provider for Firebase state
final firebaseStatusProvider = StateProvider<FirebaseStatus>((ref) {
  return FirebaseStatus.uninitialized;
});

class FirebaseService {
  FirebaseService._();

  static bool isAvailable = false;

  /// Gracefully initialize Firebase without crashing app if config is missing
  static Future<FirebaseStatus> initialize() async {
    try {
      await Firebase.initializeApp();
      isAvailable = true;
      AppLogger.success('Firebase Core initialized successfully.', 'FIREBASE');
      return FirebaseStatus.connected;
    } catch (e) {
      isAvailable = false;
      AppLogger.warning(
        'Firebase could not be initialized (google-services.json/plist missing). Running with local dev mocks: $e',
        'FIREBASE',
      );
      return FirebaseStatus.unavailable;
    }
  }
}

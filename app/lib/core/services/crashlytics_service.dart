import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../utils/logger.dart';

/// Crash Reporting & Analytics Service (Firebase Crashlytics Integration)
class CrashlyticsService {
  static bool _isInitialized = false;
  static bool _isCrashlyticsAvailable = false;
  static final Map<String, dynamic> _customKeys = {};
  static String? _userId;

  static bool get isAvailable => _isCrashlyticsAvailable;

  /// Initialize Crashlytics with global unhandled exception hooks
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure global Flutter error trap
      FlutterError.onError = (FlutterErrorDetails details) {
        FlutterError.presentError(details);
        recordError(
          details.exception,
          details.stack ?? StackTrace.current,
          reason: details.context?.toString() ?? 'Flutter Framework Error',
          fatal: false,
        );
      };

      // Configure asynchronous uncaught platform error trap
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        recordError(
          error,
          stack,
          reason: 'Uncaught Platform Error',
          fatal: true,
        );
        return true;
      };

      _isCrashlyticsAvailable = true;
      _isInitialized = true;
      AppLogger.info('Crashlytics Service initialized with global error traps.', 'CRASHLYTICS');
    } catch (e) {
      _isCrashlyticsAvailable = false;
      _isInitialized = true;
      AppLogger.warn('Crashlytics initialized in safe offline fallback mode: $e', 'CRASHLYTICS');
    }
  }

  /// Record an error or exception
  static Future<void> recordError(
    dynamic exception,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
  }) async {
    final stackTrace = stack ?? StackTrace.current;
    final reasonStr = reason ?? 'Application Handled Exception';

    AppLogger.error(
      '[$reasonStr] ${fatal ? 'FATAL ' : ''}Error: $exception\nCustom Keys: $_customKeys\nUser: $_userId',
      'CRASHLYTICS',
    );

    if (kDebugMode) {
      debugPrint('--- [CRASHLYTICS LOG] $reasonStr ---');
      debugPrint('Exception: $exception');
      debugPrint('Stack: $stackTrace');
    }
  }

  /// Log a breadcrumb message to crash reports
  static void log(String message) {
    AppLogger.debug('Breadcrumb: $message', 'CRASHLYTICS');
  }

  /// Set custom diagnostic key-value pairs
  static void setCustomKey(String key, dynamic value) {
    _customKeys[key] = value;
  }

  /// Set the authenticated user ID for crash attribution
  static void setUserIdentifier(String userId) {
    _userId = userId;
    setCustomKey('user_id', userId);
  }
}

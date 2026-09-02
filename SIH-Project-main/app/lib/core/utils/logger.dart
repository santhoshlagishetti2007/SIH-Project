import 'package:flutter/foundation.dart';

/// Lightweight development logging helper
class AppLogger {
  AppLogger._();

  static void info(String message, [String tag = 'INFO']) {
    if (kDebugMode) {
      debugPrint('[\x1B[34m$tag\x1B[0m] $message');
    }
  }

  static void success(String message, [String tag = 'SUCCESS']) {
    if (kDebugMode) {
      debugPrint('[\x1B[32m$tag\x1B[0m] $message');
    }
  }

  static void warning(String message, [String tag = 'WARNING']) {
    if (kDebugMode) {
      debugPrint('[\x1B[33m$tag\x1B[0m] $message');
    }
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[\x1B[31mERROR\x1B[0m] $message');
      if (error != null) debugPrint('Details: $error');
      if (stackTrace != null) debugPrint('$stackTrace');
    }
  }
}

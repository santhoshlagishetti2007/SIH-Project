import 'dart:io';
import 'package:flutter/foundation.dart';

/// API and Network Constants for Sanchari
class ApiConstants {
  ApiConstants._();

  /// Default API port
  static const int defaultPort = 5000;

  /// Dynamic Base URL depending on platform
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:$defaultPort/api/v1';
    }
    if (Platform.isAndroid) {
      // 10.0.2.2 is the standard loopback alias for the host machine in Android Emulators
      return 'http://10.0.2.2:$defaultPort/api/v1';
    }
    // iOS Simulator, macOS, Windows, Linux
    return 'http://localhost:$defaultPort/api/v1';
  }

  // Endpoints
  static const String healthEndpoint = '/health';
  static const String authEndpoint = '/auth';
  static const String companionEndpoint = '/companion';
  static const String tripsEndpoint = '/trips';
  static const String locationEndpoint = '/location';
  static const String notificationsEndpoint = '/notifications';

  // Network Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
  static const Duration sendTimeout = Duration(seconds: 10);
}

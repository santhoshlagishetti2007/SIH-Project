import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppLogger.info('Booting Sanchari Mobile Application...', 'BOOT');

  // Initialize Firebase with fallback tolerance for missing dev keys
  final firebaseStatus = await FirebaseService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        firebaseStatusProvider.overrideWith((ref) => firebaseStatus),
      ],
      child: const SanchariApp(),
    ),
  );
}

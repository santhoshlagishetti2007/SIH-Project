import 'package:flutter/material.dart';
import 'core/constants/app_strings.dart';
import 'core/theme/app_theme.dart';
import 'features/health/presentation/screens/hello_sanchari_screen.dart';

/// Root Sanchari Application Widget
class SanchariApp extends StatelessWidget {
  const SanchariApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HelloSanchariScreen(),
    );
  }
}

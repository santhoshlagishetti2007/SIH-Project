import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/controllers/auth_controller.dart';
import 'app_localizations.dart';

/// App Locale State
class AppLocaleState {
  final Locale currentLocale;
  final List<Locale> supportedLocales;

  const AppLocaleState({
    this.currentLocale = const Locale('en'),
    this.supportedLocales = AppLocalizations.supportedLocales,
  });

  AppLocaleState copyWith({
    Locale? currentLocale,
    List<Locale>? supportedLocales,
  }) {
    return AppLocaleState(
      currentLocale: currentLocale ?? this.currentLocale,
      supportedLocales: supportedLocales ?? this.supportedLocales,
    );
  }
}

final appLocaleProvider =
    StateNotifierProvider<AppLocaleNotifier, AppLocaleState>((ref) {
  return AppLocaleNotifier(ref);
});

class AppLocaleNotifier extends StateNotifier<AppLocaleState> {
  final Ref _ref;

  AppLocaleNotifier(this._ref) : super(const AppLocaleState()) {
    _initLocaleFromUser();
  }

  void _initLocaleFromUser() {
    final authState = _ref.read(authControllerProvider);
    if (authState is Authenticated) {
      final lang = authState.user.preferredLanguage;
      if (lang.isNotEmpty) {
        state = state.copyWith(currentLocale: Locale(lang));
      }
    }
  }

  /// Change active app locale and persist to user profile in MongoDB
  Future<void> setLocale(Locale newLocale) async {
    if (!AppLocalizations.supportedLocales
        .any((l) => l.languageCode == newLocale.languageCode)) {
      return;
    }

    state = state.copyWith(currentLocale: newLocale);

    // Sync to user profile if logged in
    final authState = _ref.read(authControllerProvider);
    if (authState is Authenticated) {
      final updatedUser = authState.user.copyWith(
        preferredLanguage: newLocale.languageCode,
      );
      await _ref.read(authControllerProvider.notifier).updateProfile(updatedUser);
    }
  }
}

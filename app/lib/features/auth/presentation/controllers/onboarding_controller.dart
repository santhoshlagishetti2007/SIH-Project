import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/emergency_contact.dart';
import '../../domain/models/traveler_type.dart';
import '../../domain/models/user_model.dart';
import 'auth_controller.dart';

/// State object for the multi-step onboarding & profile setup flow
class OnboardingState {
  final int currentStep;
  final String displayName;
  final String homeCity;
  final String preferredLanguage;
  final TravelerType travelerType;
  final List<EmergencyContact> emergencyContacts;
  final bool isSubmitting;
  final String? errorMessage;

  const OnboardingState({
    this.currentStep = 0,
    this.displayName = '',
    this.homeCity = '',
    this.preferredLanguage = 'en',
    this.travelerType = TravelerType.solo,
    this.emergencyContacts = const [],
    this.isSubmitting = false,
    this.errorMessage,
  });

  OnboardingState copyWith({
    int? currentStep,
    String? displayName,
    String? homeCity,
    String? preferredLanguage,
    TravelerType? travelerType,
    List<EmergencyContact>? emergencyContacts,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      displayName: displayName ?? this.displayName,
      homeCity: homeCity ?? this.homeCity,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      travelerType: travelerType ?? this.travelerType,
      emergencyContacts: emergencyContacts ?? this.emergencyContacts,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage,
    );
  }
}

final onboardingControllerProvider =
    StateNotifierProvider<OnboardingController, OnboardingState>((ref) {
  final authState = ref.watch(authControllerProvider);
  UserModel? currentUser;
  if (authState is Authenticated) {
    currentUser = authState.user;
  }
  return OnboardingController(ref, currentUser);
});

class OnboardingController extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingController(this._ref, UserModel? initialUser)
      : super(OnboardingState(
          displayName: initialUser?.displayName ?? '',
          homeCity: initialUser?.homeCity ?? '',
          preferredLanguage: initialUser?.preferredLanguage ?? 'en',
          travelerType: initialUser?.travelerType ?? TravelerType.solo,
          emergencyContacts: initialUser?.emergencyContacts ?? [],
        ));

  void setStep(int step) {
    state = state.copyWith(currentStep: step, errorMessage: null);
  }

  void nextStep() {
    state = state.copyWith(currentStep: state.currentStep + 1, errorMessage: null);
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1, errorMessage: null);
    }
  }

  void setDisplayName(String name) {
    state = state.copyWith(displayName: name);
  }

  void setHomeCity(String city) {
    state = state.copyWith(homeCity: city);
  }

  void setPreferredLanguage(String lang) {
    state = state.copyWith(preferredLanguage: lang);
  }

  void setTravelerType(TravelerType type) {
    state = state.copyWith(travelerType: type);
  }

  void addEmergencyContact(EmergencyContact contact) {
    final updated = List<EmergencyContact>.from(state.emergencyContacts)..add(contact);
    state = state.copyWith(emergencyContacts: updated);
  }

  void removeEmergencyContact(int index) {
    if (index >= 0 && index < state.emergencyContacts.length) {
      final updated = List<EmergencyContact>.from(state.emergencyContacts)..removeAt(index);
      state = state.copyWith(emergencyContacts: updated);
    }
  }

  void updateEmergencyContact(int index, EmergencyContact contact) {
    if (index >= 0 && index < state.emergencyContacts.length) {
      final updated = List<EmergencyContact>.from(state.emergencyContacts);
      updated[index] = contact;
      state = state.copyWith(emergencyContacts: updated);
    }
  }

  /// Submit full profile setup and mark isOnboarded = true
  Future<bool> completeOnboarding() async {
    if (state.displayName.trim().isEmpty) {
      state = state.copyWith(errorMessage: 'Please enter your name.');
      return false;
    }

    state = state.copyWith(isSubmitting: true, errorMessage: null);

    final authState = _ref.read(authControllerProvider);
    if (authState is! Authenticated) {
      state = state.copyWith(
        isSubmitting: false,
        errorMessage: 'User is not authenticated. Please log in again.',
      );
      return false;
    }

    final currentUser = authState.user;
    final updatedUser = currentUser.copyWith(
      displayName: state.displayName.trim(),
      homeCity: state.homeCity.trim(),
      preferredLanguage: state.preferredLanguage,
      travelerType: state.travelerType,
      emergencyContacts: state.emergencyContacts,
      isOnboarded: true,
    );

    final success = await _ref.read(authControllerProvider.notifier).updateProfile(updatedUser);

    state = state.copyWith(isSubmitting: false);
    return success;
  }
}

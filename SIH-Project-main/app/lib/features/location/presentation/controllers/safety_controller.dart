import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/network/api_client.dart';
import '../../auth/domain/models/emergency_contact.dart';
import '../../auth/presentation/controllers/auth_controller.dart';
import '../data/datasources/safety_remote_data_source.dart';
import '../data/repositories/safety_repository_impl.dart';
import '../domain/models/safety_models.dart';
import '../domain/repositories/safety_repository.dart';

class SafetyState {
  final bool isSosActive;
  final bool isLocationSharingActive;
  final bool isSendingSos;
  final String? activeSessionId;
  final String? publicTrackingUrl;
  final LiveLocationData currentLocation;
  final SosTriggerResult? lastSosResult;
  final String? errorMessage;

  const SafetyState({
    this.isSosActive = false,
    this.isLocationSharingActive = false,
    this.isSendingSos = false,
    this.activeSessionId,
    this.publicTrackingUrl,
    this.currentLocation = const LiveLocationData(
      lat: 26.9124,
      lng: 75.7873,
      accuracy: 8,
      speed: 0,
      battery: 88,
      address: 'Pink City, Jaipur, Rajasthan',
    ),
    this.lastSosResult,
    this.errorMessage,
  });

  SafetyState copyWith({
    bool? isSosActive,
    bool? isLocationSharingActive,
    bool? isSendingSos,
    String? activeSessionId,
    String? publicTrackingUrl,
    LiveLocationData? currentLocation,
    SosTriggerResult? lastSosResult,
    String? errorMessage,
  }) {
    return SafetyState(
      isSosActive: isSosActive ?? this.isSosActive,
      isLocationSharingActive: isLocationSharingActive ?? this.isLocationSharingActive,
      isSendingSos: isSendingSos ?? this.isSendingSos,
      activeSessionId: activeSessionId ?? this.activeSessionId,
      publicTrackingUrl: publicTrackingUrl ?? this.publicTrackingUrl,
      currentLocation: currentLocation ?? this.currentLocation,
      lastSosResult: lastSosResult ?? this.lastSosResult,
      errorMessage: errorMessage,
    );
  }
}

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  final apiClient = ApiClient();
  final remoteDataSource = SafetyRemoteDataSourceImpl(apiClient);
  return SafetyRepositoryImpl(remoteDataSource);
});

final safetyControllerProvider =
    StateNotifierProvider<SafetyNotifier, SafetyState>((ref) {
  final repo = ref.watch(safetyRepositoryProvider);
  return SafetyNotifier(repo, ref);
});

class SafetyNotifier extends StateNotifier<SafetyState> {
  final SafetyRepository _repository;
  final Ref _ref;
  Timer? _periodicLocationTimer;

  SafetyNotifier(this._repository, this._ref) : super(const SafetyState());

  @override
  void dispose() {
    _periodicLocationTimer?.cancel();
    super.dispose();
  }

  /// Trigger SOS Alert with emergency contact broadcast
  Future<SosTriggerResult?> triggerSos({
    bool autoDialHelpline = true,
    BuildContext? context,
  }) async {
    state = state.copyWith(isSendingSos: true, errorMessage: null);

    final authState = _ref.read(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.displayName ?? 'Sanchari Traveler';
    final userPhone = user?.phone ?? '+919876543210';
    final contacts = user?.emergencyContacts ?? const [
      EmergencyContact(name: 'Emergency Services', phone: '112', relation: 'other', isPrimary: true),
    ];

    final result = await _repository.triggerSos(
      userName: userName,
      userPhone: userPhone,
      location: state.currentLocation,
      emergencyContacts: contacts,
      autoDialNumber: '112',
    );

    return result.when(
      success: (data) {
        state = state.copyWith(
          isSosActive: true,
          isLocationSharingActive: true,
          isSendingSos: false,
          activeSessionId: data.sessionId,
          publicTrackingUrl: data.publicTrackingUrl,
          lastSosResult: data,
        );

        // Start 10-second continuous streaming
        _startPeriodicLocationStreaming(data.sessionId);

        // Optionally dial national emergency helpline (112)
        if (autoDialHelpline) {
          _dialEmergencyNumber(data.emergencyHelpline);
        }

        return data;
      },
      failure: (err) {
        state = state.copyWith(
          isSendingSos: false,
          errorMessage: err.message,
        );
        return null;
      },
    );
  }

  /// Start Live Trip Location Sharing
  Future<bool> startTripShare() async {
    final authState = _ref.read(authControllerProvider);
    final user = authState is Authenticated ? authState.user : null;
    final userName = user?.displayName ?? 'Sanchari Traveler';
    final userPhone = user?.phone ?? '+919876543210';
    final contacts = user?.emergencyContacts ?? [];

    final result = await _repository.startTripShare(
      userName: userName,
      userPhone: userPhone,
      location: state.currentLocation,
      emergencyContacts: contacts,
      durationHours: 12,
    );

    return result.when(
      success: (data) {
        final sessionId = data['sessionId']?.toString() ?? 'trip_${Date.now()}';
        final trackingUrl = data['publicTrackingUrl']?.toString() ?? 'http://localhost:5000/live-track/$sessionId';

        state = state.copyWith(
          isLocationSharingActive: true,
          isSosActive: false,
          activeSessionId: sessionId,
          publicTrackingUrl: trackingUrl,
        );

        _startPeriodicLocationStreaming(sessionId);
        return true;
      },
      failure: (_) => false,
    );
  }

  /// Stop active sharing / SOS session
  Future<void> stopSharing() async {
    _periodicLocationTimer?.cancel();
    _periodicLocationTimer = null;

    if (state.activeSessionId != null) {
      await _repository.stopSession(state.activeSessionId!);
    }

    state = state.copyWith(
      isLocationSharingActive: false,
      isSosActive: false,
      activeSessionId: null,
      publicTrackingUrl: null,
    );
  }

  /// Periodic location streaming every 10 seconds
  void _startPeriodicLocationStreaming(String sessionId) {
    _periodicLocationTimer?.cancel();
    _periodicLocationTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      // Simulate minor GPS movement for realistic tracking simulation
      final newLat = state.currentLocation.lat + (0.00015 * (0.5 - (DateTime.now().second % 3) * 0.3));
      final newLng = state.currentLocation.lng + (0.00018 * (0.5 - (DateTime.now().second % 2) * 0.3));

      final updatedLoc = LiveLocationData(
        lat: newLat,
        lng: newLng,
        accuracy: 6.0,
        speed: (state.currentLocation.speed + 2) % 35,
        battery: 87,
        address: state.currentLocation.address,
      );

      state = state.copyWith(currentLocation: updatedLoc);

      await _repository.updateLiveLocation(
        sessionId: sessionId,
        lat: updatedLoc.lat,
        lng: updatedLoc.lng,
        speed: updatedLoc.speed,
        battery: updatedLoc.battery,
        address: updatedLoc.address,
      );
    });
  }

  Future<void> _dialEmergencyNumber(String number) async {
    final telUrl = Uri.parse('tel:$number');
    if (await canLaunchUrl(telUrl)) {
      await launchUrl(telUrl);
    }
  }
}

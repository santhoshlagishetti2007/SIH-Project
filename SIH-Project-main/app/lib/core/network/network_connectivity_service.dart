import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NetworkConnectivityService {
  final Connectivity _connectivity;
  final _controller = StreamController<bool>.broadcast();
  bool _isOnline = true;

  NetworkConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isOnline => _isOnline;
  Stream<bool> get onConnectivityChanged => _controller.stream;

  void _init() {
    _connectivity.onConnectivityChanged.listen((results) {
      final hasConnection = results.any((r) => r != ConnectivityResult.none);
      _isOnline = hasConnection;
      _controller.add(hasConnection);
    });
  }

  Future<bool> checkIsOnline() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    return _isOnline;
  }

  void dispose() {
    _controller.close();
  }
}

final networkConnectivityServiceProvider = Provider<NetworkConnectivityService>((ref) {
  final service = NetworkConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final isOnlineStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(networkConnectivityServiceProvider);
  return service.onConnectivityChanged;
});

final isOnlineProvider = Provider<bool>((ref) {
  final asyncValue = ref.watch(isOnlineStreamProvider);
  return asyncValue.value ?? true;
});

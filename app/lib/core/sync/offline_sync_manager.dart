import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../network/api_client.dart';
import '../network/network_connectivity_service.dart';
import '../storage/local_cache_service.dart';

class OfflineSyncManager {
  final ApiClient _apiClient;
  final LocalCacheService _cacheService;
  final NetworkConnectivityService _connectivityService;
  bool _isSyncing = false;

  OfflineSyncManager({
    ApiClient? apiClient,
    LocalCacheService? cacheService,
    NetworkConnectivityService? connectivityService,
  })  : _apiClient = apiClient ?? ApiClient(),
        _cacheService = cacheService ?? LocalCacheService(),
        _connectivityService = connectivityService ?? NetworkConnectivityService() {
    _listenToConnectivity();
  }

  void _listenToConnectivity() {
    _connectivityService.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        syncPendingMutations();
      }
    });
  }

  /// Add a user edit to the offline queue
  Future<String> queueMutation({
    required String action,
    required String endpoint,
    required String method,
    required Map<String, dynamic> payload,
  }) async {
    final id = 'mut_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
    final mutation = {
      'id': id,
      'action': action,
      'endpoint': endpoint,
      'method': method.toUpperCase(),
      'payload': payload,
      'createdAt': DateTime.now().toIso8601String(),
    };

    await _cacheService.enqueueMutation(mutation);
    return id;
  }

  int get pendingCount => _cacheService.getOfflineMutationQueue().length;

  List<Map<String, dynamic>> get pendingMutations => _cacheService.getOfflineMutationQueue();

  /// Replay and sync all queued mutations
  Future<Map<String, int>> syncPendingMutations() async {
    if (_isSyncing) return {'synced': 0, 'remaining': pendingCount};

    final isOnline = await _connectivityService.checkIsOnline();
    if (!isOnline) return {'synced': 0, 'remaining': pendingCount};

    _isSyncing = true;
    int syncedCount = 0;

    final queue = List<Map<String, dynamic>>.from(_cacheService.getOfflineMutationQueue());

    for (final item in queue) {
      final id = item['id'] as String;
      final endpoint = item['endpoint'] as String;
      final method = item['method'] as String;
      final payload = item['payload'] as Map<String, dynamic>;

      try {
        if (method == 'POST') {
          await _apiClient.post(endpoint, data: payload);
        } else if (method == 'PATCH') {
          await _apiClient.patch(endpoint, data: payload);
        } else if (method == 'PUT') {
          await _apiClient.put(endpoint, data: payload);
        }

        await _cacheService.removeMutation(id);
        syncedCount++;
      } catch (err) {
        // Stop on critical network errors to preserve order, retry later
        break;
      }
    }

    _isSyncing = false;
    return {'synced': syncedCount, 'remaining': pendingCount};
  }
}

final offlineSyncManagerProvider = Provider<OfflineSyncManager>((ref) {
  final apiClient = ApiClient();
  final cache = LocalCacheService();
  final connectivity = ref.watch(networkConnectivityServiceProvider);
  return OfflineSyncManager(
    apiClient: apiClient,
    cacheService: cache,
    connectivityService: connectivity,
  );
});

final pendingMutationsCountProvider = Provider<int>((ref) {
  final manager = ref.watch(offlineSyncManagerProvider);
  return manager.pendingCount;
});

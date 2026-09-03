import 'dart:convert';

/// High-performance local storage cache for offline-first support
class LocalCacheService {
  static final LocalCacheService _instance = LocalCacheService._internal();
  factory LocalCacheService() => _instance;
  LocalCacheService._internal();

  final Map<String, dynamic> _memoryCache = {};

  // Keys
  static const String keyActiveItinerary = 'sanchari_active_itinerary_';
  static const String keySavedPlaces = 'sanchari_saved_places_';
  static const String keyDestinationCustoms = 'sanchari_destination_customs_';
  static const String keyPhrasebook = 'sanchari_phrasebook_';
  static const String keyOfflineMutationQueue = 'sanchari_offline_mutation_queue';

  /// Save raw JSON / Map to cache
  Future<void> setJson(String key, Map<String, dynamic> data) async {
    _memoryCache[key] = data;
  }

  /// Retrieve JSON / Map from cache
  Map<String, dynamic>? getJson(String key) {
    final val = _memoryCache[key];
    if (val == null) return null;
    if (val is Map<String, dynamic>) return val;
    if (val is String) {
      try {
        return jsonDecode(val) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Save list to cache
  Future<void> setList(String key, List<dynamic> list) async {
    _memoryCache[key] = list;
  }

  /// Retrieve list from cache
  List<dynamic>? getList(String key) {
    final val = _memoryCache[key];
    if (val == null) return null;
    if (val is List) return val;
    if (val is String) {
      try {
        return jsonDecode(val) as List<dynamic>;
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// Remove key
  Future<void> remove(String key) async {
    _memoryCache.remove(key);
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
  }

  // --- Specific Feature Cache Helpers ---

  Future<void> cacheActiveTrip(String tripId, Map<String, dynamic> tripJson) async {
    await setJson('$keyActiveItinerary$tripId', tripJson);
    await setJson('${keyActiveItinerary}latest', tripJson);
  }

  Map<String, dynamic>? getCachedActiveTrip(String? tripId) {
    if (tripId != null) {
      final specific = getJson('$keyActiveItinerary$tripId');
      if (specific != null) return specific;
    }
    return getJson('${keyActiveItinerary}latest');
  }

  Future<void> cacheDestinationCustoms(String destination, Map<String, dynamic> customsJson) async {
    await setJson('$keyDestinationCustoms${destination.toLowerCase()}', customsJson);
  }

  Map<String, dynamic>? getCachedDestinationCustoms(String destination) {
    return getJson('$keyDestinationCustoms${destination.toLowerCase()}');
  }

  Future<void> cachePhrasebook(String source, String target, Map<String, dynamic> phrasebookJson) async {
    await setJson('$keyPhrasebook${source}_$target', phrasebookJson);
  }

  Map<String, dynamic>? getCachedPhrasebook(String source, String target) {
    return getJson('$keyPhrasebook${source}_$target');
  }

  // --- Offline Mutation Queue ---

  List<Map<String, dynamic>> getOfflineMutationQueue() {
    final list = getList(keyOfflineMutationQueue);
    if (list == null) return [];
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<void> enqueueMutation(Map<String, dynamic> mutation) async {
    final current = getOfflineMutationQueue();
    current.add(mutation);
    await setList(keyOfflineMutationQueue, current);
  }

  Future<void> removeMutation(String mutationId) async {
    final current = getOfflineMutationQueue();
    current.removeWhere((m) => m['id'] == mutationId);
    await setList(keyOfflineMutationQueue, current);
  }

  Future<void> clearMutationQueue() async {
    await remove(keyOfflineMutationQueue);
  }
}

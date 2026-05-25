import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'local_database_service.dart';

/// Handles offline detection, caching, and background sync.
/// When online: all requests go directly to API and cache responses.
/// When offline: serves from cache for reads, queues writes for later sync.
class SyncService extends ChangeNotifier {
  final ApiService api = ApiService();
  final LocalDatabaseService db = LocalDatabaseService();
  final Connectivity _connectivity = Connectivity();

  bool _isOnline = true;
  bool _isSyncing = false;
  StreamSubscription? _connectivitySubscription;

  bool get isOnline => _isOnline;
  bool get isSyncing => _isSyncing;

  SyncService() {
    _init();
  }

  void _init() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((result) {
      final wasOffline = !_isOnline;
      _isOnline = result != ConnectivityResult.none;

      if (_isOnline && wasOffline) {
        // Came back online — sync pending mutations
        syncPendingMutations();
      }

      notifyListeners();
    });

    // Check initial connectivity
    _connectivity.checkConnectivity().then((result) {
      _isOnline = result != ConnectivityResult.none;
      notifyListeners();
    });
  }

  /// Fetch with offline fallback: try API, fall back to cache.
  Future<dynamic> fetch(String endpoint,
      {Duration cacheMaxAge = const Duration(hours: 1)}) async {
    // Try network first
    if (_isOnline) {
      try {
        final data = await api.get(endpoint);
        // Cache the response
        await db.cachePut(endpoint, data);
        return data;
      } catch (e) {
        // Network failed — try cache
        final cached = await db.cacheGet(endpoint, maxAge: cacheMaxAge);
        if (cached != null) return cached;
        rethrow;
      }
    }

    // Offline — serve from cache
    final cached = await db.cacheGet(endpoint, maxAge: cacheMaxAge);
    if (cached != null) return cached;

    throw Exception('No internet connection and no cached data available');
  }

  /// Mutate with offline support: write online, queue when offline.
  Future<dynamic> mutate(
      String method, String endpoint, dynamic body) async {
    if (_isOnline) {
      try {
        final result = await _apiCall(method, endpoint, body);
        // Invalidate cache for this endpoint
        await db.cachePut(endpoint, result);
        return result;
      } catch (e) {
        // Queue on failure (server error, timeout, etc.)
        await db.enqueueMutation(method, endpoint, body);
        rethrow;
      }
    }

    // Offline — queue the mutation
    await db.enqueueMutation(method, endpoint, body);
    throw Exception('Queued for sync when online');
  }

  Future<dynamic> _apiCall(String method, String endpoint, dynamic body) async {
    switch (method.toUpperCase()) {
      case 'POST':
        return api.post(endpoint, body);
      case 'PUT':
        return api.put(endpoint, body);
      case 'DELETE':
        return api.delete(endpoint);
      default:
        throw Exception('Unsupported method: $method');
    }
  }

  /// Sync all pending mutations to the server.
  Future<void> syncPendingMutations() async {
    if (_isSyncing || !_isOnline) return;

    _isSyncing = true;
    notifyListeners();

    try {
      final pending = await db.getPendingMutations();
      for (final mutation in pending) {
        try {
          await _apiCall(
            mutation['method'] as String,
            mutation['endpoint'] as String,
            mutation['body'] != null
                ? mutation['body'] as String
                : null,
          );
          await db.removeMutation(mutation['id'] as int);
        } catch (e) {
          // Skip failed mutations for now, retry later
          debugPrint('Sync failed for mutation ${mutation['id']}: $e');
        }
      }
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }

  Future<int> pendingCount() async {
    return db.pendingMutationCount();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}
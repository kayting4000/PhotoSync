/// Sync service that processes pending offline operations
/// when connectivity is restored.
///
/// Watches connectivity and replays queued API calls in order.
import 'dart:async';
import 'dart:convert';
import '../services/local_database.dart';
import '../services/connectivity_service.dart';
import '../services/api_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final LocalDatabase _localDb = LocalDatabase();
  final ConnectivityService _connectivity = ConnectivityService();
  final ApiService _api = ApiService();

  bool _isSyncing = false;
  StreamSubscription? _connectivitySub;
  Timer? _periodicTimer;

  /// Stream that emits sync status updates
  final StreamController<SyncStatus> _statusController =
      StreamController<SyncStatus>.broadcast();
  Stream<SyncStatus> get onSyncStatusChanged => _statusController.stream;

  /// Current sync status
  SyncStatus _status = SyncStatus.idle;
  SyncStatus get status => _status;

  /// Initialize: start listening for connectivity changes
  Future<void> init() async {
    // Listen for connectivity changes
    _connectivitySub = _connectivity.onConnectivityChanged.listen((isOnline) {
      if (isOnline) {
        _sync();
      }
    });

    // Periodic sync every 5 minutes as a fallback
    _periodicTimer = Timer.periodic(const Duration(minutes: 5), (_) {
      if (_connectivity.isOnline) {
        _sync();
      }
    });

    // Initial sync attempt
    if (_connectivity.isOnline) {
      await _sync();
    }
  }

  /// Process all pending sync operations
  Future<void> _sync() async {
    if (_isSyncing) return;
    _isSyncing = true;
    _status = SyncStatus.syncing;
    _statusController.add(_status);

    try {
      final pendingItems = await _localDb.getPendingSyncs();

      for (final item in pendingItems) {
        if (!_connectivity.isOnline) break; // Stop if offline

        try {
          final id = item['id'] as int;
          final operation = item['operation'] as String;
          final endpoint = item['endpoint'] as String;
          final payloadStr = item['payload'] as String?;

          Map<String, dynamic>? payload;
          if (payloadStr != null) {
            try {
              payload = jsonDecode(payloadStr) as Map<String, dynamic>;
            } catch (_) {
              // If we can't decode, try simple parsing
              payload = {};
            }
          }

          // Replay the operation
          switch (operation) {
            case 'POST':
              await _api.post(endpoint, payload ?? {});
              break;
            case 'PUT':
              await _api.put(endpoint, payload ?? {});
              break;
            case 'DELETE':
              await _api.delete(endpoint);
              break;
          }

          // Remove successful sync
          await _localDb.removePendingSync(id);
        } catch (e) {
          // Increment retry count and continue with next
          await _localDb.incrementRetry(item['id'] as int);
        }
      }

      _status = SyncStatus.idle;
    } catch (e) {
      _status = SyncStatus.error;
    }

    _statusController.add(_status);
    _isSyncing = false;
  }

  /// Manually trigger a sync
  Future<void> triggerSync() async {
    if (_connectivity.isOnline) {
      await _sync();
    }
  }

  /// Get the count of pending sync operations
  Future<int> getPendingCount() async {
    return await _localDb.pendingSyncCount();
  }

  /// Clean up
  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _statusController.close();
  }
}

/// Possible sync statuses
enum SyncStatus { idle, syncing, error }
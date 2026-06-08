/// Service locator that provides access to global service instances.
/// This avoids circular dependencies from importing main.dart.
import 'connectivity_service.dart';
import 'sync_service.dart';

/// Global service instances
final connectivityService = ConnectivityService();
final syncService = SyncService();
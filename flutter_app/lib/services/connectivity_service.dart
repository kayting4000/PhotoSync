// Connectivity monitoring service.
// Uses connectivity_plus to detect online/offline status
// and provides a stream for other services to listen to.
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  bool _isOnline = true;
  StreamSubscription? _subscription;

  /// Current online status
  bool get isOnline => _isOnline;

  /// Stream that emits true/false when connectivity changes
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  Stream<bool> get onConnectivityChanged => _controller.stream;

  /// Initialize and start listening for connectivity changes
  Future<void> init() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      _controller.add(_isOnline);
    } catch (_) {
      _isOnline = true; // Default to online if check fails
    }

    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      _isOnline = result != ConnectivityResult.none;
      _controller.add(_isOnline);
    });
  }

  /// Clean up the stream subscription
  void dispose() {
    _subscription?.cancel();
    _controller.close();
  }
}
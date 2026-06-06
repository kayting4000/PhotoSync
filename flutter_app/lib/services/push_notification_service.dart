import 'package:flutter/foundation.dart';

/// Push notification service — stubbed out (Firebase not configured)
class PushNotificationService {
  static final PushNotificationService _instance = PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  Future<void> init() async {
    debugPrint('PushNotificationService: Firebase not configured, skipping init.');
  }

  Future<String?> getToken() async => null;

  Future<void> subscribeToTopic(String topic) async {}

  Future<void> unsubscribeFromTopic(String topic) async {}
}

import 'dart:async';
import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

/// Service for handling Firebase Cloud Messaging (FCM) push notifications.
class PushNotificationService {
  PushNotificationService._();

  static final PushNotificationService instance = PushNotificationService._();

  /// Lazy-initialized to avoid accessing FirebaseMessaging.instance on web.
  FirebaseMessaging? _messaging;
  FirebaseMessaging get _firebaseMessaging =>
      _messaging ??= FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Callback to be called when token is obtained or refreshed.
  void Function(String token)? onTokenRefresh;

  /// Callback to be called when a foreground message is received.
  /// The app can use this to show a snackbar, refresh data, or navigate.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Initializes the push notification service.
  /// Call this after Firebase.initializeApp() and after user login.
  Future<void> initialize() async {
    if (kIsWeb) {
      log('PushNotificationService: Skipping on web');
      return;
    }

    // Request permission (required for iOS, no-op on Android)
    final settings = await _firebaseMessaging.requestPermission();

    if (settings.authorizationStatus == AuthorizationStatus.authorized ||
        settings.authorizationStatus == AuthorizationStatus.provisional) {
      log('PushNotificationService: Permission granted');

      // Get initial token
      final token = await _firebaseMessaging.getToken();
      if (token != null) {
        log('PushNotificationService: FCM token obtained');
        onTokenRefresh?.call(token);
      }

      // Listen for token refresh
      unawaited(_tokenRefreshSubscription?.cancel());
      _tokenRefreshSubscription =
          _firebaseMessaging.onTokenRefresh.listen((token) {
        log('PushNotificationService: FCM token refreshed');
        onTokenRefresh?.call(token);
      });

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    } else {
      log('PushNotificationService: Permission denied');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log('PushNotificationService: Foreground message received');
    log('Title: ${message.notification?.title}');
    log('Body: ${message.notification?.body}');
    onForegroundMessage?.call(message);
  }

  /// Disposes the service and cancels subscriptions.
  void dispose() {
    unawaited(_tokenRefreshSubscription?.cancel());
    _tokenRefreshSubscription = null;
    onTokenRefresh = null;
    onForegroundMessage = null;
  }
}

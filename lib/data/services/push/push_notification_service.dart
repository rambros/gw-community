import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Handles FCM token registration, permission requests, foreground banners,
/// and background/terminated message tap navigation.
class PushNotificationService {
  PushNotificationService._();
  static final instance = PushNotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();

  // Android high-importance channel required for heads-up notifications
  static const _androidChannel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    importance: Importance.max,
    playSound: true,
  );

  // Called once from main.dart after Firebase.initializeApp()
  Future<void> initialize() async {
    await _setupLocalNotifications();
    await _requestPermission();
    await _registerToken();
    _listenForeground();
    _listenTokenRefresh();
  }

  // ── Permission ───────────────────────────────────────────────────────────────

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── Token registration ────────────────────────────────────────────────────────

  Future<void> _registerToken() async {
    try {
      if (Platform.isIOS) {
        // APNS token may not be ready immediately on iOS — wait with retries
        String? apnsToken;
        for (int i = 0; i < 5; i++) {
          apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) break;
          await Future.delayed(const Duration(seconds: 1));
        }
        if (apnsToken == null) {
          // Will get the FCM token later via onTokenRefresh
          debugPrint('PushNotificationService: APNS token not ready, skipping getToken()');
          return;
        }
      }

      final token = await _messaging.getToken();
      if (token != null) await _saveToken(token);
    } catch (e) {
      debugPrint('PushNotificationService: getToken error: $e');
    }
  }

  void _listenTokenRefresh() {
    _messaging.onTokenRefresh.listen(_saveToken);
  }

  Future<void> _saveToken(String token) async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;

    final platform = Platform.isIOS ? 'ios' : 'android';

    try {
      await SupaFlow.client.from('cc_device_tokens').upsert(
        {
          'user_id': userId,
          'fcm_token': token,
          'platform': platform,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,fcm_token',
      );
      debugPrint('PushNotificationService: token saved ($platform)');
    } catch (e) {
      debugPrint('PushNotificationService: failed to save token: $e');
    }
  }

  /// Call this when the user disables push in Settings — removes all tokens
  /// for the current device so FCM won't deliver messages.
  Future<void> removeToken() async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;

    final token = await _messaging.getToken();
    if (token == null) return;

    try {
      await SupaFlow.client
          .from('cc_device_tokens')
          .delete()
          .eq('user_id', userId)
          .eq('fcm_token', token);
      debugPrint('PushNotificationService: token removed');
    } catch (e) {
      debugPrint('PushNotificationService: failed to remove token: $e');
    }
  }

  // ── Local notifications (foreground banner) ───────────────────────────────────

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(android: androidSettings, iOS: iosSettings);

    await _localNotifications.initialize(settings);

    await _localNotifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_androidChannel);
  }

  void _listenForeground() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (notification == null) return;

      _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(),
        ),
      );
    });
  }
}

/// Top-level handler for background messages (required by firebase_messaging).
/// Must be a top-level function — not a method.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('PushNotificationService: background message: ${message.messageId}');
  // No UI work here — Firebase handles the system notification automatically.
}

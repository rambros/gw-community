import 'package:flutter/foundation.dart';
import 'package:flutter_app_badger/flutter_app_badger.dart';

/// Service to manage app icon badge count for unread notifications
class AppBadgeService {
  static final AppBadgeService _instance = AppBadgeService._internal();
  factory AppBadgeService() => _instance;
  AppBadgeService._internal();

  bool _isSupported = false;
  bool _initialized = false;

  /// Initialize the badge service and check platform support
  Future<void> init() async {
    if (_initialized) return;

    try {
      _isSupported = await FlutterAppBadger.isAppBadgeSupported();
      _initialized = true;
      debugPrint('AppBadgeService: Badge supported = $_isSupported');
    } catch (e) {
      debugPrint('AppBadgeService: Error checking support: $e');
      _isSupported = false;
      _initialized = true;
    }
  }

  /// Update the app icon badge with the unread count
  Future<void> updateBadgeCount(int count) async {
    if (!_initialized) await init();
    if (!_isSupported) return;

    try {
      if (count > 0) {
        await FlutterAppBadger.updateBadgeCount(count);
        debugPrint('AppBadgeService: Badge updated to $count');
      } else {
        await FlutterAppBadger.removeBadge();
        debugPrint('AppBadgeService: Badge removed');
      }
    } catch (e) {
      debugPrint('AppBadgeService: Error updating badge: $e');
    }
  }

  /// Remove the badge from app icon
  Future<void> removeBadge() async {
    if (!_initialized) await init();
    if (!_isSupported) return;

    try {
      await FlutterAppBadger.removeBadge();
      debugPrint('AppBadgeService: Badge removed');
    } catch (e) {
      debugPrint('AppBadgeService: Error removing badge: $e');
    }
  }
}

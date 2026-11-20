import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/in_app_notification_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/data/services/unread_badge_sync.dart';

/// One inbox row from `cc_notifications`. Group messages stay in the group tab.
class UnifiedNotificationItem {
  final int id;
  final String title;
  final String? message;
  final String? imageUrl;
  bool isRead;
  final DateTime createdAt;
  final CcNotificationsRow notification;

  UnifiedNotificationItem(CcNotificationsRow n)
      : id = n.id,
        title = n.title,
        message = n.message,
        imageUrl = imageUrlOf(n.metadata),
        isRead = n.isRead,
        createdAt = n.createdAt,
        notification = n;
}

String? imageUrlOf(dynamic metadata) {
  if (metadata is Map && metadata['image_url'] is String) {
    final url = (metadata['image_url'] as String).trim();
    if (url.isNotEmpty) return url;
  }
  return null;
}

class InAppNotificationsViewModel extends ChangeNotifier {
  final InAppNotificationRepository _repository = InAppNotificationRepository();
  final AnnouncementRepository _announcementRepository = AnnouncementRepository();

  List<UnifiedNotificationItem> _items = [];
  List<UnifiedNotificationItem> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  bool get hasUnread => _items.any((n) => !n.isRead);
  int get unreadCount => _items.where((n) => !n.isRead).length;

  List<UnifiedNotificationItem> get unreadItems =>
      _items.where((n) => !n.isRead).toList();
  List<UnifiedNotificationItem> get readItems =>
      _items.where((n) => n.isRead).toList();

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final systemNotifs = await _repository.getNotificationsForCurrentUser();
      _items = systemNotifs.map(UnifiedNotificationItem.new).toList();
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading notifications';
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> markAsRead(UnifiedNotificationItem item) async {
    if (item.isRead) return;

    final success = await _repository.markAsRead(item.id);
    if (success) {
      item.isRead = true;
      _safeNotifyListeners();
      unawaited(UnreadBadgeSync.instance.refreshNow());
    }
  }

  /// Marks the group message read, and the inbox alert that points at it.
  Future<void> markMessageRead(int sharingId) async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;
    await _announcementRepository.markAnnouncementAsRead(sharingId, userId);
  }

  Future<void> markAllAsRead() async {
    await _repository.markAllAsRead();
    await loadNotifications();
    unawaited(UnreadBadgeSync.instance.refreshNow());
  }

  Future<void> deleteNotification(UnifiedNotificationItem item) async {
    final success = await _repository.deleteNotification(item.id);
    if (success) {
      _items.removeWhere((n) => n.id == item.id);
      _safeNotifyListeners();
      unawaited(UnreadBadgeSync.instance.refreshNow());
    }
  }

  Future<void> deleteAllNotifications() async {
    final success = await _repository.deleteAllNotifications();
    if (success) {
      _items = [];
      _safeNotifyListeners();
      unawaited(UnreadBadgeSync.instance.refreshNow());
    }
  }

  Future<void> deleteReadNotifications() async {
    final success = await _repository.deleteReadNotifications();
    if (success) {
      _items.removeWhere((n) => n.isRead);
      _safeNotifyListeners();
    }
  }

  void _safeNotifyListeners() {
    if (_isDisposed) return;
    notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

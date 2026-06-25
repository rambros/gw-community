import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/in_app_notification_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Unified item representing either a system notification or a facilitator announcement
class UnifiedNotificationItem {
  final String source; // 'system' | 'announcement'
  final int id;
  final String title;
  final String? message;
  bool isRead;
  final DateTime createdAt;

  // System notification fields
  final CcNotificationsRow? systemNotification;

  // Announcement fields
  final CcViewNotificationsUsersRow? announcement;
  final String? groupName;
  final int? groupId;

  UnifiedNotificationItem.fromSystem(CcNotificationsRow n)
      : source = 'system',
        id = n.id,
        title = n.title,
        message = n.message,
        isRead = n.isRead,
        createdAt = n.createdAt,
        systemNotification = n,
        announcement = null,
        groupName = null,
        groupId = n.groupId;

  UnifiedNotificationItem.fromAnnouncement(
    CcViewNotificationsUsersRow a, {
    required bool isRead,
  })  : source = 'announcement',
        id = a.id!,
        title = a.title ?? 'Message',
        message = a.text,
        isRead = isRead,
        createdAt = a.updatedAt ?? DateTime.now(),
        systemNotification = null,
        announcement = a,
        groupName = a.groupName,
        groupId = a.groupId;
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

  List<UnifiedNotificationItem> get unreadItems => _items.where((n) => !n.isRead).toList();
  List<UnifiedNotificationItem> get readItems => _items.where((n) => n.isRead).toList();

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      final userId = SupaFlow.client.auth.currentUser?.id;

      final systemNotifs = await _repository.getNotificationsForCurrentUser();
      final systemItems = systemNotifs
          .map((n) => UnifiedNotificationItem.fromSystem(n))
          .toList();

      List<UnifiedNotificationItem> announcementItems = [];
      if (userId != null) {
        final memberships = await CcGroupMembersTable().queryRows(
          queryFn: (q) => q.eq('user_id', userId),
        );
        final groupIds = memberships.map((m) => m.groupId).whereType<int>().toList();

        if (groupIds.isNotEmpty) {
          final announcements = await CcViewNotificationsUsersTable().queryRows(
            queryFn: (q) => q.inFilter('group_id', groupIds),
          );

          if (announcements.isNotEmpty) {
            // Filtra mensagens privadas: broadcast + privadas para/do usuário atual
            final visible = announcements.where((a) =>
                a.recipientUserId == null ||
                a.recipientUserId == userId ||
                a.userId == userId).toList();

            if (visible.isNotEmpty) {
              final visibleIds = visible.map((a) => a.id!).toList();
              final reads = await CcSharingReadsTable().queryRows(
                queryFn: (q) =>
                    q.eq('user_id', userId).inFilter('sharing_id', visibleIds),
              );
              final readIds = reads.map((r) => r.experienceId).toSet();

              announcementItems = visible
                  .map((a) => UnifiedNotificationItem.fromAnnouncement(
                        a,
                        isRead: readIds.contains(a.id),
                      ))
                  .toList();
            }
          }
        }
      }

      final all = [...systemItems, ...announcementItems];
      all.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      _items = all;

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

    if (item.source == 'system' && item.systemNotification != null) {
      final success = await _repository.markAsRead(item.id);
      if (success) {
        item.isRead = true;
        _safeNotifyListeners();
      }
    } else if (item.source == 'announcement') {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId != null) {
        await _announcementRepository.markAnnouncementAsRead(item.id, userId);
        item.isRead = true;
        _safeNotifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    await _repository.markAllAsRead();
    if (userId != null) {
      for (final item in _items.where((i) => !i.isRead && i.source == 'announcement')) {
        await _announcementRepository.markAnnouncementAsRead(item.id, userId);
      }
    }
    await loadNotifications();
  }

  Future<void> deleteNotification(UnifiedNotificationItem item) async {
    if (item.source == 'system') {
      final success = await _repository.deleteNotification(item.id);
      if (success) {
        _items.removeWhere((n) => n.source == 'system' && n.id == item.id);
        _safeNotifyListeners();
      }
    }
    // Announcements are not deleted individually — they're group content
  }

  Future<void> deleteAllNotifications() async {
    final success = await _repository.deleteAllNotifications();
    if (success) {
      _items.removeWhere((n) => n.source == 'system');
      _safeNotifyListeners();
    }
  }

  Future<void> deleteReadNotifications() async {
    final success = await _repository.deleteReadNotifications();
    if (success) {
      _items.removeWhere((n) => n.source == 'system' && n.isRead);
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

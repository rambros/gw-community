import 'package:flutter/foundation.dart';
import '/data/repositories/in_app_notification_repository.dart';
import '/data/services/supabase/supabase.dart';

/// ViewModel for managing in-app notifications page state
///
/// Handles:
/// - Loading notifications for current user
/// - Marking notifications as read
/// - Mark all as read functionality
class InAppNotificationsViewModel extends ChangeNotifier {
  final InAppNotificationRepository _repository = InAppNotificationRepository();

  List<CcNotificationsRow> _notifications = [];
  List<CcNotificationsRow> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  bool get hasUnread => _notifications.any((n) => !n.isRead);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

  List<CcNotificationsRow> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  List<CcNotificationsRow> get readNotifications =>
      _notifications.where((n) => n.isRead).toList();

  Future<void> loadNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    _safeNotifyListeners();

    try {
      _notifications = await _repository.getNotificationsForCurrentUser();
      _isLoading = false;
      _safeNotifyListeners();
    } catch (e) {
      _errorMessage = 'Error loading notifications';
      _isLoading = false;
      _safeNotifyListeners();
    }
  }

  Future<void> markAsRead(int notificationId) async {
    final success = await _repository.markAsRead(notificationId);
    if (success) {
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        // Update local state by modifying the data map
        _notifications[index].isRead = true;
        _notifications[index].readAt = DateTime.now();
        _safeNotifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _repository.markAllAsRead();
    if (success) {
      await loadNotifications();
    }
  }

  /// Delete a single notification
  Future<void> deleteNotification(int notificationId) async {
    final success = await _repository.deleteNotification(notificationId);
    if (success) {
      _notifications.removeWhere((n) => n.id == notificationId);
      _safeNotifyListeners();
    }
  }

  /// Delete all notifications
  Future<void> deleteAllNotifications() async {
    final success = await _repository.deleteAllNotifications();
    if (success) {
      _notifications.clear();
      _safeNotifyListeners();
    }
  }

  /// Delete all read notifications
  Future<void> deleteReadNotifications() async {
    final success = await _repository.deleteReadNotifications();
    if (success) {
      _notifications.removeWhere((n) => n.isRead);
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

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Repository for managing in-app user notifications
///
/// Handles:
/// - Fetching notifications for current user
/// - Marking notifications as read
/// - Getting unread count
/// - Real-time notification streams
class InAppNotificationRepository {
  /// Get all notifications for current user, ordered by date descending
  Future<List<CcNotificationsRow>> getNotificationsForCurrentUser() async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return [];

      return await CcNotificationsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).order('created_at', ascending: false),
      );
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notification count for current user
  Future<int> getUnreadCount() async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return 0;

      final notifications = await CcNotificationsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).eq('is_read', false),
      );
      return notifications.length;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      await CcNotificationsTable().update(
        data: {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        },
        matchingRows: (rows) => rows.eq('id', notificationId),
      );
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return false;

      await CcNotificationsTable().update(
        data: {
          'is_read': true,
          'read_at': DateTime.now().toIso8601String(),
        },
        matchingRows: (rows) => rows.eq('user_id', userId).eq('is_read', false),
      );
      return true;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return false;
    }
  }

  /// Get notification by ID
  Future<CcNotificationsRow?> getNotificationById(int id) async {
    try {
      final result = await CcNotificationsTable().querySingleRow(
        queryFn: (q) => q.eq('id', id),
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      debugPrint('Error fetching notification: $e');
      return null;
    }
  }

  /// Stream of notifications for real-time updates
  Stream<List<CcNotificationsRow>> watchNotifications() {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return Stream.value([]);

    return SupaFlow.client
        .from('cc_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .map((list) => list.map((item) => CcNotificationsRow(item)).toList());
  }

  /// Stream of unread count for real-time updates
  Stream<int> watchUnreadCount() {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return SupaFlow.client
        .from('cc_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((list) => list.where((n) => n['is_read'] == false).length);
  }

  /// Delete a single notification
  Future<bool> deleteNotification(int notificationId) async {
    try {
      await CcNotificationsTable().delete(
        matchingRows: (rows) => rows.eq('id', notificationId),
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting notification: $e');
      return false;
    }
  }

  /// Delete all notifications for current user
  Future<bool> deleteAllNotifications() async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return false;

      await CcNotificationsTable().delete(
        matchingRows: (rows) => rows.eq('user_id', userId),
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting all notifications: $e');
      return false;
    }
  }

  /// Delete all read notifications for current user
  Future<bool> deleteReadNotifications() async {
    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return false;

      await CcNotificationsTable().delete(
        matchingRows: (rows) => rows.eq('user_id', userId).eq('is_read', true),
      );
      return true;
    } catch (e) {
      debugPrint('Error deleting read notifications: $e');
      return false;
    }
  }
}

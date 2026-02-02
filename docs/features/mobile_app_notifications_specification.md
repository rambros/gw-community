# Mobile App (medita-bk) - Notifications & Experience Moderation Specification

## Overview

This document provides detailed specifications for implementing the
notifications system and experience moderation integration in the **medita-bk**
mobile Flutter app.

---

## Features Summary

1. **Notifications Page**: View all notifications with read/unread states
2. **Notification Bell Icon**: Home page bell with unread count badge
3. **Experience Submission Updates**: Set pending status on new submissions
4. **Experience Detail Updates**: Show moderation status and handle user actions

---

## Data Layer

### 1. Notification Model

**File**: `lib/domain/models/notification_model.dart`

```dart
class NotificationModel {
  final int id;
  final String userId;
  final String type;
  final String title;
  final String? message;
  final bool isRead;
  final String? referenceType;
  final int? referenceId;
  final int? groupId;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? metadata;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    this.message,
    required this.isRead,
    this.referenceType,
    this.referenceId,
    this.groupId,
    required this.createdAt,
    this.readAt,
    this.metadata,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      referenceType: json['reference_type'] as String?,
      referenceId: json['reference_id'] as int?,
      groupId: json['group_id'] as int?,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null 
          ? DateTime.parse(json['read_at'] as String) 
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'type': type,
    'title': title,
    'message': message,
    'is_read': isRead,
    'reference_type': referenceType,
    'reference_id': referenceId,
    'group_id': groupId,
    'created_at': createdAt.toIso8601String(),
    'read_at': readAt?.toIso8601String(),
    'metadata': metadata,
  };

  /// Helper to check if this is an experience-related notification
  bool get isExperienceNotification => referenceType == 'experience';

  /// Get notification icon based on type
  IconData get icon {
    switch (type) {
      case 'experience_approved':
        return Icons.check_circle;
      case 'experience_rejected':
        return Icons.cancel;
      case 'experience_changes_requested':
        return Icons.edit_note;
      default:
        return Icons.notifications;
    }
  }

  /// Get notification color based on type
  Color get color {
    switch (type) {
      case 'experience_approved':
        return Colors.green;
      case 'experience_rejected':
        return Colors.red;
      case 'experience_changes_requested':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }
}
```

---

### 2. Notification Repository

**File**: `lib/data/repositories/notification_repository.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Get all notifications for current user, ordered by date descending
  Future<List<NotificationModel>> getNotificationsForCurrentUser() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _client
          .from('cc_notifications')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('Error fetching notifications: $e');
      return [];
    }
  }

  /// Get unread notification count for current user
  Future<int> getUnreadCount() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return 0;

      final response = await _client
          .from('cc_notifications')
          .select('id')
          .eq('user_id', userId)
          .eq('is_read', false);

      return (response as List).length;
    } catch (e) {
      debugPrint('Error fetching unread count: $e');
      return 0;
    }
  }

  /// Mark a notification as read
  Future<bool> markAsRead(int notificationId) async {
    try {
      await _client
          .from('cc_notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('id', notificationId);
      return true;
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
      return false;
    }
  }

  /// Mark all notifications as read for current user
  Future<bool> markAllAsRead() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) return false;

      await _client
          .from('cc_notifications')
          .update({
            'is_read': true,
            'read_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', userId)
          .eq('is_read', false);
      return true;
    } catch (e) {
      debugPrint('Error marking all as read: $e');
      return false;
    }
  }

  /// Get notification by ID
  Future<NotificationModel?> getNotificationById(int id) async {
    try {
      final response = await _client
          .from('cc_notifications')
          .select()
          .eq('id', id)
          .single();

      return NotificationModel.fromJson(response);
    } catch (e) {
      debugPrint('Error fetching notification: $e');
      return null;
    }
  }

  /// Stream of unread count for real-time updates
  Stream<int> watchUnreadCount() {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return Stream.value(0);

    return _client
        .from('cc_notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .map((list) => list.where((n) => n['is_read'] == false).length);
  }
}
```

---

### 3. Update Experience/Sharing Repository

Add moderation-related methods to your existing sharing repository:

**Add to**: `lib/data/repositories/sharing_repository.dart`

```dart
/// Submit experience for moderation (sets status to pending)
Future<bool> submitExperienceForModeration(int experienceId) async {
  try {
    await _client
        .from('cc_sharings')
        .update({
          'moderation_status': 'pending',
          'moderated_by': null,
          'moderated_at': null,
          'moderation_reason': null,
        })
        .eq('id', experienceId);
    return true;
  } catch (e) {
    debugPrint('Error submitting for moderation: $e');
    return false;
  }
}

/// Create new experience with pending moderation status
Future<int?> createExperience({
  required String title,
  required String text,
  required String privacy,
  int? groupId,
}) async {
  try {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final response = await _client
        .from('cc_sharings')
        .insert({
          'title': title,
          'text': text,
          'privacy': privacy,
          'user_id': userId,
          'group_id': groupId,
          'moderation_status': 'pending', // Always start as pending
          'visibility': 'hidden', // Hidden until approved
          'locked': false,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    // Create notification for moderators (done via database trigger or edge function)
    
    return response['id'] as int;
  } catch (e) {
    debugPrint('Error creating experience: $e');
    return null;
  }
}

/// Get moderation status for an experience
Future<Map<String, dynamic>?> getModerationStatus(int experienceId) async {
  try {
    final response = await _client
        .from('cc_sharings')
        .select('moderation_status, moderation_reason, moderated_at')
        .eq('id', experienceId)
        .single();

    return response;
  } catch (e) {
    debugPrint('Error fetching moderation status: $e');
    return null;
  }
}

/// Update and resubmit experience after changes requested
Future<bool> resubmitExperience(int experienceId, {
  String? title,
  String? text,
}) async {
  try {
    final updates = <String, dynamic>{
      'moderation_status': 'pending',
      'moderation_reason': null,
      'moderated_by': null,
      'moderated_at': null,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (title != null) updates['title'] = title;
    if (text != null) updates['text'] = text;

    await _client
        .from('cc_sharings')
        .update(updates)
        .eq('id', experienceId);

    return true;
  } catch (e) {
    debugPrint('Error resubmitting experience: $e');
    return false;
  }
}
```

---

## UI Layer

### 4. Notifications Page

**File**: `lib/ui/notifications/notifications_page/notifications_page.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'view_model/notifications_view_model.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  static const String routeName = 'notificationsPage';
  static const String routePath = '/notifications';

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  late NotificationsViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = NotificationsViewModel();
    _viewModel.loadNotifications();
  }

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _viewModel,
      child: Consumer<NotificationsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Notifications'),
              actions: [
                if (viewModel.hasUnread)
                  TextButton(
                    onPressed: () => viewModel.markAllAsRead(),
                    child: const Text('Mark all read'),
                  ),
              ],
            ),
            body: _buildBody(context, viewModel),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationsViewModel viewModel) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadNotifications(),
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: viewModel.notifications.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final notification = viewModel.notifications[index];
          return _NotificationTile(
            notification: notification,
            onTap: () => _handleNotificationTap(context, viewModel, notification),
          );
        },
      ),
    );
  }

  void _handleNotificationTap(
    BuildContext context,
    NotificationsViewModel viewModel,
    NotificationModel notification,
  ) async {
    // Mark as read
    await viewModel.markAsRead(notification.id);

    // Navigate based on notification type
    if (notification.isExperienceNotification && notification.referenceId != null) {
      // Navigate to experience detail page
      if (context.mounted) {
        Navigator.pushNamed(
          context,
          '/experience/${notification.referenceId}',
          arguments: {'experienceId': notification.referenceId},
        );
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: notification.color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(
          notification.icon,
          color: notification.color,
          size: 20,
        ),
      ),
      title: Text(
        notification.title,
        style: TextStyle(
          fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (notification.message != null)
            Text(
              notification.message!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          const SizedBox(height: 4),
          Text(
            _formatDate(notification.createdAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
      trailing: !notification.isRead
          ? Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            )
          : null,
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}h ago';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}d ago';
    } else {
      return DateFormat('MMM d').format(date);
    }
  }
}
```

---

### 5. Notifications ViewModel

**File**:
`lib/ui/notifications/notifications_page/view_model/notifications_view_model.dart`

```dart
import 'package:flutter/foundation.dart';
import '/data/repositories/notification_repository.dart';
import '/domain/models/notification_model.dart';

class NotificationsViewModel extends ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  bool _isDisposed = false;

  bool get hasUnread => _notifications.any((n) => !n.isRead);
  int get unreadCount => _notifications.where((n) => !n.isRead).length;

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
        // Update local state
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          userId: _notifications[index].userId,
          type: _notifications[index].type,
          title: _notifications[index].title,
          message: _notifications[index].message,
          isRead: true,
          referenceType: _notifications[index].referenceType,
          referenceId: _notifications[index].referenceId,
          groupId: _notifications[index].groupId,
          createdAt: _notifications[index].createdAt,
          readAt: DateTime.now(),
          metadata: _notifications[index].metadata,
        );
        _safeNotifyListeners();
      }
    }
  }

  Future<void> markAllAsRead() async {
    final success = await _repository.markAllAsRead();
    if (success) {
      await loadNotifications(); // Reload to get updated states
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
```

---

### 6. Notification Bell Widget (for Home Page)

**File**: `lib/ui/core/widgets/notification_bell/notification_bell_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/data/repositories/notification_repository.dart';

class NotificationBellWidget extends StatefulWidget {
  const NotificationBellWidget({super.key});

  @override
  State<NotificationBellWidget> createState() => _NotificationBellWidgetState();
}

class _NotificationBellWidgetState extends State<NotificationBellWidget> {
  final NotificationRepository _repository = NotificationRepository();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _repository.getUnreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: () {
            Navigator.pushNamed(context, '/notifications');
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _unreadCount > 99 ? '99+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
```

**Usage in Home Page AppBar**:

```dart
AppBar(
  title: const Text('Home'),
  actions: [
    const NotificationBellWidget(),
    // ... other actions
  ],
)
```

---

### 7. Experience Detail Page Updates

**Update**:
`lib/ui/experiences/experience_detail_page/experience_detail_page.dart`

Add a moderation status banner at the top:

```dart
Widget _buildModerationBanner(String status, String? reason) {
  Color backgroundColor;
  Color textColor;
  IconData icon;
  String message;

  switch (status) {
    case 'pending':
      backgroundColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
      icon = Icons.hourglass_empty;
      message = 'Your experience is pending moderation';
      break;
    case 'approved':
      backgroundColor = Colors.green.shade50;
      textColor = Colors.green.shade800;
      icon = Icons.check_circle;
      message = 'Your experience has been approved and is now visible';
      break;
    case 'rejected':
      backgroundColor = Colors.red.shade50;
      textColor = Colors.red.shade800;
      icon = Icons.cancel;
      message = reason ?? 'Your experience was not approved';
      break;
    case 'changes_requested':
      backgroundColor = Colors.amber.shade50;
      textColor = Colors.amber.shade800;
      icon = Icons.edit_note;
      message = reason ?? 'Changes have been requested for your experience';
      break;
    default:
      return const SizedBox.shrink();
  }

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: textColor.withOpacity(0.3)),
    ),
    child: Row(
      children: [
        Icon(icon, color: textColor, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            message,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        if (status == 'changes_requested')
          TextButton(
            onPressed: () => _enableEditMode(),
            child: const Text('Edit'),
          ),
      ],
    ),
  );
}

// In your build method, at the top of the content:
if (experience.moderationStatus != null)
  _buildModerationBanner(
    experience.moderationStatus!,
    experience.moderationReason,
  ),
```

---

## Routing

Add the notifications route to your router:

```dart
// In your router configuration
GoRoute(
  path: '/notifications',
  name: NotificationsPage.routeName,
  builder: (context, state) => const NotificationsPage(),
),
```

---

## File Structure Summary

```
lib/
├── domain/
│   └── models/
│       └── notification_model.dart          [NEW]
├── data/
│   └── repositories/
│       ├── notification_repository.dart     [NEW]
│       └── sharing_repository.dart          [UPDATE]
├── ui/
│   ├── core/
│   │   └── widgets/
│   │       └── notification_bell/
│   │           └── notification_bell_widget.dart   [NEW]
│   ├── notifications/
│   │   └── notifications_page/
│   │       ├── notifications_page.dart      [NEW]
│   │       └── view_model/
│   │           └── notifications_view_model.dart   [NEW]
│   ├── experiences/
│   │   └── experience_detail_page/
│   │       └── experience_detail_page.dart  [UPDATE - add moderation banner]
│   └── home/
│       └── home_page/
│           └── home_page.dart               [UPDATE - add NotificationBellWidget]
└── routing/
    └── router.dart                          [UPDATE - add notifications route]
```

---

## Testing Checklist

### Manual Testing

- [ ] Create new experience → verify `moderation_status = 'pending'`
- [ ] View notifications page (empty state)
- [ ] Receive notification after moderation → verify bell shows count
- [ ] Tap notification → mark as read + navigate to experience
- [ ] View approved experience → see green "Approved" banner
- [ ] View rejected experience → see red banner with reason
- [ ] View changes_requested experience → see amber banner with "Edit" button
- [ ] Tap "Edit" → enter edit mode
- [ ] Resubmit after editing → status resets to `pending`
- [ ] "Mark all read" → all notifications marked as read
- [ ] Pull to refresh → reload notifications list

---

## Notes

1. **Real-time Updates**: Consider using Supabase realtime subscriptions to
   update the bell badge without requiring manual refresh.

2. **Push Notifications**: This specification only covers in-app notifications.
   Push notifications can be added later using Firebase Cloud Messaging or
   Supabase Edge Functions.

3. **Pagination**: If users accumulate many notifications, consider adding
   pagination to the notifications list.

4. **Delete Notifications**: Consider adding ability to delete/dismiss
   notifications.

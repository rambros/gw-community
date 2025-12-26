import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:gw_community/data/repositories/in_app_notification_repository.dart';
import 'package:gw_community/data/services/app_badge_service.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Widget that displays a notification bell icon with unread count badge
///
/// Uses real-time stream to update the badge count automatically
class NotificationBellWidget extends StatefulWidget {
  const NotificationBellWidget({super.key});

  @override
  State<NotificationBellWidget> createState() => _NotificationBellWidgetState();
}

class _NotificationBellWidgetState extends State<NotificationBellWidget> {
  final InAppNotificationRepository _repository = InAppNotificationRepository();
  final AppBadgeService _badgeService = AppBadgeService();
  StreamSubscription<int>? _subscription;
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    _subscribeToUpdates();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  Future<void> _loadUnreadCount() async {
    final count = await _repository.getUnreadCount();
    if (mounted) {
      setState(() => _unreadCount = count);
      _badgeService.updateBadgeCount(count);
    }
  }

  void _subscribeToUpdates() {
    _subscription = _repository.watchUnreadCount().listen((count) {
      if (mounted) {
        setState(() => _unreadCount = count);
        _badgeService.updateBadgeCount(count);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: AppTheme.of(context).secondary,
            size: 28,
          ),
          onPressed: () {
            context.pushNamed(InAppNotificationsPage.routeName);
          },
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 4,
            top: 4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: AppTheme.of(context).error,
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

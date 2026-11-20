import 'dart:async';

import 'package:gw_community/data/repositories/in_app_notification_repository.dart';
import 'package:gw_community/data/services/app_badge_service.dart';

/// Keeps the phone's app-icon badge equal to the unread inbox.
///
/// The push sets that badge to 1. Group messages have their own count on the
/// group card. Opening a message marks the matching inbox alert as read, and
/// this sync writes the remaining inbox total back onto the icon.
class UnreadBadgeSync {
  UnreadBadgeSync._();

  static final UnreadBadgeSync instance = UnreadBadgeSync._();

  final InAppNotificationRepository _notifications = InAppNotificationRepository();
  final AppBadgeService _badge = AppBadgeService();

  Timer? _timer;
  int _generation = 0;

  /// Coalesces bursts, such as every group card reloading after a read.
  void schedule() {
    _timer?.cancel();
    _timer = Timer(const Duration(milliseconds: 80), () {
      _timer = null;
      unawaited(refreshNow());
    });
  }

  Future<int> refreshNow() async {
    _timer?.cancel();
    _timer = null;
    final generation = ++_generation;
    final total = await _notifications.getUnreadCount();
    if (generation != _generation) return total;
    await _badge.updateBadgeCount(total);
    if (generation != _generation) return refreshNow();
    return total;
  }
}

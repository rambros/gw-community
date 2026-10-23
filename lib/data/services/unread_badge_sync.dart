import 'dart:async';

import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/in_app_notification_repository.dart';
import 'package:gw_community/data/services/app_badge_service.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Keeps the phone's app-icon badge equal to the unread total shown in the app.
///
/// The push sets that badge to 1. Reading a group message updates the group
/// card and the Messages tab, but those screens do not open the home bell,
/// which was the only place that wrote the icon badge back.
class UnreadBadgeSync {
  UnreadBadgeSync._();

  static final UnreadBadgeSync instance = UnreadBadgeSync._();

  final InAppNotificationRepository _notifications = InAppNotificationRepository();
  final AnnouncementRepository _announcements = AnnouncementRepository();
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
    final userId = SupaFlow.client.auth.currentUser?.id;
    final notifications = await _notifications.getUnreadCount();
    final announcements = userId == null || userId.isEmpty
        ? 0
        : await _announcements.getTotalUnreadForUser(userId);
    final total = notifications + announcements;
    if (generation != _generation) return total;
    await _badge.updateBadgeCount(total);
    if (generation != _generation) return refreshNow();
    return total;
  }
}

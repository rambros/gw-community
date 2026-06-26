import 'package:flutter/material.dart';
import 'package:gw_community/data/services/push/push_notification_service.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class SetNotificationsViewModel extends ChangeNotifier {
  bool _pushEnabled = true;
  bool _inAppEnabled = true;
  bool _isLoading = true;
  String? _errorMessage;

  bool get pushEnabled => _pushEnabled;
  bool get inAppEnabled => _inAppEnabled;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  SetNotificationsViewModel() {
    _load();
  }

  Future<void> _load() async {
    _isLoading = true;
    notifyListeners();

    try {
      final userId = SupaFlow.client.auth.currentUser?.id;
      if (userId == null) return;

      final rows = await SupaFlow.client
          .from('cc_notification_preferences')
          .select('notification_type, enabled')
          .eq('user_id', userId)
          .inFilter('notification_type', ['push_global', 'in_app_global']);

      for (final row in rows as List<dynamic>) {
        if (row['notification_type'] == 'push_global') {
          _pushEnabled = row['enabled'] as bool? ?? true;
        } else if (row['notification_type'] == 'in_app_global') {
          _inAppEnabled = row['enabled'] as bool? ?? true;
        }
      }
    } catch (e) {
      _errorMessage = 'Failed to load preferences';
      debugPrint('SetNotificationsViewModel: load error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPushEnabled(bool value) async {
    _pushEnabled = value;
    notifyListeners();
    await _savePref('push_global', value);
    if (value) {
      await PushNotificationService.instance.initialize();
    } else {
      await PushNotificationService.instance.removeToken();
    }
  }

  Future<void> setInAppEnabled(bool value) async {
    _inAppEnabled = value;
    notifyListeners();
    await _savePref('in_app_global', value);
  }

  Future<void> _savePref(String type, bool enabled) async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;

    try {
      await SupaFlow.client.from('cc_notification_preferences').upsert(
        {
          'user_id': userId,
          'notification_type': type,
          'enabled': enabled,
          'updated_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,notification_type',
      );
    } catch (e) {
      debugPrint('SetNotificationsViewModel: save error: $e');
    }
  }
}

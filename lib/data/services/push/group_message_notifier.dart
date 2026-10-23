import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Asks the server to push a new group message to the members who can see it.
/// Failure here does not undo the message. The in-app badge comes from the
/// unread message itself.
class GroupMessageNotifier {
  static Future<void> notify(int sharingId) async {
    try {
      await SupaFlow.client.functions.invoke(
        'notify-group-message',
        body: {'sharing_id': sharingId},
      );
    } catch (e) {
      debugPrint('Group message push failed: $e');
    }
  }
}

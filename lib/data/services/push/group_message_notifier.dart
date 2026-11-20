import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Asks the server to alert members who can see a new group message.
/// The server writes an inbox row and sends the push. Failure here does not
/// undo the message. The group card still counts the message itself.
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

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Asks the server to ping facilitators about a new reply on a group message.
/// Failure here does not undo the comment. The in-app badge is computed from
/// the comment itself.
class CommentReplyNotifier {
  static Future<void> notify(int commentId) async {
    try {
      await SupaFlow.client.functions.invoke(
        'notify-comment-reply',
        body: {'comment_id': commentId},
      );
    } catch (e) {
      debugPrint('Comment reply push failed: $e');
    }
  }
}

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Asks the server to tell the group's facilitators about a new experience.
/// Failure here does not undo the post.
class ExperienceFacilitatorNotifier {
  static Future<void> notify(int sharingId) async {
    try {
      await SupaFlow.client.functions.invoke(
        'notify-facilitator-experience',
        body: {'sharing_id': sharingId},
      );
    } catch (e) {
      debugPrint('Experience facilitator notify failed: $e');
    }
  }
}

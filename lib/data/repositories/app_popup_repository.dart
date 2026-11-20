import 'package:gw_community/data/models/app_popup.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class AppPopupRepository {
  Future<AppPopup?> activePopup() async {
    final result = await SupaFlow.client.rpc('active_app_popup');
    if (result is! List || result.isEmpty) return null;
    final row = result.first;
    if (row is! Map) return null;
    return AppPopup.fromMap(Map<String, dynamic>.from(row));
  }

  Future<void> dismiss({
    required String popupId,
    required String userId,
    required String action,
  }) async {
    try {
      await SupaFlow.client.from('cc_app_popup_dismissals').insert({
        'popup_id': popupId,
        'auth_user_id': userId,
        'action': action,
      });
    } on PostgrestException catch (error) {
      if (error.code == '23505') return;
      rethrow;
    }
  }
}

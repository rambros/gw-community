import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Read-only journey queries for an app admin browsing as another member.
/// Used only when the requested id is not the signed-in auth user.
class AdminViewAsQueries {
  static bool isOtherUser(String userId) {
    final authId = SupaFlow.client.auth.currentUser?.id;
    return authId != null &&
        authId.isNotEmpty &&
        userId.isNotEmpty &&
        userId != authId;
  }

  static Future<List<CcViewUserJourneysRow>> journeys(String userId) async {
    try {
      final response = await SupaFlow.client.rpc(
        'admin_view_user_journeys',
        params: {'target_auth_user_id': userId},
      );
      if (response is! List) return [];
      return response
          .map((row) => CcViewUserJourneysRow(_asMap(row)))
          .toList();
    } catch (e) {
      debugPrint('admin_view_user_journeys failed: $e');
      return [];
    }
  }

  /// [journeyId] null returns every step of the member.
  static Future<List<CcViewUserStepsRow>> steps(
    String userId, {
    int? journeyId,
  }) async {
    try {
      final response = await SupaFlow.client.rpc(
        'admin_view_user_steps',
        params: {
          'target_auth_user_id': userId,
          'p_journey_id': journeyId,
        },
      );
      if (response is! List) return [];
      return response.map((row) => CcViewUserStepsRow(_asMap(row))).toList();
    } catch (e) {
      debugPrint('admin_view_user_steps failed: $e');
      return [];
    }
  }

  static Map<String, dynamic> _asMap(dynamic row) {
    if (row is Map<String, dynamic>) return row;
    return Map<String, dynamic>.from(row as Map);
  }
}

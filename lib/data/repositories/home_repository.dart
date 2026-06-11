import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class HomeRepository {
  /// Fetches the user profile by auth user ID
  Future<CcMembersRow?> getUserProfile(String authUserId) async {
    final rows = await CcMembersTable().queryRows(
      queryFn: (q) => q.eqOrNull('auth_user_id', authUserId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Fetches user journeys
  Future<List<CcUserJourneysRow>> getUserJourneys(String userId) async {
    // Filter user journeys by ensuring the related journey has status='published'
    return await CcUserJourneysTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', userId)
          .inFilter('cc_journeys.status', ['published', 'Published']).select('*, cc_journeys!inner(status)'),
    );
  }

  /// Fetches a specific journey by ID
  Future<CcJourneysRow?> getJourneyDetails(int journeyId) async {
    final rows = await CcJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', journeyId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Fetches view user journeys (for progress) for a specific journey
  Future<CcViewUserJourneysRow?> getUserJourneyProgress(String userId, int journeyId) async {
    final rows = await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).eqOrNull('journey_id', journeyId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Fetches all journey progress records for a user
  Future<List<CcViewUserJourneysRow>> getAllUserJourneyProgress(String userId) async {
    return await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
    );
  }

  /// Fetches all completed steps for a user across all journeys
  Future<List<CcViewUserStepsRow>> getAllCompletedSteps(String userId) async {
    return await CcViewUserStepsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).inFilter('step_status', ['completed', 'Completed']),
    );
  }

  /// Fetches upcoming events
  Future<List<CcEventsRow>> getUpcomingEvents() async {
    return await CcEventsTable().queryRows(
      queryFn: (q) =>
          q.gtOrNull('event_date', supaSerialize<DateTime>(DateTime.now())).order('event_date', ascending: true),
    );
  }

  /// Fetches available groups for the user
  Future<List<CcGroupsRow>> getAvailableGroups(String authUserId) async {
    final response = await SupaFlow.client.rpc(
      'get_available_groups',
      params: {
        'user_input': authUserId,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).where((group) {
        final privacy = group.groupPrivacy?.toLowerCase().trim();
        return privacy == 'public' || group.groupPrivacy == null;
      }).toList();
    }
    return [];
  }

  /// Returns module enable flags aggregated across all groups the user belongs to.
  /// Returns module enable flags for all groups the user belongs to.
  /// Tries a direct table join first (works when RLS allows user to read own rows).
  /// Falls back to the get_group_module_flags RPC (SECURITY DEFINER) if the direct
  /// query returns empty — which happens when RLS blocks it or the user has no groups.
  /// A module is enabled if ANY group has the flag true or null (null = default on).
  Future<({bool enableLibrary, bool enableJourney})> getGroupModuleFlags(String authUserId) async {
    // --- Primary: direct join query ---
    try {
      final response = await SupaFlow.client
          .from('cc_group_members')
          .select('cc_groups!inner(enable_library_module, enable_journey_module)')
          .eq('user_id', authUserId);

      if ((response as List).isNotEmpty) {
        bool anyLibrary = false;
        bool anyJourney = false;
        for (final row in response) {
          final g = row['cc_groups'] as Map<String, dynamic>?;
          if (g != null) {
            if (g['enable_library_module'] != false) anyLibrary = true;
            if (g['enable_journey_module'] != false) anyJourney = true;
          }
        }
        debugPrint('🔧 getGroupModuleFlags (direct): library=$anyLibrary journey=$anyJourney');
        return (enableLibrary: anyLibrary, enableJourney: anyJourney);
      }
    } catch (e) {
      debugPrint('🔧 getGroupModuleFlags direct query failed, trying RPC: $e');
    }

    // --- Fallback: SECURITY DEFINER RPC (bypasses RLS) ---
    try {
      final response = await SupaFlow.client.rpc(
        'get_group_module_flags',
        params: {'user_input': authUserId},
      );

      final rows = response as List?;
      if (rows == null || rows.isEmpty) {
        debugPrint('🔧 getGroupModuleFlags RPC: no groups found, defaulting to true');
        return (enableLibrary: true, enableJourney: true);
      }

      bool anyLibrary = false;
      bool anyJourney = false;
      for (final row in rows) {
        if (row['enable_library_module'] != false) anyLibrary = true;
        if (row['enable_journey_module'] != false) anyJourney = true;
      }
      debugPrint('🔧 getGroupModuleFlags (RPC): library=$anyLibrary journey=$anyJourney');
      return (enableLibrary: anyLibrary, enableJourney: anyJourney);
    } catch (e) {
      debugPrint('🔧 getGroupModuleFlags RPC failed: $e — defaulting to true');
      return (enableLibrary: true, enableJourney: true);
    }
  }

  /// Fetches groups the user is a member of
  Future<List<CcGroupsRow>> getMyGroups(String authUserId) async {
    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {
        'user_input': authUserId,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

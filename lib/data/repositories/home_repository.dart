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
    return await CcUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
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

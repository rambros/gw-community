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
    debugPrint('HomeRepository.getMyGroups: fetching for ID: $authUserId');
    debugPrint('HomeRepository.getMyGroups: ID type: ${authUserId.runtimeType}');
    debugPrint('HomeRepository.getMyGroups: ID length: ${authUserId.length}');

    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {
        'user_input': authUserId,
      },
    );

    debugPrint('HomeRepository.getMyGroups: response type: ${response.runtimeType}');
    debugPrint('HomeRepository.getMyGroups: received ${response is List ? response.length : 0} items');

    if (response is List) {
      debugPrint('HomeRepository.getMyGroups: Raw response: $response');
      final groups = response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
      debugPrint('HomeRepository.getMyGroups: Parsed ${groups.length} groups');
      for (final group in groups) {
        debugPrint('  - Group: ${group.name} (ID: ${group.id})');
      }
      return groups;
    }
    debugPrint('HomeRepository.getMyGroups: Response is not a list, returning empty');
    return [];
  }
}

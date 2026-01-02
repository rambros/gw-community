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
}

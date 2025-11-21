import '/data/services/supabase/supabase.dart';

class HomeRepository {
  /// Fetches the user profile by ID
  Future<CcUsersRow?> getUserProfile(String userId) async {
    final rows = await CcUsersTable().queryRows(
      queryFn: (q) => q.eqOrNull('id', userId),
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

  /// Fetches view user journeys (for progress)
  Future<CcViewUserJourneysRow?> getUserJourneyProgress(String userId) async {
    final rows = await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
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

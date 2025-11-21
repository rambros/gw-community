import '/backend/supabase/supabase.dart';

class UserProfileRepository {
  /// Fetches the user profile by ID.
  Future<CcUsersRow?> getUserProfile(String userId) async {
    final result = await CcUsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', userId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Resets the user's journey.
  /// Deletes the journey with ID 1 for the user and updates the user's started journeys list.
  Future<void> resetJourney(String userId, List<int> currentStartedJourneys) async {
    // Delete on cascade: user_journeys, user_activities, user_steps
    await CcUserJourneysTable().delete(
      matchingRows: (rows) => rows.eqOrNull('user_id', userId).eqOrNull('journey_id', 1),
    );

    // Update user's started_journeys list
    final updatedJourneys = currentStartedJourneys.where((e) => e != 1).toList();

    await CcUsersTable().update(
      data: {
        'started_journeys': updatedJourneys,
      },
      matchingRows: (rows) => rows.eqOrNull('id', userId),
    );
  }

  /// Updates the user profile.
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await CcUsersTable().update(
      data: data,
      matchingRows: (rows) => rows.eqOrNull('id', userId),
    );
  }

  /// Fetches the user's journal entries.
  Future<List<CcViewUserJournalRow>> getUserJournalEntries(String userId) async {
    return await CcViewUserJournalTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).order('date_completed'),
    );
  }

  /// Fetches a single journal entry by userActivityId.
  Future<CcViewUserJournalRow?> getJournalEntry(int userActivityId) async {
    final result = await CcViewUserJournalTable().querySingleRow(
      queryFn: (q) => q.eq('user_activity_id', userActivityId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> updateJournalEntry(int userActivityId, String content) async {
    await CcUserActivitiesTable().update(
      data: {
        'journal_saved': content,
      },
      matchingRows: (rows) => rows.eqOrNull(
        'id',
        userActivityId,
      ),
    );
  }

  /// Fetches the user's journeys.
  Future<List<CcViewUserJourneysRow>> getUserJourneys(String userId) async {
    return await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
    );
  }
}

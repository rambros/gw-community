import '/data/services/supabase/supabase.dart';

class UserProfileRepository {
  /// Fetches the user profile by ID.
  Future<CcMembersRow?> getUserProfile(String userId) async {
    final result = await CcMembersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', userId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Resets the user's journey.
  /// Deletes the journey with ID 1 for the user and updates the user's started journeys list.
  Future<void> resetJourney(String userId, List<int> currentStartedJourneys) async {
    // First, get the user_journey record to find its ID
    final userJourneys = await CcUserJourneysTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('journey_id', 1),
    );

    if (userJourneys.isNotEmpty) {
      final userJourneyId = userJourneys.first.id;

      // Get all user_steps for this journey to delete their activities
      final userSteps = await CcUserStepsTable().queryRows(
        queryFn: (q) => q.eq('user_journey_id', userJourneyId),
      );

      // Delete user_activities for each user_step
      for (final step in userSteps) {
        await CcUserActivitiesTable().delete(
          matchingRows: (rows) => rows.eq('user_step_id', step.id),
        );
      }

      // Delete user_steps for this journey
      await CcUserStepsTable().delete(
        matchingRows: (rows) => rows.eq('user_journey_id', userJourneyId),
      );

      // Delete user_journey
      await CcUserJourneysTable().delete(
        matchingRows: (rows) => rows.eq('id', userJourneyId),
      );
    }

    // Update user's started_journeys list
    final updatedJourneys = currentStartedJourneys.where((e) => e != 1).toList();

    await CcMembersTable().update(
      data: {
        'started_journeys': updatedJourneys,
      },
      matchingRows: (rows) => rows.eq('id', userId),
    );
  }

  /// Updates the user profile.
  Future<void> updateProfile(String userId, Map<String, dynamic> data) async {
    await CcMembersTable().update(
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

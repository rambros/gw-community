import '/backend/supabase/supabase.dart';

class JourneysRepository {
  Future<List<CcViewUserJourneysRow>> getUserJourneys(String userId) async {
    final result = await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
    );
    return result;
  }

  Future<List<CcViewAvailJourneysRow>> getAvailableJourneys(String userId) async {
    final result = await CcViewAvailJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
    );
    return result;
  }

  Future<CcJourneysRow?> getJourneyById(int journeyId) async {
    final results = await CcJourneysTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', journeyId),
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<CcViewUserJourneysRow?> getUserJourney(String userId, int journeyId) async {
    final results = await CcViewUserJourneysTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('user_id', userId).eqOrNull('journey_id', journeyId),
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<CcViewUserStepsRow>> getUserSteps(String userId, int journeyId) async {
    final result = await CcViewUserStepsTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).eqOrNull('journey_id', journeyId).order('step_number', ascending: true),
    );
    return result;
  }

  Future<void> updateUserStartedJourneys(String userId, List<int> startedJourneys) async {
    await CcUsersTable().update(
      data: {
        'started_journeys': startedJourneys,
      },
      matchingRows: (rows) => rows.eqOrNull('id', userId),
    );
  }
}

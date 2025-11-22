import '/data/services/supabase/supabase.dart';
import '/utils/flutter_flow_util.dart';

class StepActivitiesRepository {
  Future<List<CcViewUserActivitiesRow>> getUserActivities(
    String userId,
    int userStepId,
  ) async {
    final result = await CcViewUserActivitiesTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).eqOrNull('user_step_id', userStepId).order('order_in_step', ascending: true),
    );
    return result;
  }

  Future<void> completeActivity(int activityId) async {
    await CcUserActivitiesTable().update(
      data: {
        'date_completed': supaSerialize<DateTime>(getCurrentTimestamp),
        'activity_status': 'completed',
      },
      matchingRows: (rows) => rows.eqOrNull('id', activityId),
    );
  }

  Future<List<CcUserActivitiesRow>> getOpenActivities(
    String userId,
    int userStepId,
  ) async {
    final result = await CcUserActivitiesTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_step_id', userStepId).eqOrNull('activity_status', 'open').eqOrNull('user_id', userId),
    );
    return result;
  }

  Future<void> completeUserStep(int userStepId) async {
    await CcUserStepsTable().update(
      data: {
        'step_status': 'completed',
        'date_completed': supaSerialize<DateTime>(getCurrentTimestamp),
      },
      matchingRows: (rows) => rows.eqOrNull('id', userStepId),
    );
  }

  Future<List<CcViewUserStepsRow>> getClosedSteps(
    String userId,
    int userJourneyId,
  ) async {
    final result = await CcViewUserStepsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_journey_id', userJourneyId)
          .eqOrNull('user_id', userId)
          .eqOrNull('step_status', 'closed')
          .order('step_number', ascending: true),
    );
    return result;
  }

  Future<void> openNextStep(int userStepId) async {
    await CcUserStepsTable().update(
      data: {
        'step_status': 'open',
        'date_started': supaSerialize<DateTime>(getCurrentTimestamp),
      },
      matchingRows: (rows) => rows.eqOrNull('id', userStepId),
    );
  }

  Future<List<CcUserStepsRow>> getCompletedSteps(
    String userId,
    int userJourneyId,
  ) async {
    final result = await CcUserStepsTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_journey_id', userJourneyId).eqOrNull('user_id', userId).eqOrNull('step_status', 'completed'),
    );
    return result;
  }

  Future<void> updateUserJourney(int userJourneyId, int stepsCompleted) async {
    await CcUserJourneysTable().update(
      data: {
        'steps_completed': stepsCompleted,
      },
      matchingRows: (rows) => rows.eqOrNull('id', userJourneyId),
    );
  }

  Future<void> completeUserJourney(int userJourneyId) async {
    await CcUserJourneysTable().update(
      data: {
        'date_completed': supaSerialize<DateTime>(getCurrentTimestamp),
        'journey_status': 'completed',
      },
      matchingRows: (rows) => rows.eqOrNull('id', userJourneyId),
    );
  }
}

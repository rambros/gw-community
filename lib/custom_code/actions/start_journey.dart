// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<CcUserJourneysRow?> startJourney(
  String userId,
  int journeyId,
) async {
  // Cria o user journey e gera user steps/activities em lotes para evitar múltiplas idas ao Supabase

  if (userId.isEmpty) {
    return null;
  }

  final supabase = SupaFlow.client;
  final now = getCurrentTimestamp;
  final nowIsoString = supaSerialize<DateTime>(now);

  final userJourneyRow = await CcUserJourneysTable().insert({
    'user_id': userId,
    'journey_id': journeyId,
    'date_started': nowIsoString,
    'last_access_date': nowIsoString,
    'journey_status': 'started',
  });

  final journeySteps = await CcJourneyStepsTable().queryRows(
    queryFn: (q) =>
        q.eq('journey_id', journeyId).order('step_number', ascending: true),
  );

  if (journeySteps.isEmpty) {
    return userJourneyRow;
  }

  final userStepsPayload = <Map<String, dynamic>>[];
  for (var i = 0; i < journeySteps.length; i++) {
    final step = journeySteps[i];
    userStepsPayload.add({
      'user_journey_id': userJourneyRow.id,
      'user_id': userId,
      'journey_step_id': step.id,
      'date_started': nowIsoString,
      'step_status': i == 0 ? 'open' : 'closed',
    });
  }

  final userStepByJourneyStepId = <int, int>{};
  if (userStepsPayload.isNotEmpty) {
    final insertedUserStepsResponse =
        await supabase.from('cc_user_steps').insert(userStepsPayload).select();
    final insertedUserSteps = List<Map<String, dynamic>>.from(
        insertedUserStepsResponse as List<dynamic>);

    for (final row in insertedUserSteps) {
      final journeyStepId = row['journey_step_id'];
      final userStepId = row['id'];
      if (journeyStepId is int && userStepId is int) {
        userStepByJourneyStepId[journeyStepId] = userStepId;
      }
    }
  }

  if (userStepByJourneyStepId.isEmpty) {
    return userJourneyRow;
  }

  final stepActivities = await CcStepActivitiesTable().queryRows(
    queryFn: (q) => q
        .inFilterOrNull('step_id', userStepByJourneyStepId.keys.toList())
        .order('order_in_step', ascending: true),
  );

  if (stepActivities.isNotEmpty) {
    final userActivitiesPayload = <Map<String, dynamic>>[];
    for (final activity in stepActivities) {
      final stepId = activity.stepId;
      if (stepId == null) {
        continue;
      }
      final userStepId = userStepByJourneyStepId[stepId];
      if (userStepId == null) {
        continue;
      }
      userActivitiesPayload.add({
        'step_activity_id': activity.id,
        'user_step_id': userStepId,
        'user_id': userId,
        'date_started': nowIsoString,
        'activity_status': 'open',
        'journal_saved': activity.journal,
      });
    }

    if (userActivitiesPayload.isNotEmpty) {
      await supabase.from('cc_user_activities').insert(userActivitiesPayload);
    }
  }

  return userJourneyRow;
}

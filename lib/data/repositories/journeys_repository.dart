import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

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

  Future<void> updateUserStartedJourneys(String authUserId, List<int> startedJourneys) async {
    await CcMembersTable().update(
      data: {
        'started_journeys': startedJourneys,
      },
      matchingRows: (rows) => rows.eqOrNull('auth_user_id', authUserId),
    );
  }

  Future<CcUserJourneysRow?> startJourney(String userId, int journeyId) async {
    if (userId.isEmpty) {
      return null;
    }

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
      queryFn: (q) => q.eq('journey_id', journeyId).order('step_number', ascending: true),
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
        'step_status': i == 0 ? 'open' : 'locked',
      });
    }

    final userStepByJourneyStepId = <int, int>{};
    if (userStepsPayload.isNotEmpty) {
      final insertedUserStepsResponse = await SupaFlow.client.from('cc_user_steps').insert(userStepsPayload).select();
      final insertedUserSteps = List<Map<String, dynamic>>.from(insertedUserStepsResponse as List<dynamic>);

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
      queryFn: (q) =>
          q.inFilterOrNull('step_id', userStepByJourneyStepId.keys.toList()).order('order_in_step', ascending: true),
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
        await SupaFlow.client.from('cc_user_activities').insert(userActivitiesPayload);
      }
    }

    return userJourneyRow;
  }

  Future<void> resetJourney(String userId, int journeyId) async {
    // Buscar user_journey record
    final userJourneys = await CcUserJourneysTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('journey_id', journeyId),
    );

    if (userJourneys.isEmpty) {
      return; // Nada para resetar
    }

    final userJourneyId = userJourneys.first.id;

    // Buscar todos os user_steps da journey
    final userSteps = await CcUserStepsTable().queryRows(
      queryFn: (q) => q.eq('user_journey_id', userJourneyId),
    );

    // Deletar user_activities de cada user_step
    for (final step in userSteps) {
      await CcUserActivitiesTable().delete(
        matchingRows: (rows) => rows.eq('user_step_id', step.id),
      );
    }

    // Deletar user_steps
    await CcUserStepsTable().delete(
      matchingRows: (rows) => rows.eq('user_journey_id', userJourneyId),
    );

    // Deletar user_journey
    await CcUserJourneysTable().delete(
      matchingRows: (rows) => rows.eq('id', userJourneyId),
    );
  }

  Future<List<CcJourneysRow>> getJourneysForGroup(int groupId) async {
    // Query the new cc_group_journeys junction table
    final response = await SupaFlow.client
        .from('cc_group_journeys')
        .select('journey_id, cc_journeys!inner(*)')
        .eq('group_id', groupId)
        .order('featured', ascending: false);

    if ((response as List).isEmpty) {
      return [];
    }

    // Extract journey data from the response
    final List<CcJourneysRow> journeys = [];
    for (final row in response as List<dynamic>) {
      final journeyData = row['cc_journeys'] as Map<String, dynamic>?;
      if (journeyData != null) {
        journeys.add(CcJourneysRow(journeyData));
      }
    }

    return journeys;
  }

  /// Get journeys the user has started (for "My Journeys" section)
  Future<List<CcJourneysRow>> getMyJourneys(String userId) async {
    try {
      // Query user_journeys to get started journey IDs
      final userJourneys = await CcUserJourneysTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );

      if (userJourneys.isEmpty) return [];

      final journeyIds = userJourneys
          .map((uj) => uj.journeyId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (journeyIds.isEmpty) return [];

      // Get journey details (exclude draft journeys)
      final journeys = await CcJourneysTable().queryRows(
        queryFn: (q) => q.inFilter('id', journeyIds).neq('status', 'draft'),
      );

      return journeys;
    } catch (e) {
      return [];
    }
  }

  /// Get available journeys for the journey list
  /// Returns public journeys + private journeys (via groups) that user has NOT started yet
  Future<List<CcJourneysRow>> getAvailableJourneysForList(String userId) async {
    try {
      // Get journey IDs user has already started
      final userJourneys = await CcUserJourneysTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );

      final startedJourneyIds = userJourneys
          .map((uj) => uj.journeyId)
          .where((id) => id != null)
          .cast<int>()
          .toSet();

      // Get all public journeys (exclude draft journeys)
      final publicJourneys = await CcJourneysTable().queryRows(
        queryFn: (q) => q.eq('is_public', true).neq('status', 'draft'),
      );

      // Get private journeys via user's group memberships
      final privateJourneys = await _getPrivateJourneysForUser(userId);

      // Combine and filter out started journeys
      final allAvailable = <CcJourneysRow>[];
      final seenIds = <int>{};

      for (final journey in [...publicJourneys, ...privateJourneys]) {
        final journeyId = journey.id;
        if (!startedJourneyIds.contains(journeyId) && seenIds.add(journeyId)) {
          allAvailable.add(journey);
        }
      }

      return allAvailable;
    } catch (e) {
      debugPrint('Error in getAvailableJourneysForList: $e');
      return [];
    }
  }

  /// Get private journeys accessible via user's group memberships
  Future<List<CcJourneysRow>> _getPrivateJourneysForUser(String userId) async {
    try {
      // Get user's groups
      final groupMembers = await CcGroupMembersTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );

      if (groupMembers.isEmpty) return [];

      final groupIds = groupMembers
          .map((gm) => gm.groupId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (groupIds.isEmpty) return [];

      // Get journeys associated with these groups via cc_group_journeys
      // Exclude draft journeys
      final response = await SupaFlow.client
          .from('cc_group_journeys')
          .select('journey_id, cc_journeys!inner(*)')
          .inFilter('group_id', groupIds)
          .isFilter('deleted_at', null)
          .neq('cc_journeys.status', 'draft');

      if ((response as List).isEmpty) return [];

      final journeys = <CcJourneysRow>[];
      for (final row in response as List<dynamic>) {
        final journeyData = row['cc_journeys'] as Map<String, dynamic>?;
        if (journeyData != null) {
          journeys.add(CcJourneysRow(journeyData));
        }
      }

      return journeys;
    } catch (e) {
      return [];
    }
  }
}

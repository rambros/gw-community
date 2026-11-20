import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/admin_view_as_queries.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneysRepository {
  List<int>? _publishedJourneyIdsCache;
  DateTime? _lastCacheTime;
  static const _cacheDuration = Duration(minutes: 5);

  Future<List<int>> getPublishedJourneyIds() async {
    final now = DateTime.now();
    if (_publishedJourneyIdsCache != null &&
        _lastCacheTime != null &&
        now.difference(_lastCacheTime!) < _cacheDuration) {
      return _publishedJourneyIdsCache!;
    }

    final res = await CcJourneysTable().queryRows(
      queryFn: (q) =>
          q.inFilter('status', ['published', 'Published']).select('id'),
    );
    _publishedJourneyIdsCache = res.map((e) => e.id).whereType<int>().toList();
    _lastCacheTime = now;
    return _publishedJourneyIdsCache!;
  }

  Future<List<CcViewUserJourneysRow>> getUserJourneys(String userId) async {
    final publishedIds = await getPublishedJourneyIds();
    if (publishedIds.isEmpty) return [];

    if (AdminViewAsQueries.isOtherUser(userId)) {
      final rows = await AdminViewAsQueries.journeys(userId);
      return rows
          .where((row) =>
              publishedIds.contains(row.journeyId) &&
              _isJourneyInProgress(row.journeyStatus))
          .toList();
    }

    final result = await CcViewUserJourneysTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).inFilter('journey_id', publishedIds),
    );
    return result
        .where((row) => _isJourneyInProgress(row.journeyStatus))
        .toList();
  }

  Future<List<CcViewAvailJourneysRow>> getAvailableJourneys(
      String userId) async {
    final publishedIds = await getPublishedJourneyIds();
    if (publishedIds.isEmpty) return [];

    final result = await CcViewAvailJourneysTable().queryRows(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).inFilter('id', publishedIds),
    );
    return result;
  }

  Future<CcJourneysRow?> getJourneyById(int journeyId) async {
    final results = await CcJourneysTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', journeyId),
    );
    return results.isNotEmpty ? results.first : null;
  }

  /// `cc_journeys.fixed_language` for the journey that owns this step activity.
  Future<String?> fixedLanguageForStepActivity(int stepActivityId) async {
    final activities = await CcStepActivitiesTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', stepActivityId),
    );
    final stepId = activities.isNotEmpty ? activities.first.stepId : null;
    if (stepId == null) return null;

    final steps = await CcJourneyStepsTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', stepId),
    );
    final journeyId = steps.isNotEmpty ? steps.first.journeyId : null;
    if (journeyId == null) return null;

    final code = (await getJourneyById(journeyId))?.fixedLanguage?.trim();
    if (code == null || code.isEmpty) return null;
    return code;
  }

  Future<CcViewUserJourneysRow?> getUserJourney(
      String userId, int journeyId) async {
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final rows = await AdminViewAsQueries.journeys(userId);
      for (final row in rows) {
        if (row.journeyId == journeyId) return row;
      }
      return null;
    }

    final results = await CcViewUserJourneysTable().querySingleRow(
      queryFn: (q) =>
          q.eqOrNull('user_id', userId).eqOrNull('journey_id', journeyId),
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<CcViewUserStepsRow>> getUserSteps(
      String userId, int journeyId) async {
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final steps = await AdminViewAsQueries.steps(userId, journeyId: journeyId);
      steps.sort((a, b) => (a.stepNumber ?? 0).compareTo(b.stepNumber ?? 0));
      return steps;
    }

    final result = await CcViewUserStepsTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', userId)
          .eqOrNull('journey_id', journeyId)
          .order('step_number', ascending: true),
    );

    // Clean up duplicates if found
    await _cleanUpDuplicateUserSteps(result);

    final repaired = await _repairStepProgression(result);
    if (repaired) {
      return CcViewUserStepsTable().queryRows(
        queryFn: (q) => q
            .eqOrNull('user_id', userId)
            .eqOrNull('journey_id', journeyId)
            .order('step_number', ascending: true),
      );
    }

    return result;
  }

  /// Fixes progression when new journey steps were inserted as `closed`
  /// (DB trigger) and the app skipped ahead to a later `locked` step.
  Future<bool> _repairStepProgression(List<CcViewUserStepsRow> steps) async {
    if (steps.isEmpty) return false;

    final ordered = List<CcViewUserStepsRow>.from(steps)
      ..sort((a, b) => (a.stepNumber ?? 0).compareTo(b.stepNumber ?? 0));

    final firstIncompleteIndex =
        ordered.indexWhere((s) => s.stepStatus != 'completed');
    if (firstIncompleteIndex == -1) return false;

    var changed = false;
    for (var i = 0; i < ordered.length; i++) {
      final step = ordered[i];
      final stepId = step.id;
      if (stepId == null) continue;

      if (i == firstIncompleteIndex) {
        if (step.stepStatus != 'open') {
          await CcUserStepsTable().update(
            data: {
              'step_status': 'open',
              'date_started': supaSerialize(getCurrentTimestamp),
            },
            matchingRows: (rows) => rows.eq('id', stepId),
          );
          changed = true;
        }
      } else if (i > firstIncompleteIndex &&
          (step.stepStatus == 'open' || step.stepStatus == 'closed')) {
        await CcUserStepsTable().update(
          data: {'step_status': 'locked'},
          matchingRows: (rows) => rows.eq('id', stepId),
        );
        changed = true;
      }
    }

    return changed;
  }

  Future<void> _cleanUpDuplicateUserSteps(
      List<CcViewUserStepsRow> userSteps) async {
    // Group steps by journey_step_id
    final stepsByJourneyStepId = <int, List<CcViewUserStepsRow>>{};
    for (final step in userSteps) {
      final journeyStepId = step.journeyStepId;
      if (journeyStepId != null) {
        stepsByJourneyStepId.putIfAbsent(journeyStepId, () => []).add(step);
      }
    }

    // Find and delete duplicates (keep the most recent one)
    for (final entry in stepsByJourneyStepId.entries) {
      final steps = entry.value;
      if (steps.length > 1) {
        // Sort by id (most recent has higher id)
        steps.sort((a, b) => (b.id ?? 0).compareTo(a.id ?? 0));

        // Delete all except the first (most recent)
        for (var i = 1; i < steps.length; i++) {
          final stepToDelete = steps[i];
          if (stepToDelete.id != null) {
            await CcUserStepsTable().delete(
              matchingRows: (rows) => rows.eq('id', stepToDelete.id!),
            );
          }
        }
      }
    }
  }

  Future<List<CcJourneyStepsRow>> getJourneySteps(int journeyId) async {
    final result = await CcJourneyStepsTable().queryRows(
      queryFn: (q) =>
          q.eq('journey_id', journeyId).order('step_number', ascending: true),
    );
    return result;
  }

  Future<List<CcJourneySectionsRow>> getJourneySections(int journeyId) async {
    return await CcJourneySectionsTable().queryRows(
      queryFn: (q) =>
          q.eq('journey_id', journeyId).order('section_order', ascending: true),
    );
  }

  Future<void> updateUserStartedJourneys(
      String authUserId, List<int> startedJourneys) async {
    await CcMembersTable().update(
      data: {
        'started_journeys': startedJourneys,
      },
      matchingRows: (rows) => rows.eqOrNull('auth_user_id', authUserId),
    );
  }

  /// Creates the user journey, steps, and activities.
  /// Returns true when this call created them.
  Future<bool> startJourney(String userId, int journeyId) async {
    if (userId.isEmpty) {
      return false;
    }

    try {
      final created = await SupaFlow.client.rpc(
        'start_user_journey',
        params: {'p_journey_id': journeyId},
      );
      if (created == true) return true;
      // An enrollment left at the initial status still needs its first steps.
      // Older database functions treat any existing row as already started.
      final existing = await CcUserJourneysTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).eq('journey_id', journeyId),
      );
      if (existing.isEmpty ||
          _isJourneyInProgress(existing.first.journeyStatus)) {
        return false;
      }
      return await _startJourneyWithSeparateRequests(userId, journeyId);
    } on PostgrestException catch (error) {
      final missingFunction = error.code == 'PGRST202' ||
          error.message.contains('start_user_journey');
      if (!missingFunction) rethrow;
      return _startJourneyWithSeparateRequests(userId, journeyId);
    }
  }

  Future<bool> _startJourneyWithSeparateRequests(
      String userId, int journeyId) async {
    // Check if user has already started this journey
    final existingUserJourney = await CcUserJourneysTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('journey_id', journeyId),
    );

    final now = getCurrentTimestamp;
    final nowIsoString = supaSerialize<DateTime>(now);

    final CcUserJourneysRow userJourneyRow;
    if (existingUserJourney.isNotEmpty) {
      final existing = existingUserJourney.first;
      if (_isJourneyInProgress(existing.journeyStatus)) {
        return false;
      }
      await _deleteUserJourneyProgress(existing.id);
      await CcUserJourneysTable().update(
        data: {
          'date_started': nowIsoString,
          'date_completed': null,
          'last_access_date': nowIsoString,
          'steps_completed': 0,
          'journey_status': 'started',
        },
        matchingRows: (rows) => rows.eq('id', existing.id),
      );
      userJourneyRow = existing;
    } else {
      userJourneyRow = await CcUserJourneysTable().insert({
        'user_id': userId,
        'journey_id': journeyId,
        'date_started': nowIsoString,
        'last_access_date': nowIsoString,
        'journey_status': 'started',
      });
    }

    final journeySteps = await CcJourneyStepsTable().queryRows(
      queryFn: (q) =>
          q.eq('journey_id', journeyId).order('step_number', ascending: true),
    );

    if (journeySteps.isEmpty) {
      return true;
    }

    final userStepsPayload = <Map<String, dynamic>>[];
    for (var i = 0; i < journeySteps.length; i++) {
      final step = journeySteps[i];
      userStepsPayload.add({
        'user_journey_id': userJourneyRow.id,
        'user_id': userId,
        'journey_step_id': step.id,
        'date_started': i == 0 ? nowIsoString : null,
        'step_status': i == 0 ? 'open' : 'locked',
      });
    }

    final userStepByJourneyStepId = <int, int>{};
    if (userStepsPayload.isNotEmpty) {
      final insertedUserStepsResponse = await SupaFlow.client
          .from('cc_user_steps')
          .insert(userStepsPayload)
          .select();
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
      return true;
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
        });
      }

      if (userActivitiesPayload.isNotEmpty) {
        await SupaFlow.client
            .from('cc_user_activities')
            .insert(userActivitiesPayload);
      }
    }

    return true;
  }

  Future<void> resetJourney(String userId, int journeyId) async {
    final userJourneys = await CcUserJourneysTable().queryRows(
      queryFn: (q) => q.eq('user_id', userId).eq('journey_id', journeyId),
    );

    if (userJourneys.isEmpty) {
      return;
    }

    final userJourneyId = userJourneys.first.id;
    await _deleteUserJourneyProgress(userJourneyId);
    await CcUserJourneysTable().update(
      data: {
        'journey_status': 'non_started',
        'steps_completed': 0,
        'date_started': null,
        'date_completed': null,
      },
      matchingRows: (rows) => rows.eq('id', userJourneyId),
    );
  }

  /// `non_started` keeps access and shows the journey as not started.
  bool _isJourneyInProgress(String? status) =>
      status != null && status != 'non_started';

  void _collectJourneyAccess(
    int? journeyId,
    String? status,
    Set<int> startedJourneyIds,
    Set<int> initialJourneyIds,
  ) {
    if (journeyId == null) return;
    if (_isJourneyInProgress(status)) {
      startedJourneyIds.add(journeyId);
    } else if (status == 'non_started') {
      initialJourneyIds.add(journeyId);
    }
  }

  Future<void> _deleteUserJourneyProgress(int userJourneyId) async {
    final userSteps = await CcUserStepsTable().queryRows(
      queryFn: (q) => q.eq('user_journey_id', userJourneyId),
    );
    for (final step in userSteps) {
      await CcUserActivitiesTable().delete(
        matchingRows: (rows) => rows.eq('user_step_id', step.id),
      );
    }
    await CcUserStepsTable().delete(
      matchingRows: (rows) => rows.eq('user_journey_id', userJourneyId),
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
          .where((uj) => _isJourneyInProgress(uj.journeyStatus))
          .map((uj) => uj.journeyId)
          .where((id) => id != null)
          .cast<int>()
          .toList();

      if (journeyIds.isEmpty) return [];

      // Get journey details (exclude draft journeys)
      final journeys = await CcJourneysTable().queryRows(
        queryFn: (q) => q
            .inFilter('id', journeyIds)
            .inFilter('status', ['published', 'Published']),
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
      final startedJourneyIds = <int>{};
      final initialJourneyIds = <int>{};
      if (AdminViewAsQueries.isOtherUser(userId)) {
        final userJourneys = await AdminViewAsQueries.journeys(userId);
        for (final journey in userJourneys) {
          _collectJourneyAccess(
            journey.journeyId,
            journey.journeyStatus,
            startedJourneyIds,
            initialJourneyIds,
          );
        }
      } else {
        final userJourneys = await CcUserJourneysTable().queryRows(
          queryFn: (q) => q.eq('user_id', userId),
        );
        for (final journey in userJourneys) {
          _collectJourneyAccess(
            journey.journeyId,
            journey.journeyStatus,
            startedJourneyIds,
            initialJourneyIds,
          );
        }
      }

      // Get all public journeys (exclude draft journeys)
      final publicJourneys = await CcJourneysTable().queryRows(
        queryFn: (q) => q
            .eq('is_public', true)
            .inFilter('status', ['published', 'Published']),
      );
      debugPrint(
          '🔍 JourneyRepo: Found ${publicJourneys.length} public journeys');
      debugPrint('🔍 JourneyRepo: Started journey IDs: $startedJourneyIds');
      for (final journey in publicJourneys) {
        debugPrint(
            '  - ${journey.title} (ID: ${journey.id}, is_public: ${journey.isPublic}, status: ${journey.status})');
      }

      // Get private journeys via user's group memberships
      final privateJourneys = await _getPrivateJourneysForUser(userId);
      final enrolledJourneys = initialJourneyIds.isEmpty
          ? <CcJourneysRow>[]
          : await CcJourneysTable().queryRows(
              queryFn: (q) => q
                  .inFilter('id', initialJourneyIds.toList())
                  .inFilter('status', ['published', 'Published']),
            );

      // Combine and filter out started journeys
      final allAvailable = <CcJourneysRow>[];
      final seenIds = <int>{};

      for (final journey in [
        ...publicJourneys,
        ...privateJourneys,
        ...enrolledJourneys,
      ]) {
        final journeyId = journey.id;
        final isStarted = startedJourneyIds.contains(journeyId);
        debugPrint(
            '  Checking ${journey.title} (ID: $journeyId): started=$isStarted');
        if (!startedJourneyIds.contains(journeyId) && seenIds.add(journeyId)) {
          allAvailable.add(journey);
        }
      }

      debugPrint(
          '📊 JourneyRepo: ${allAvailable.length} journeys available (not started)');
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
          .inFilter('cc_journeys.status', ['published', 'Published']);

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

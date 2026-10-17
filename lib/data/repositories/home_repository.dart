import 'package:flutter/foundation.dart';
import 'package:gw_community/data/repositories/admin_view_as_queries.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';

class HomeRepository {
  /// Fetches the user profile by auth user ID
  Future<CcMembersRow?> getUserProfile(String authUserId) async {
    final rows = await CcMembersTable().queryRows(
      queryFn: (q) => q.eqOrNull('auth_user_id', authUserId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Records app open / session resume for admin Members "Last Access".
  Future<void> touchLastAccess() async {
    try {
      await SupaFlow.client.rpc('touch_member_last_access');
    } catch (e) {
      debugPrint('touch_member_last_access failed: $e');
    }
  }

  /// Fetches user journeys
  Future<List<CcUserJourneysRow>> getUserJourneys(String userId) async {
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final progress = await getAllUserJourneyProgress(userId);
      return progress
          .map(
            (row) => CcUserJourneysRow({
              'id': row.id,
              'journey_id': row.journeyId,
              'user_id': row.userId,
              'steps_completed': row.stepsCompleted,
              'last_access_date': row.lastAccessDate?.toUtc().toIso8601String(),
              'journey_status': row.journeyStatus,
            }),
          )
          .toList();
    }

    // Filter user journeys by ensuring the related journey has status='published'
    return await CcUserJourneysTable().queryRows(
      queryFn: (q) => q
          .eqOrNull('user_id', userId)
          .inFilter('cc_journeys.status', ['published', 'Published']).select('*, cc_journeys!inner(status)'),
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
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final rows = await AdminViewAsQueries.journeys(userId);
      for (final row in rows) {
        if (row.journeyId == journeyId) return row;
      }
      return null;
    }

    final rows = await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).eqOrNull('journey_id', journeyId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  /// Fetches all journey progress records for a user
  Future<List<CcViewUserJourneysRow>> getAllUserJourneyProgress(String userId) async {
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final rows = await AdminViewAsQueries.journeys(userId);
      if (rows.isEmpty) return [];
      final journeyIds = rows.map((j) => j.journeyId).whereType<int>().toList();
      if (journeyIds.isEmpty) return [];
      final published = await CcJourneysTable().queryRows(
        queryFn: (q) => q.inFilter('id', journeyIds).inFilter('status', ['published', 'Published']),
      );
      final publishedIds = published.map((j) => j.id).toSet();
      return rows.where((j) => publishedIds.contains(j.journeyId)).toList();
    }

    return await CcViewUserJourneysTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId),
    );
  }

  /// Fetches all completed steps for a user across all journeys
  Future<List<CcViewUserStepsRow>> getAllCompletedSteps(String userId) async {
    if (AdminViewAsQueries.isOtherUser(userId)) {
      final steps = await AdminViewAsQueries.steps(userId);
      return steps.where((step) {
        final status = step.stepStatus?.toLowerCase().trim();
        return status == 'completed';
      }).toList();
    }

    return await CcViewUserStepsTable().queryRows(
      queryFn: (q) => q.eqOrNull('user_id', userId).inFilter('step_status', ['completed', 'Completed']),
    );
  }

  /// Events still ahead of [now]. A repeating event stays as one row and
  /// is listed on its next date until that day has passed.
  Future<List<CcEventsRow>> getUpcomingEvents({DateTime? now}) async {
    final refreshedAt = now ?? DateTime.now();
    final startOfToday = DateTime(refreshedAt.year, refreshedAt.month, refreshedAt.day);
    final day =
        '${startOfToday.year.toString().padLeft(4, '0')}-${startOfToday.month.toString().padLeft(2, '0')}-${startOfToday.day.toString().padLeft(2, '0')}';
    final rows = await CcEventsTable().queryRows(
      queryFn: (q) => q
          .or('event_date.gte.$day,recurrence.in.(weekly,biweekly,monthly)')
          .order('event_date', ascending: true),
    );
    final upcoming = rows.where((event) => _isListed(event, refreshedAt)).toList();
    upcoming.sort((a, b) {
      final aStart = _sortStart(a, refreshedAt);
      final bStart = _sortStart(b, refreshedAt);
      if (aStart == null && bStart == null) return 0;
      if (aStart == null) return 1;
      if (bStart == null) return -1;
      return aStart.compareTo(bStart);
    });
    return upcoming;
  }

  bool _isListed(CcEventsRow event, DateTime refreshedAt) {
    if (EventRecurrence.repeats(event.recurrence)) {
      final anchor = event.eventDate;
      if (anchor == null) return false;
      return upcomingEventWindow(
            anchor: anchor,
            end: event.endDate,
            recurrence: event.recurrence,
            until: event.recurrenceUntil,
            now: refreshedAt,
          ) !=
          null;
    }
    return _occursAfter(event, refreshedAt);
  }

  DateTime? _sortStart(CcEventsRow event, DateTime refreshedAt) {
    if (EventRecurrence.repeats(event.recurrence) && event.eventDate != null) {
      final window = upcomingEventWindow(
        anchor: event.eventDate!,
        end: event.endDate,
        recurrence: event.recurrence,
        until: event.recurrenceUntil,
        now: refreshedAt,
      );
      if (window != null) {
        final clock = event.eventTime?.time?.toLocal();
        if (clock == null) return window.start;
        return DateTime(window.start.year, window.start.month, window.start.day, clock.hour, clock.minute);
      }
    }
    return _eventStart(event);
  }

  DateTime? _eventStart(CcEventsRow event) {
    final date = event.eventDate?.toLocal();
    if (date == null) return null;
    final clock = event.eventTime?.time?.toLocal();
    if (clock == null) {
      return DateTime(date.year, date.month, date.day);
    }
    return DateTime(date.year, date.month, date.day, clock.hour, clock.minute);
  }

  bool _occursAfter(CcEventsRow event, DateTime refreshedAt) {
    final today = DateTime(refreshedAt.year, refreshedAt.month, refreshedAt.day);
    if (event.eventType == 'multi_day') {
      final end = (event.endDate ?? event.eventDate)?.toLocal();
      if (end == null) return false;
      final lastDay = DateTime(end.year, end.month, end.day);
      return !lastDay.isBefore(today);
    }
    final date = event.eventDate?.toLocal();
    if (date == null) return false;
    final day = DateTime(date.year, date.month, date.day);
    return !day.isBefore(today);
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

  /// Returns module enable flags aggregated across all groups the user belongs to.
  /// Tries a direct table join first (works when RLS allows user to read own rows).
  /// Falls back to the get_group_module_flags RPC (SECURITY DEFINER) if the direct
  /// query returns empty — which happens when RLS blocks it or the user has no groups.
  /// A module is enabled if ANY group has the flag true or null (null = default on).
  Future<({bool enableLibrary, bool enableJourney, bool enableCommunity})> getGroupModuleFlags(String authUserId) async {
    // --- Primary: direct join query ---
    try {
      final response = await SupaFlow.client
          .from('cc_group_members')
          .select('cc_groups!inner(enable_library_module, enable_journey_module, enable_community_module)')
          .eq('user_id', authUserId);

      if ((response as List).isNotEmpty) {
        bool anyLibrary = false;
        bool anyJourney = false;
        bool anyCommunity = false;
        for (final row in response) {
          final g = row['cc_groups'] as Map<String, dynamic>?;
          if (g != null) {
            if (g['enable_library_module'] != false) anyLibrary = true;
            if (g['enable_journey_module'] != false) anyJourney = true;
            if (g['enable_community_module'] != false) anyCommunity = true;
          }
        }
        debugPrint('🔧 getGroupModuleFlags (direct): library=$anyLibrary journey=$anyJourney community=$anyCommunity');
        return (enableLibrary: anyLibrary, enableJourney: anyJourney, enableCommunity: anyCommunity);
      }
    } catch (e) {
      debugPrint('🔧 getGroupModuleFlags direct query failed, trying RPC: $e');
    }

    // --- Fallback: SECURITY DEFINER RPC (bypasses RLS) ---
    try {
      final response = await SupaFlow.client.rpc(
        'get_group_module_flags',
        params: {'user_input': authUserId},
      );

      final rows = response as List?;
      if (rows == null || rows.isEmpty) {
        debugPrint('🔧 getGroupModuleFlags RPC: no groups found, defaulting to true');
        return (enableLibrary: true, enableJourney: true, enableCommunity: true);
      }

      bool anyLibrary = false;
      bool anyJourney = false;
      bool anyCommunity = false;
      for (final row in rows) {
        if (row['enable_library_module'] != false) anyLibrary = true;
        if (row['enable_journey_module'] != false) anyJourney = true;
        if (row['enable_community_module'] != false) anyCommunity = true;
      }
      debugPrint('🔧 getGroupModuleFlags (RPC): library=$anyLibrary journey=$anyJourney community=$anyCommunity');
      return (enableLibrary: anyLibrary, enableJourney: anyJourney, enableCommunity: anyCommunity);
    } catch (e) {
      debugPrint('🔧 getGroupModuleFlags RPC failed: $e — defaulting to true');
      return (enableLibrary: true, enableJourney: true, enableCommunity: true);
    }
  }

  /// Fetches groups the user is a member of
  Future<List<CcGroupsRow>> getMyGroups(String authUserId) async {
    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {
        'user_input': authUserId,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
    }
    return [];
  }
}

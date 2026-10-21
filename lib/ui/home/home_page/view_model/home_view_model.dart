import 'package:flutter/material.dart';

import 'package:gw_community/data/models/structs/index.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_access.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class HomeViewModel extends ChangeNotifier {
  final HomeRepository _repository;

  HomeViewModel({
    required HomeRepository repository,
  }) : _repository = repository;

  /// Gets the current user ID dynamically from Supabase auth
  String get currentUserUid => SupaFlow.client.auth.currentUser?.id ?? '';

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  CcMembersRow? _userProfile;
  CcMembersRow? get userProfile => _userProfile;

  List<CcUserJourneysRow> _userJourneys = [];
  List<CcUserJourneysRow> get userJourneys => _userJourneys;

  List<CcViewUserJourneysRow> _userJourneyProgressList = [];
  List<CcViewUserJourneysRow> get userJourneyProgressList =>
      _userJourneyProgressList;

  List<CcEventsRow> _upcomingEvents = [];
  List<CcEventsRow> get upcomingEvents => _upcomingEvents;

  List<CcGroupsRow> _userGroups = [];
  List<CcGroupsRow> get userGroups => _userGroups;

  List<CcGroupsRow> _publicGroups = [];
  List<CcGroupsRow> get publicGroups => _publicGroups;

  // ========== COMMANDS ==========

  /// [blocking] replaces the page with the first-load spinner.
  /// Returning to the home and pull-to-refresh keep the current list
  /// on screen until the new data arrives.
  Future<void> loadData({bool blocking = true}) async {
    if (blocking) {
      _setLoading(true);
    }
    _clearError();

    try {
      final viewingAs = ViewAsSession.instance.isActive;
      final subjectUserId =
          ViewAsSession.instance.subjectUserId(currentUserUid);
      await _repository.touchLastAccess();
      await Future.wait([
        if (!viewingAs) _loadUserProfile(),
        _loadUserJourneys(subjectUserId),
        _loadUpcomingEvents(),
        _loadGroups(subjectUserId),
        _loadAllUserJourneyProgress(subjectUserId),
      ]);
      _upcomingEvents = _eventsVisibleTo(subjectUserId);
    } catch (e) {
      _setError('Error loading home data: $e');
    } finally {
      if (blocking) {
        _setLoading(false);
      } else {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> _loadUserProfile() async {
    _userProfile = await _repository.getUserProfile(currentUserUid);

    // Update global state (FFAppState) as per original code requirement
    // "FFAppState().loginUser = LoginUserStruct(...)"
    if (_userProfile != null) {
      FFAppState().loginUser = LoginUserStruct(
        fullName: _userProfile?.displayName,
        email: _userProfile?.email,
        userId: _userProfile?.id,
        roles: _userProfile?.userRole ?? [],
        displayName: _userProfile?.displayName,
        photoUrl: _userProfile?.photoUrl == null || _userProfile?.photoUrl == ''
            ? ''
            : _userProfile?.photoUrl,
        firstName: _userProfile?.firstName,
      );
    }
  }

  Future<void> _loadUserJourneys(String subjectUserId) async {
    _userJourneys = await _repository.getUserJourneys(subjectUserId);

    // Update global state
    FFAppState().listStartedJourneys =
        _userJourneys.map((e) => e.journeyId).withoutNulls.toList().cast<int>();
    FFAppState().hasStartedJourney = _userJourneys.isNotEmpty;
  }

  Future<void> _loadAllUserJourneyProgress(String subjectUserId) async {
    try {
      // Fetch both progress and completed steps lists in parallel
      final results = await Future.wait([
        _repository.getAllUserJourneyProgress(subjectUserId),
        _repository.getAllCompletedSteps(subjectUserId),
      ]);

      final allProgress = results[0] as List<CcViewUserJourneysRow>;
      final allCompletedSteps = results[1] as List<CcViewUserStepsRow>;

      // Map to store unique journey_step_ids by journey_id for deduplication
      final uniqueStepsByJourney = <int, Set<int>>{};
      for (final step in allCompletedSteps) {
        if (step.journeyId != null && step.journeyStepId != null) {
          uniqueStepsByJourney
              .putIfAbsent(step.journeyId!, () => {})
              .add(step.journeyStepId!);
        }
      }

      // Filter to keep only PUBLISHED journeys (check cc_journeys.status, not user journey_status)
      // Since the view doesn't expose cc_journeys.status, we need to query it separately
      final publishedJourneyIds = <int>{};
      if (allProgress.isNotEmpty) {
        final journeyIds = allProgress
            .map((j) => j.journeyId)
            .where((id) => id != null)
            .cast<int>()
            .toList();
        if (journeyIds.isNotEmpty) {
          final publishedJourneys = await CcJourneysTable().queryRows(
            queryFn: (q) => q
                .inFilter('id', journeyIds)
                .inFilter('status', ['published', 'Published']),
          );
          publishedJourneyIds.addAll(publishedJourneys.map((j) => j.id));
        }
      }

      // Filter to only include published journeys
      final finalProgressList = <CcViewUserJourneysRow>[];
      for (final progress in allProgress) {
        final journeyId = progress.journeyId;
        final isPublished = publishedJourneyIds.contains(journeyId);

        if (isPublished) {
          // Update stepsCompleted count with deduplicated value
          progress.stepsCompleted =
              uniqueStepsByJourney[journeyId]?.length ?? 0;
          finalProgressList.add(progress);
        }
      }

      _userJourneyProgressList = finalProgressList;
    } catch (e) {
      debugPrint('Error loading all user journey progress: $e');
    }
  }

  Future<void> _loadUpcomingEvents() async {
    _upcomingEvents = await _repository.getUpcomingEvents();
  }

  /// The signed-in user already receives only their rows from RLS.
  /// View-as keeps the admin session, so the same list has to be cut
  /// down to the member's groups here.
  List<CcEventsRow> _eventsVisibleTo(String userId) {
    final memberGroupIds = _userGroups.map((group) => group.id).toSet();
    return _upcomingEvents
        .where(
          (event) => eventVisibleToUser(
            visibility: event.visibility,
            groupId: event.groupId,
            facilitatorId: event.facilitatorId,
            userId: userId,
            memberGroupIds: memberGroupIds,
          ),
        )
        .toList();
  }

  Future<void> _loadGroups(String subjectUserId) async {
    // Use auth_user_id directly (cc_group_members.user_id stores auth_user_id, not member.id)
    _userGroups = await _repository.getMyGroups(subjectUserId);
    _publicGroups = await _repository.getAvailableGroups(subjectUserId);
  }

  // ========== HELPER METHODS ==========

  String? getGroupNameById(int? groupId) => _groupById(groupId)?.name;

  String? groupImageUrlById(int? groupId) {
    final url = _groupById(groupId)?.groupImageUrl?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  CcGroupsRow? _groupById(int? groupId) {
    if (groupId == null) return null;
    for (final group in _userGroups) {
      if (group.id == groupId) return group;
    }
    for (final group in _publicGroups) {
      if (group.id == groupId) return group;
    }
    return null;
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

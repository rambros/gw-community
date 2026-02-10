import 'package:flutter/material.dart';

import 'package:gw_community/data/models/structs/index.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
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
  List<CcViewUserJourneysRow> get userJourneyProgressList => _userJourneyProgressList;

  List<CcEventsRow> _upcomingEvents = [];
  List<CcEventsRow> get upcomingEvents => _upcomingEvents;

  List<CcGroupsRow> _userGroups = [];
  List<CcGroupsRow> get userGroups => _userGroups;

  List<CcGroupsRow> _publicGroups = [];
  List<CcGroupsRow> get publicGroups => _publicGroups;

  // ========== COMMANDS ==========

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _loadUserProfile(),
        _loadUserJourneys(),
        _loadUpcomingEvents(),
        _loadGroups(),
        _loadAllUserJourneyProgress(),
      ]);
    } catch (e) {
      _setError('Error loading home data: $e');
    } finally {
      _setLoading(false);
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
        photoUrl: _userProfile?.photoUrl == null || _userProfile?.photoUrl == '' ? '' : _userProfile?.photoUrl,
        firstName: _userProfile?.firstName,
      );
    }
  }

  Future<void> _loadUserJourneys() async {
    _userJourneys = await _repository.getUserJourneys(currentUserUid);

    // Update global state
    FFAppState().listStartedJourneys = _userJourneys.map((e) => e.journeyId).withoutNulls.toList().cast<int>();
    FFAppState().hasStartedJourney = _userJourneys.isNotEmpty;
  }

  Future<void> _loadAllUserJourneyProgress() async {
    try {
      // Fetch both progress and completed steps lists in parallel
      final results = await Future.wait([
        _repository.getAllUserJourneyProgress(currentUserUid),
        _repository.getAllCompletedSteps(currentUserUid),
      ]);

      final allProgress = results[0] as List<CcViewUserJourneysRow>;
      final allCompletedSteps = results[1] as List<CcViewUserStepsRow>;

      // Map to store unique journey_step_ids by journey_id for deduplication
      final uniqueStepsByJourney = <int, Set<int>>{};
      for (final step in allCompletedSteps) {
        if (step.journeyId != null && step.journeyStepId != null) {
          uniqueStepsByJourney.putIfAbsent(step.journeyId!, () => {}).add(step.journeyStepId!);
        }
      }

      // Filter to keep only PUBLISHED journeys (check cc_journeys.status, not user journey_status)
      // Since the view doesn't expose cc_journeys.status, we need to query it separately
      final publishedJourneyIds = <int>{};
      if (allProgress.isNotEmpty) {
        final journeyIds = allProgress.map((j) => j.journeyId).where((id) => id != null).cast<int>().toList();
        if (journeyIds.isNotEmpty) {
          final publishedJourneys = await CcJourneysTable().queryRows(
            queryFn: (q) => q.inFilter('id', journeyIds).inFilter('status', ['published', 'Published']),
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
          progress.stepsCompleted = uniqueStepsByJourney[journeyId]?.length ?? 0;
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

  Future<void> _loadGroups() async {
    // Use auth_user_id directly (cc_group_members.user_id stores auth_user_id, not member.id)
    _userGroups = await _repository.getMyGroups(currentUserUid);
    _publicGroups = await _repository.getAvailableGroups(currentUserUid);
  }

  // ========== HELPER METHODS ==========

  String? getGroupNameById(int? groupId) {
    if (groupId == null) return null;
    try {
      final group = _userGroups.firstWhere(
        (g) => g.id == groupId,
        orElse: () => _publicGroups.firstWhere(
          (g) => g.id == groupId,
        ),
      );
      return group.name;
    } catch (e) {
      return null;
    }
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

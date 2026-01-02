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

  CcJourneysRow? _journeyDetails;
  CcJourneysRow? get journeyDetails => _journeyDetails;

  bool get isJourney1Started => _userJourneys.any((j) => j.journeyId == 1);

  CcViewUserJourneysRow? _userJourneyProgress;
  CcViewUserJourneysRow? get userJourneyProgress => _userJourneyProgress;

  List<CcEventsRow> _upcomingEvents = [];
  List<CcEventsRow> get upcomingEvents => _upcomingEvents;

  // ========== COMMANDS ==========

  Future<void> loadData() async {
    _setLoading(true);
    _clearError();

    try {
      await Future.wait([
        _loadUserProfile(),
        _loadUserJourneys(),
        _loadUpcomingEvents(),
      ]);

      // Always load journey ID 1 details as requested
      // This ensures the user sees the first journey with a "Start" button even if not yet started
      await _loadJourneyDetails(1);

      if (_userJourneys.isNotEmpty) {
        await _loadUserJourneyProgress();
      }
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

  Future<void> _loadJourneyDetails(int journeyId) async {
    _journeyDetails = await _repository.getJourneyDetails(journeyId);
  }

  Future<void> _loadUserJourneyProgress() async {
    _userJourneyProgress = await _repository.getUserJourneyProgress(currentUserUid, 1);
  }

  Future<void> _loadUpcomingEvents() async {
    _upcomingEvents = await _repository.getUpcomingEvents();
  }

  // ========== HELPER METHODS ==========

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

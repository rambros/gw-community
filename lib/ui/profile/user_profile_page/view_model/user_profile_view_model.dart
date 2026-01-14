import 'package:flutter/material.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/repositories/user_profile_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class UserProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserProfileViewModel({
    required UserProfileRepository repository,
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

  // ========== COMMANDS ==========

  /// Loads the user profile data.
  Future<void> loadUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      _userProfile = await _repository.getUserProfile(currentUserUid);
      if (_userProfile == null && currentUserUid.isNotEmpty) {
        debugPrint('Profile not found for $currentUserUid, logging out.');
        await _signOut();
      }
      notifyListeners();
    } catch (e) {
      _setError('Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Resets the user's journey.
  Future<void> resetJourneyCommand() async {
    if (_userProfile == null) return;

    _setLoading(true);
    _clearError();

    try {
      // The original code used userProfilePageCcMembersRow!.startedJourneys.toList()
      // We assume _userProfile is loaded.
      final currentStartedJourneys = _userProfile!.startedJourneys;

      await _repository.resetJourney(currentUserUid, currentStartedJourneys);

      // Auth logout logic from original code
      await _signOut();
    } catch (e) {
      _setError('Error resetting journey: $e');
      rethrow; // Allow UI to handle specific navigation/feedback if needed, or just catch here.
    } finally {
      _setLoading(false);
    }
  }

  /// Resets the onboarding flag stored locally so onboarding runs again.
  Future<void> resetOnboardingCommand() async {
    _clearError();

    try {
      FFAppState().update(() {
        FFAppState().onboardingDone = false;
      });
    } catch (e) {
      _setError('Error resetting onboarding: $e');
      rethrow;
    }
  }

  /// Signs the user out from Supabase.
  Future<void> logoutCommand() async {
    _setLoading(true);
    _clearError();

    try {
      await _signOut();
    } catch (e) {
      _setError('Error signing out: $e');
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _signOut() async {
    await SupaFlow.client.auth.signOut();
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

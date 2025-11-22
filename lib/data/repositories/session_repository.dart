import 'package:shared_preferences/shared_preferences.dart';

/// Repository for managing session-related persistent state.
///
/// Handles user session preferences like onboarding completion status.
class SessionRepository {
  static const String _keyOnboardingDone = 'ff_onboardingDone';
  late SharedPreferences _prefs;

  /// Initializes the repository by loading SharedPreferences.
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Returns whether the user has completed onboarding.
  bool isOnboardingDone() {
    return _prefs.getBool(_keyOnboardingDone) ?? false;
  }

  /// Sets the onboarding completion status.
  Future<void> setOnboardingDone(bool value) async {
    await _prefs.setBool(_keyOnboardingDone, value);
  }
}

import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/user_profile_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class UserEditProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserEditProfileViewModel({
    required UserProfileRepository repository,
  }) : _repository = repository;

  /// Gets the current user ID dynamically from Supabase auth
  String get currentUserUid => SupaFlow.client.auth.currentUser?.id ?? '';

  // ========== STATE ==========

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form Fields
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController displayNameController = TextEditingController();

  bool _hideLastName = false;
  bool get hideLastName => _hideLastName;

  // ========== INITIALIZATION ==========

  Future<void> loadUserProfile() async {
    _setLoading(true);
    _clearError();

    try {
      final userProfile = await _repository.getUserProfile(currentUserUid);
      if (userProfile != null) {
        firstNameController.text = userProfile.firstName ?? '';
        lastNameController.text = userProfile.lastName ?? '';
        displayNameController.text = userProfile.displayName ?? '';

        _hideLastName = userProfile.hideLastName ?? false;
      }
      notifyListeners();
    } catch (e) {
      _setError('Error loading profile: $e');
    } finally {
      _setLoading(false);
    }
  }

  // ========== COMMANDS ==========

  void setHideLastName(bool value) {
    _hideLastName = value;
    _updateDisplayName();
    notifyListeners();
  }

  void updateFirstName(String value) {
    _updateDisplayName();
  }

  void updateLastName(String value) {
    _updateDisplayName();
  }

  void _updateDisplayName() {
    if (_hideLastName) {
      displayNameController.text = '${firstNameController.text} ';
    } else {
      displayNameController.text = '${firstNameController.text} ${lastNameController.text}';
    }
  }

  Future<void> saveProfileCommand(BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      await _repository.updateProfile(currentUserUid, {
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'display_name': displayNameController.text,
        'hide_last_name': _hideLastName,
      });

      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _setError('Error saving profile: $e');
    } finally {
      _setLoading(false);
    }
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

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    displayNameController.dispose();

    super.dispose();
  }
}

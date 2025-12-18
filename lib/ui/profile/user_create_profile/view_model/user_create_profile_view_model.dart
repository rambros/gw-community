import 'package:flutter/material.dart';
import '/data/repositories/user_profile_repository.dart';
import '/data/services/supabase/supabase.dart';
import '/app_state.dart';
import '/index.dart';
import 'package:go_router/go_router.dart';

class UserCreateProfileViewModel extends ChangeNotifier {
  final UserProfileRepository _repository;

  UserCreateProfileViewModel({
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

  // ========== COMMANDS ==========

  Future<void> completeSetupCommand(BuildContext context) async {
    if (firstNameController.text.isEmpty || lastNameController.text.isEmpty) {
      _setError('Please enter both first and last names.');
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      final firstName = firstNameController.text;
      final lastName = lastNameController.text;
      final fullName = '$firstName $lastName';

      await _repository.updateProfile(currentUserUid, {
        'first_name': firstName,
        'last_name': lastName,
        'display_name': fullName,
        'hide_last_name': false,
      });

      FFAppState().updateLoginUserStruct(
        (e) => e..displayName = fullName,
      );

      if (context.mounted) {
        context.pushNamed(HomePage.routeName);
      }
    } catch (e) {
      _setError('Error creating profile: $e');
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
    super.dispose();
  }
}

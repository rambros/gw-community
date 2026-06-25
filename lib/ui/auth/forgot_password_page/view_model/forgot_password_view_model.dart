import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  ForgotPasswordViewModel({required AuthRepository authRepository}) : _repository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Returns 'apple', 'google', or 'email' based on how the account was created.
  Future<String> checkAuthMethod(String email) async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await SupaFlow.client.functions.invoke(
        'check-auth-method',
        body: {'email': email.trim().toLowerCase()},
      );
      if (response.status == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        return (data['method'] as String?) ?? 'email';
      }
      return 'email';
    } catch (_) {
      return 'email';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.resetPassword(email, redirectTo: 'gw://login-callback');
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

import 'package:flutter/material.dart';
import '/data/repositories/auth_repository.dart';
import '/backend/supabase/supabase.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  CreateAccountViewModel({required AuthRepository authRepository}) : _repository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  bool _confirmPasswordVisibility = false;
  bool get confirmPasswordVisibility => _confirmPasswordVisibility;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _confirmPasswordVisibility = !_confirmPasswordVisibility;
    notifyListeners();
  }

  Future<User?> createAccount(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.createAccountWithEmail(email, password);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

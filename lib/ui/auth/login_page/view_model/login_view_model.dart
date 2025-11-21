import 'package:flutter/material.dart';
import '/data/repositories/auth_repository.dart';
import '/backend/supabase/supabase.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  LoginViewModel({required AuthRepository authRepository}) : _repository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  Future<User?> signIn(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.signInWithEmail(email, password);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

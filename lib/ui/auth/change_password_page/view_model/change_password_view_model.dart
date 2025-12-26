import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';

class ChangePasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  ChangePasswordViewModel({required AuthRepository authRepository}) : _repository = authRepository;

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

  Future<void> updatePassword(String newPassword) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.updatePassword(newPassword);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

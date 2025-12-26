import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  ForgotPasswordViewModel({required AuthRepository authRepository}) : _repository = authRepository;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> resetPassword(String email) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.resetPassword(email);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

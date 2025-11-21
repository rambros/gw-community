import 'package:flutter/material.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/auth_repository_impl.dart';
import '/domain/models/user_entity.dart';

class CreateAccountViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  CreateAccountViewModel({required AuthRepository authRepository}) : _repository = authRepository as AuthRepositoryImpl;

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

  Future<UserEntity?> createAccount(BuildContext context, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.createAccountWithEmailContext(context, email, password);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

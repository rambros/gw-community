import 'package:flutter/material.dart';
import '/data/repositories/auth_repository.dart';
import '/data/repositories/auth_repository_impl.dart';
import '/domain/models/user_entity.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  LoginViewModel({required AuthRepository authRepository}) : _repository = authRepository as AuthRepositoryImpl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  Future<UserEntity?> signIn(BuildContext context, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final user = await _repository.signInWithEmailContext(context, email, password);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

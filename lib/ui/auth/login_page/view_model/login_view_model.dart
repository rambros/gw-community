import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/repositories/auth_repository_impl.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/user_entity.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _repository;

  LoginViewModel({required AuthRepository authRepository}) : _repository = authRepository as AuthRepositoryImpl;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadingProvider; // 'email' | 'google' | 'apple'
  bool get isEmailLoading => _loadingProvider == 'email';
  bool get isGoogleLoading => _loadingProvider == 'google';
  bool get isAppleLoading => _loadingProvider == 'apple';

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  Future<UserEntity?> signIn(BuildContext context, String email, String password) async {
    if (_isLoading) return null;
    _isLoading = true;
    _loadingProvider = 'email';
    notifyListeners();

    try {
      final user = await _repository.signInWithEmailContext(context, email, password);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _loadingProvider = null;
      notifyListeners();
    }
  }

  Future<UserEntity?> signInWithGoogle(BuildContext context) async {
    if (_isLoading) return null;
    _isLoading = true;
    _loadingProvider = 'google';
    notifyListeners();

    try {
      final user = await _repository.signInWithGoogleContext(context);
      if (user == null) return null;
      await _assertMemberExists(user.uid);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _loadingProvider = null;
      notifyListeners();
    }
  }

  Future<UserEntity?> signInWithApple(BuildContext context) async {
    if (_isLoading) return null;
    _isLoading = true;
    _loadingProvider = 'apple';
    notifyListeners();

    try {
      final user = await _repository.signInWithAppleContext(context);
      if (user == null) return null;
      await _assertMemberExists(user.uid);
      return user;
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      _loadingProvider = null;
      notifyListeners();
    }
  }

  /// Verifica se o usuário OAuth tem um registro em cc_members (aceitou convite).
  /// Se não tiver, faz signOut e lança exceção para a UI exibir a mensagem.
  Future<void> _assertMemberExists(String authUserId) async {
    final rows = await CcMembersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('auth_user_id', authUserId),
    );
    if (rows.isEmpty) {
      await SupaFlow.client.auth.signOut();
      throw Exception(
        'No account found for this login. Please use an invitation link to register.',
      );
    }
  }
}

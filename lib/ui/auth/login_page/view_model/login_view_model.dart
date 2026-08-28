import 'dart:async';

import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/repositories/auth_repository_impl.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/user_entity.dart';

enum SendMagicLinkResult { sent, notRegistered, error }

class LoginViewModel extends ChangeNotifier {
  final AuthRepositoryImpl _repository;
  StreamSubscription<AuthState>? _authSubscription;

  LoginViewModel({required AuthRepository authRepository})
      : _repository = authRepository as AuthRepositoryImpl {
    _authSubscription = SupaFlow.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.signedOut) {
        resetOnSignOut();
      }
    });
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _loadingProvider; // 'email' | 'magic'
  bool get isEmailLoading => _loadingProvider == 'email';
  bool get isMagicLinkLoading => _loadingProvider == 'magic';

  bool _passwordVisibility = false;
  bool get passwordVisibility => _passwordVisibility;

  // Magic link mode
  bool _isMagicLinkMode = true;
  bool get isMagicLinkMode => _isMagicLinkMode;

  bool _magicLinkSent = false;
  bool get magicLinkSent => _magicLinkSent;

  String? _magicLinkEmail;
  String? get magicLinkEmail => _magicLinkEmail;

  void togglePasswordVisibility() {
    _passwordVisibility = !_passwordVisibility;
    notifyListeners();
  }

  void toggleLoginMode() {
    _isMagicLinkMode = !_isMagicLinkMode;
    _magicLinkSent = false;
    _magicLinkEmail = null;
    notifyListeners();
  }

  void resetMagicLinkState() {
    _magicLinkSent = false;
    _magicLinkEmail = null;
    notifyListeners();
  }

  /// Clears login form state after sign-out so the welcome screen is shown.
  void resetOnSignOut() {
    _magicLinkSent = false;
    _magicLinkEmail = null;
    _isLoading = false;
    _loadingProvider = null;
    _isMagicLinkMode = true;
    _passwordVisibility = false;
    notifyListeners();
  }

  Future<SendMagicLinkResult> sendMagicLink(String email) async {
    if (_isLoading) return SendMagicLinkResult.error;
    _isLoading = true;
    _loadingProvider = 'magic';
    notifyListeners();

    final trimmedEmail = email.trim();

    try {
      await _repository.sendMagicLink(trimmedEmail);
      _magicLinkEmail = trimmedEmail;
      _magicLinkSent = true;
      return SendMagicLinkResult.sent;
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      if (msg.contains('not found') || e.statusCode == '422' || msg.contains('otp')) {
        return SendMagicLinkResult.notRegistered;
      }
      return SendMagicLinkResult.error;
    } catch (_) {
      return SendMagicLinkResult.error;
    } finally {
      _isLoading = false;
      _loadingProvider = null;
      notifyListeners();
    }
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

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

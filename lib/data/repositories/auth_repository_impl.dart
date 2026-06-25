import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/services/auth/auth_service.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/domain/models/user_entity.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  AuthRepositoryImpl({required AuthService authService}) : _authService = authService;

  @override
  Stream<UserEntity?> get authStateChanges => _authService.authStateChanges;

  @override
  Stream<AppAuthUser> get authUserChanges => _authService.authUserChanges;

  @override
  Stream<String> get jwtTokenChanges => _authService.jwtTokenChanges;

  @override
  UserEntity? get currentUser => _authService.currentUser;

  @override
  String? get currentUserId => _authService.currentUserId;

  @override
  Future<UserEntity?> signInWithEmail(String email, String password) {
    throw UnimplementedError(
      'Use signInWithEmailContext instead - requires BuildContext for error handling',
    );
  }

  Future<UserEntity?> signInWithEmailContext(BuildContext context, String email, String password) {
    return _authService.signInWithEmail(context, email, password);
  }

  @override
  Future<void> signOut() => _authService.signOut();

  @override
  Future<void> resetPassword(String email, {String? redirectTo}) {
    return SupaFlow.client.auth.resetPasswordForEmail(email, redirectTo: redirectTo);
  }

  Future<void> resetPasswordContext(BuildContext context, String email, {String? redirectTo}) {
    return _authService.resetPassword(email: email, context: context, redirectTo: redirectTo);
  }

  @override
  Future<void> updateEmail(String email) {
    throw UnimplementedError(
      'Use updateEmailContext instead - requires BuildContext for error handling',
    );
  }

  Future<void> updateEmailContext(BuildContext context, String email) {
    return _authService.updateEmail(email: email, context: context);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    throw UnimplementedError(
      'Use updatePasswordContext instead - requires BuildContext for error handling',
    );
  }

  Future<void> updatePasswordContext(BuildContext context, String newPassword) {
    return _authService.updatePassword(newPassword: newPassword, context: context);
  }

  @override
  Future<void> deleteUser() {
    throw UnimplementedError(
      'Use deleteUserContext instead - requires BuildContext for error handling',
    );
  }

  Future<void> deleteUserContext(BuildContext context) => _authService.deleteUser(context);

  @override
  Future<void> sendEmailVerification() => _authService.sendEmailVerification();

  @override
  Future<void> refreshUser() => _authService.refreshUser();

  @override
  Future<void> sendMagicLink(String email) => _authService.sendMagicLink(email);
}

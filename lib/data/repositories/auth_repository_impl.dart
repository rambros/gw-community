import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/services/auth/auth_service.dart';
import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/domain/models/user_entity.dart';

/// Implementation of [AuthRepository] using [AuthService].
///
/// This repository acts as a facade over the auth service,
/// providing additional business logic, caching, or error handling
/// if needed in the future.
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
  Future<UserEntity?> signInWithEmail(String email, String password) async {
    // For now, we need a BuildContext for the service layer
    // In a more advanced implementation, we could handle errors here
    // and return Result types instead of showing SnackBars in the service
    throw UnimplementedError(
      'Use signInWithEmailContext instead - requires BuildContext for error handling',
    );
  }

  /// Signs in with email and password (requires context for error messages).
  Future<UserEntity?> signInWithEmailContext(
    BuildContext context,
    String email,
    String password,
  ) {
    return _authService.signInWithEmail(context, email, password);
  }

  @override
  Future<UserEntity?> createAccountWithEmail(String email, String password) {
    throw UnimplementedError(
      'Use createAccountWithEmailContext instead - requires BuildContext for error handling',
    );
  }

  /// Creates account with email and password (requires context for error messages).
  Future<UserEntity?> createAccountWithEmailContext(
    BuildContext context,
    String email,
    String password,
  ) {
    return _authService.createAccountWithEmail(context, email, password);
  }

  @override
  Future<UserEntity?> signInWithGoogle() {
    throw UnimplementedError(
      'Use signInWithGoogleContext instead - requires BuildContext for error handling',
    );
  }

  /// Signs in with Google (requires context for error messages).
  Future<UserEntity?> signInWithGoogleContext(BuildContext context) {
    return _authService.signInWithGoogle(context);
  }

  @override
  Future<void> signOut() {
    return _authService.signOut();
  }

  @override
  Future<void> resetPassword(String email, {String? redirectTo}) {
    throw UnimplementedError(
      'Use resetPasswordContext instead - requires BuildContext for error handling',
    );
  }

  /// Resets password (requires context for error messages).
  Future<void> resetPasswordContext(
    BuildContext context,
    String email, {
    String? redirectTo,
  }) {
    return _authService.resetPassword(
      email: email,
      context: context,
      redirectTo: redirectTo,
    );
  }

  @override
  Future<void> updateEmail(String email) {
    throw UnimplementedError(
      'Use updateEmailContext instead - requires BuildContext for error handling',
    );
  }

  /// Updates email (requires context for error messages).
  Future<void> updateEmailContext(BuildContext context, String email) {
    return _authService.updateEmail(email: email, context: context);
  }

  @override
  Future<void> updatePassword(String newPassword) {
    throw UnimplementedError(
      'Use updatePasswordContext instead - requires BuildContext for error handling',
    );
  }

  /// Updates password (requires context for error messages).
  Future<void> updatePasswordContext(
    BuildContext context,
    String newPassword,
  ) {
    return _authService.updatePassword(
      newPassword: newPassword,
      context: context,
    );
  }

  @override
  Future<void> deleteUser() {
    throw UnimplementedError(
      'Use deleteUserContext instead - requires BuildContext for error handling',
    );
  }

  /// Deletes user (requires context for error messages).
  Future<void> deleteUserContext(BuildContext context) {
    return _authService.deleteUser(context);
  }

  @override
  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  @override
  Future<void> refreshUser() {
    return _authService.refreshUser();
  }
}

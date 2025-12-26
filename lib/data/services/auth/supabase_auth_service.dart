import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import '/data/services/supabase/supabase.dart';
import '/domain/models/app_auth_user.dart';
import '/domain/models/user_entity.dart';
import '/utils/flutter_flow_util.dart';
import 'auth_service.dart';
import 'providers/email_auth_provider.dart';
import 'providers/google_auth_provider.dart';
import 'supabase_auth_user_provider.dart';

/// Supabase implementation of [AuthService].
///
/// This service handles all authentication operations using Supabase,
/// converting between Supabase's User type and our domain UserEntity.
class SupabaseAuthService implements AuthService {
  static final SupabaseAuthService _instance = SupabaseAuthService._internal();
  factory SupabaseAuthService() => _instance;
  SupabaseAuthService._internal();

  Stream<AppAuthUser>? _authUserStream;
  Stream<String>? _jwtTokenStream;

  @override
  Stream<UserEntity?> get authStateChanges {
    final supabaseAuthStream = SupaFlow.client.auth.onAuthStateChange.debounce(
      (authState) => authState.event == AuthChangeEvent.tokenRefreshed
          ? TimerStream(authState, const Duration(seconds: 1))
          : Stream.value(authState),
    );

    return (currentUser == null ? Stream<AuthState?>.value(null).concatWith([supabaseAuthStream]) : supabaseAuthStream)
        .map<UserEntity?>((authState) => _mapToUserEntity(authState?.session?.user));
  }

  @override
  UserEntity? get currentUser {
    final user = SupaFlow.client.auth.currentUser;
    return user != null ? _mapToUserEntity(user) : null;
  }

  @override
  Stream<AppAuthUser> get authUserChanges => _authUserStream ??= gWCommunitySupabaseUserStream();

  @override
  Stream<String> get jwtTokenChanges => _jwtTokenStream ??= SupaFlow.client.auth.onAuthStateChange
      .debounce(
        (authState) => authState.event == AuthChangeEvent.tokenRefreshed
            ? TimerStream(authState, const Duration(seconds: 1))
            : Stream.value(authState),
      )
      .map<String>((authState) => authState.session?.accessToken ?? '');

  @override
  String? get currentUserId => SupaFlow.client.auth.currentUser?.id;

  @override
  Future<UserEntity?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    return _signInOrCreateAccount(
      context,
      () => emailSignInFunc(email, password),
    );
  }

  @override
  Future<UserEntity?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  ) async {
    return _signInOrCreateAccount(
      context,
      () => emailCreateAccountFunc(email, password),
    );
  }

  @override
  Future<UserEntity?> signInWithGoogle(BuildContext context) async {
    return _signInOrCreateAccount(context, googleSignInFunc);
  }

  @override
  Future<void> signOut() {
    return SupaFlow.client.auth.signOut();
  }

  @override
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  }) async {
    try {
      await SupaFlow.client.auth.resetPasswordForEmail(
        email,
        redirectTo: redirectTo,
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset email sent')),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) {
        debugPrint('Error: update email attempted with no logged in user!');
        return;
      }
      await SupaFlow.client.auth.updateUser(UserAttributes(email: email));
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email change confirmation email sent')),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> updatePassword({
    required String newPassword,
    required BuildContext context,
  }) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) {
        debugPrint('Error: update password attempted with no logged in user!');
        return;
      }
      await SupaFlow.client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password updated successfully')),
        );
      }
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> deleteUser(BuildContext context) async {
    try {
      final user = SupaFlow.client.auth.currentUser;
      if (user == null) {
        debugPrint('Error: delete user attempted with no logged in user!');
        return;
      }
      // Note: Supabase doesn't have a direct delete user method in the client SDK
      throw UnsupportedError('The delete user operation is not yet supported.');
    } on AuthException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.message}')),
        );
      }
      rethrow;
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    throw UnsupportedError('The send email verification operation is not yet supported.');
  }

  @override
  Future<void> refreshUser() async {
    await SupaFlow.client.auth.refreshSession();
  }

  /// Helper method to sign in or create an account.
  Future<UserEntity?> _signInOrCreateAccount(
    BuildContext context,
    Future<User?> Function() signInFunc,
  ) async {
    try {
      final user = await signInFunc();
      final userEntity = user != null ? _mapToUserEntity(user) : null;

      // Update app state if needed - using BaseAuthUser for compatibility
      if (user != null) {
        final baseAuthUser = GWCommunitySupabaseUser(user);
        AppStateNotifier.instance.update(baseAuthUser);
      }
      return userEntity;
    } on AuthException catch (e) {
      final errorMsg = e.message.contains('User already registered')
          ? 'Error: The email is already in use by a different account'
          : 'Error: ${e.message}';
      if (context.mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
      return null;
    }
  }

  /// Maps a Supabase User to a UserEntity.
  UserEntity? _mapToUserEntity(User? user) {
    if (user == null) return null;
    return UserEntity(
      uid: user.id,
      email: user.email,
      displayName: user.userMetadata?['display_name'] as String?,
      photoUrl: user.userMetadata?['avatar_url'] as String?,
      phoneNumber: user.phone,
      emailVerified: user.emailConfirmedAt != null,
    );
  }
}

import 'package:flutter/material.dart';

import '/domain/models/app_auth_user.dart';
import '/domain/models/user_entity.dart';

/// Abstract service interface for authentication operations.
///
/// This interface defines the contract for authentication services,
/// allowing different implementations (Supabase, Firebase, etc.)
/// without changing the repository or business logic.
abstract class AuthService {
  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;

  /// Stream of raw auth user changes (used for router/app state updates).
  Stream<AppAuthUser> get authUserChanges;

  /// Stream that emits the latest JWT token (useful for Web).
  Stream<String> get jwtTokenChanges;

  /// Gets the current authenticated user, if any.
  UserEntity? get currentUser;

  /// Convenience getter for the current user's ID if authenticated.
  String? get currentUserId;

  /// Signs in a user with email and password.
  ///
  /// Returns the authenticated user on success, null on failure.
  /// May throw exceptions for network errors or invalid credentials.
  Future<UserEntity?> signInWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  /// Creates a new account with email and password.
  ///
  /// Returns the newly created user on success, null on failure.
  /// May throw exceptions for network errors or if email is already in use.
  Future<UserEntity?> createAccountWithEmail(
    BuildContext context,
    String email,
    String password,
  );

  /// Signs in with Google OAuth.
  ///
  /// Returns the authenticated user on success, null on failure.
  Future<UserEntity?> signInWithGoogle(BuildContext context);

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email to the specified address.
  Future<void> resetPassword({
    required String email,
    required BuildContext context,
    String? redirectTo,
  });

  /// Updates the current user's email address.
  Future<void> updateEmail({
    required String email,
    required BuildContext context,
  });

  /// Updates the current user's password.
  Future<void> updatePassword({
    required String newPassword,
    required BuildContext context,
  });

  /// Deletes the current user's account.
  Future<void> deleteUser(BuildContext context);

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification();

  /// Refreshes the current user's data.
  Future<void> refreshUser();
}

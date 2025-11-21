import '/domain/models/user_entity.dart';

/// Repository interface for authentication operations.
///
/// This is the main interface that ViewModels should depend on.
/// It provides high-level authentication operations and abstracts
/// away the underlying service implementation (Supabase, Firebase, etc.).
abstract class AuthRepository {
  /// Stream of authentication state changes.
  /// Emits the current user when authenticated, null when signed out.
  Stream<UserEntity?> get authStateChanges;

  /// Gets the current authenticated user, if any.
  UserEntity? get currentUser;

  /// Signs in a user with email and password.
  ///
  /// Returns the authenticated user on success, null on failure.
  /// Shows error messages via SnackBar if context is provided.
  Future<UserEntity?> signInWithEmail(String email, String password);

  /// Creates a new account with email and password.
  ///
  /// Returns the newly created user on success, null on failure.
  /// Shows error messages via SnackBar if context is provided.
  Future<UserEntity?> createAccountWithEmail(String email, String password);

  /// Signs in with Google OAuth.
  ///
  /// Returns the authenticated user on success, null on failure.
  Future<UserEntity?> signInWithGoogle();

  /// Signs out the current user.
  Future<void> signOut();

  /// Sends a password reset email to the specified address.
  Future<void> resetPassword(String email, {String? redirectTo});

  /// Updates the current user's email address.
  Future<void> updateEmail(String email);

  /// Updates the current user's password.
  Future<void> updatePassword(String newPassword);

  /// Deletes the current user's account.
  Future<void> deleteUser();

  /// Sends an email verification to the current user.
  Future<void> sendEmailVerification();

  /// Refreshes the current user's data.
  Future<void> refreshUser();
}

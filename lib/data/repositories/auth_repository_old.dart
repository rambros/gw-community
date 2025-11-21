import '/backend/supabase/supabase.dart';

class AuthRepository {
  /// Signs in a user with email and password.
  Future<User?> signInWithEmail(String email, String password) async {
    final AuthResponse res = await SupaFlow.client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return res.user;
  }

  /// Creates a new account with email and password.
  Future<User?> createAccountWithEmail(String email, String password) async {
    final AuthResponse res = await SupaFlow.client.auth.signUp(
      email: email,
      password: password,
    );

    // If email confirmation is required, the user might be returned but not signed in.
    // We return the user if the sign-up request was successful.
    return res.user;
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await SupaFlow.client.auth.signOut();
  }

  /// Sends a password reset email.
  Future<void> resetPassword(String email, {String? redirectTo}) async {
    await SupaFlow.client.auth.resetPasswordForEmail(
      email,
      redirectTo: redirectTo,
    );
  }

  /// Updates the user's password.
  Future<void> updatePassword(String newPassword) async {
    await SupaFlow.client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
  }

  /// Gets the current authenticated user.
  User? get currentUser => SupaFlow.client.auth.currentUser;

  /// Stream of auth state changes.
  Stream<AuthState> get onAuthStateChange => SupaFlow.client.auth.onAuthStateChange;
}

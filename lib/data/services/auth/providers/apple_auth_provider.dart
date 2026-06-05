import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';

Future<User?> appleSignInFunc() async {
  if (kIsWeb) {
    final success = await SupaFlow.client.auth.signInWithOAuth(OAuthProvider.apple);
    return success ? SupaFlow.client.auth.currentUser : null;
  }

  try {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );

    final idToken = credential.identityToken;
    if (idToken == null) throw Exception('No ID Token received from Apple.');

    final authResponse = await SupaFlow.client.auth.signInWithIdToken(
      provider: OAuthProvider.apple,
      idToken: idToken,
    );
    return authResponse.user;
  } on SignInWithAppleAuthorizationException catch (e) {
    // User dismissed the dialog or is not signed into an Apple Account — not an error.
    if (e.code == AuthorizationErrorCode.canceled ||
        e.code == AuthorizationErrorCode.unknown) {
      return null;
    }
    rethrow;
  }
}

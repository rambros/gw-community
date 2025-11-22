import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '/data/services/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_util.dart';

const _googleScopes = ['profile', 'email'];
Future<void>? _googleSignInInit;

Future<void> _ensureGoogleSignInInitialized() {
  return _googleSignInInit ??= GoogleSignIn.instance.initialize(
    clientId: isAndroid ? null : '720538206617-f3fnpkfmeuetlktaqdd2ckvh3cjqb9rf.apps.googleusercontent.com',
    serverClientId: '720538206617-ardiq4kfkcrfu3qei4a2ej9l2kipmtgf.apps.googleusercontent.com',
  );
}

Future<User?> googleSignInFunc() async {
  if (kIsWeb) {
    final success = await SupaFlow.client.auth.signInWithOAuth(OAuthProvider.google);
    return success ? SupaFlow.client.auth.currentUser : null;
  }

  await _ensureGoogleSignInInitialized();
  final googleSignIn = GoogleSignIn.instance;

  await googleSignIn.signOut().catchError((_) => null);
  try {
    final googleUser = await googleSignIn.authenticate(scopeHint: _googleScopes);
    final authorization = await googleUser.authorizationClient.authorizeScopes(_googleScopes);
    final idToken = googleUser.authentication.idToken;
    final accessToken = authorization.accessToken;

    if (idToken == null) {
      throw 'No ID Token found.';
    }

    final authResponse = await SupaFlow.client.auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    );
    return authResponse.user;
  } on GoogleSignInException catch (error) {
    if (error.code == GoogleSignInExceptionCode.canceled ||
        error.code == GoogleSignInExceptionCode.interrupted ||
        error.code == GoogleSignInExceptionCode.uiUnavailable) {
      return null;
    }
    rethrow;
  }
}

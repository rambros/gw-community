import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '/backend/supabase/supabase.dart';
import '/domain/models/app_auth_user.dart';

/// Supabase-specific implementation of [AppAuthUser].
class GWCommunitySupabaseUser extends AppAuthUser {
  GWCommunitySupabaseUser(this.user);

  final User? user;

  @override
  bool get loggedIn => user != null;

  @override
  String? get uid => user?.id;

  @override
  String? get email => user?.email;

  @override
  String? get displayName => user?.userMetadata?['display_name'] as String?;

  @override
  String? get photoUrl => user?.userMetadata?['avatar_url'] as String?;

  @override
  String? get phoneNumber => user?.phone;

  @override
  bool get emailVerified => user?.emailConfirmedAt != null;
}

/// Stream of Supabase auth state changes mapped to [AppAuthUser].
Stream<AppAuthUser> gWCommunitySupabaseUserStream() {
  return SupaFlow.client.auth.onAuthStateChange
      .debounce(
        (authState) => authState.event == AuthChangeEvent.tokenRefreshed
            ? TimerStream(authState, const Duration(seconds: 1))
            : Stream.value(authState),
      )
      .map<AppAuthUser>(
        (authState) => GWCommunitySupabaseUser(authState.session?.user),
      );
}

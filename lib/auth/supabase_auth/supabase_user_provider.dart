import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '/backend/supabase/supabase.dart';
import '/auth/base_auth_user_provider.dart';

export '/auth/base_auth_user_provider.dart';

/// Supabase-specific implementation of BaseAuthUser.
class GWCommunitySupabaseUser extends BaseAuthUser {
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

/// Stream of Supabase auth state changes.
Stream<BaseAuthUser> gWCommunitySupabaseUserStream() {
  return SupaFlow.client.auth.onAuthStateChange
      .debounce(
        (authState) => authState.event == AuthChangeEvent.tokenRefreshed
            ? TimerStream(authState, const Duration(seconds: 1))
            : Stream.value(authState),
      )
      .map<BaseAuthUser>(
        (authState) => GWCommunitySupabaseUser(authState.session?.user),
      );
}

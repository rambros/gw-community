import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:rxdart/rxdart.dart';

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

Future<Map<String, dynamic>?> _checkMemberExists(String uid, String? email) {
  if (email != null && email.isNotEmpty) {
    return SupaFlow.client
        .from('cc_members')
        .select('id')
        .or('auth_user_id.eq.$uid,email.eq.$email')
        .maybeSingle();
  }
  return SupaFlow.client.from('cc_members').select('id').eq('auth_user_id', uid).maybeSingle();
}

/// Stream of Supabase auth state changes mapped to [AppAuthUser].
Stream<AppAuthUser> gWCommunitySupabaseUserStream() {
  // Get current user
  final currentUser = SupaFlow.client.auth.currentUser;

  // Create stream that emits current user first, then listens for changes
  final baseAuthStream = Stream<AppAuthUser>.value(GWCommunitySupabaseUser(currentUser)).concatWith([
    SupaFlow.client.auth.onAuthStateChange
        .debounce(
          (authState) => authState.event == AuthChangeEvent.tokenRefreshed
              ? TimerStream(authState, const Duration(seconds: 1))
              : Stream.value(authState),
        )
        .map<AppAuthUser>(
          (authState) => GWCommunitySupabaseUser(authState.session?.user),
        ),
  ]);

  // Combined with a periodic heartbeat to force a database check every 10 seconds
  final authStream = Rx.combineLatest2<AppAuthUser, dynamic, AppAuthUser>(
    baseAuthStream,
    Stream.periodic(const Duration(seconds: 10)).startWith(null),
    (user, _) => user,
  );

  // Add a verification step: if the user is logged in, verify they exist in cc_members
  return authStream.switchMap((authUser) {
    if (!authUser.loggedIn || authUser.uid == null) {
      return Stream.value(authUser);
    }

    // Check if the member exists in cc_members by auth_user_id OR by email.
    // The email fallback handles the brief window during OAuth invite acceptance
    // where auth_user_id hasn't been linked yet by the accept-invite-oauth function.
    return Stream.fromFuture(_checkMemberExists(authUser.uid!, authUser.email)).map((response) {
      if (response == null) {
        // User exists in Auth but not in cc_members - forced logout
        debugPrint('FORCED LOGOUT: Member record missing in database for uid ${authUser.uid}. Signing out...');
        SupaFlow.client.auth.signOut();
        return GWCommunitySupabaseUser(null);
      }
      return authUser;
    }).onErrorReturn(authUser); // On error, assume they are still logged in to avoid flickering
  });
}

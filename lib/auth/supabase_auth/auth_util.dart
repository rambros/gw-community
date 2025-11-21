import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '/backend/supabase/supabase.dart';

export 'supabase_user_provider.dart';

/// Stream that emits JWT tokens from Supabase auth.
Stream<String> get jwtTokenStream {
  return SupaFlow.client.auth.onAuthStateChange
      .debounce(
        (authState) => authState.event == AuthChangeEvent.tokenRefreshed
            ? TimerStream(authState, const Duration(seconds: 1))
            : Stream.value(authState),
      )
      .map<String>((authState) => authState.session?.accessToken ?? '');
}

/// Gets the current user's UID from Supabase.
String get currentUserUid {
  return SupaFlow.client.auth.currentUser?.id ?? '';
}

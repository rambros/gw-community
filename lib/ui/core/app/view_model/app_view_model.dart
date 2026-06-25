import 'dart:async';
import 'package:flutter/material.dart';

import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/repositories/auth_repository.dart';
import 'package:gw_community/data/repositories/home_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/app_auth_user.dart';
import 'package:gw_community/routing/router.dart';
import 'package:gw_community/utils/internationalization.dart';

class AppViewModel extends ChangeNotifier with WidgetsBindingObserver {
  final AuthRepository authRepository;
  late AppStateNotifier appStateNotifier;
  late GoRouter router;

  Locale? _locale;
  Locale? get locale => _locale;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  StreamSubscription<AppAuthUser>? _userSubscription;
  StreamSubscription<AuthState>? _authEventSubscription;

  AppViewModel({required this.authRepository}) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  void _initialize() {
    appStateNotifier = AppStateNotifier.instance;
    router = createRouter(appStateNotifier);

    // Detect password recovery deep link before the auth user stream fires,
    // so the router redirect can send the user to ChangePasswordPage instead of Home.
    _authEventSubscription = SupaFlow.client.auth.onAuthStateChange.listen((authState) {
      if (authState.event == AuthChangeEvent.passwordRecovery) {
        debugPrint('AUTH: passwordRecovery detected — setting pendingPasswordRecovery flag.');
        appStateNotifier.pendingPasswordRecovery = true;
        appStateNotifier.notifyListeners();
      }
    });

    // Initialize with current user from auth immediately.
    // Also reload module config whenever the user transitions to logged-in so
    // the nav tabs reflect the correct group flags regardless of login method
    // (email, magic link, invite) — not just on splash for pre-logged-in users.
    _userSubscription = authRepository.authUserChanges.listen((user) {
      final wasLoggedIn = appStateNotifier.loggedIn;
      appStateNotifier.update(user);
      final isNowLoggedIn = appStateNotifier.loggedIn;
      if (!wasLoggedIn && isNowLoggedIn) {
        FFAppState().loadGroupModuleConfig(HomeRepository());
      }
    });

    authRepository.jwtTokenChanges.listen((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      authRepository.refreshUser();
      // Refresh module flags on resume so changes made in the admin portal
      // are reflected without requiring a log-out/log-in cycle.
      if (appStateNotifier.loggedIn) {
        FFAppState().loadGroupModuleConfig(HomeRepository());
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userSubscription?.cancel();
    _authEventSubscription?.cancel();
    super.dispose();
  }

  void setLocale(String language) {
    _locale = createLocale(language);
    notifyListeners();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  String getRoute([RouteMatchBase? routeMatch]) {
    final RouteMatchBase lastMatch = routeMatch ?? router.routerDelegate.currentConfiguration.last;
    final RouteMatchList matchList =
        lastMatch is ImperativeRouteMatch ? lastMatch.matches : router.routerDelegate.currentConfiguration;
    return matchList.uri.toString();
  }

  List<String> getRouteStack() => router.routerDelegate.currentConfiguration.matches.map((e) => getRoute(e)).toList();
}

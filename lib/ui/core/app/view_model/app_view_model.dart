import 'dart:async';
import 'package:flutter/material.dart';

import 'package:gw_community/data/repositories/auth_repository.dart';
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

  AppViewModel({required this.authRepository}) {
    WidgetsBinding.instance.addObserver(this);
    _initialize();
  }

  void _initialize() {
    appStateNotifier = AppStateNotifier.instance;
    router = createRouter(appStateNotifier);

    // Initialize with current user from auth immediately
    _userSubscription = authRepository.authUserChanges.listen((user) {
      appStateNotifier.update(user);
    });

    authRepository.jwtTokenChanges.listen((_) {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // When the app comes back to the foreground, refresh the user to trigger validation
      authRepository.refreshUser();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userSubscription?.cancel();
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

import 'dart:async';
import 'package:flutter/material.dart';

import '/data/repositories/auth_repository.dart';
import '/domain/models/app_auth_user.dart';
import '/routing/router.dart';
import '/utils/internationalization.dart';

class AppViewModel extends ChangeNotifier {
  final AuthRepository authRepository;
  late AppStateNotifier appStateNotifier;
  late GoRouter router;

  Locale? _locale;
  Locale? get locale => _locale;

  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  StreamSubscription<AppAuthUser>? _userSubscription;

  AppViewModel({required this.authRepository}) {
    _initialize();
  }

  void _initialize() {
    appStateNotifier = AppStateNotifier.instance;
    router = createRouter(appStateNotifier);

    _userSubscription = authRepository.authUserChanges.listen((user) {
      appStateNotifier.update(user);
    });

    authRepository.jwtTokenChanges.listen((_) {});

    Future.delayed(
      const Duration(milliseconds: 1000),
      () => appStateNotifier.stopShowingSplashImage(),
    );
  }

  @override
  void dispose() {
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

import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/settings_repository.dart';
import 'package:gw_community/ui/auth/login_page/login_page.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplash(BuildContext context) async {
    // Load app configuration from settings during splash
    try {
      final settingsRepo = SettingsRepository();
      final appState = context.read<FFAppState>();
      await appState.loadAppConfig(settingsRepo);
    } catch (e) {
      // Continue with defaults if settings fail to load
      debugPrint('Error loading app config: $e');
    }

    await Future.delayed(const Duration(milliseconds: 4000));

    if (context.mounted) {
      AppStateNotifier.instance.stopShowingSplashImage();

      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        final loggedIn = AppStateNotifier.instance.loggedIn;

        if (loggedIn) {
          context.goNamed(HomePage.routeName);
        } else {
          context.goNamed(LoginPage.routeName);
        }
      }
    }
  }
}

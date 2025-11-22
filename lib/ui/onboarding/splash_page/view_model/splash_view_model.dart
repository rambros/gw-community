import 'package:flutter/material.dart';
import '/utils/flutter_flow_util.dart';
import '/index.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplash(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (context.mounted) {
      print('✅ SplashViewModel: context is mounted, stopping splash image');

      // 1. Stop showing splash image
      AppStateNotifier.instance.stopShowingSplashImage();
      print('🛑 SplashViewModel: splash image stopped');

      // 2. Force navigation immediately
      if (context.mounted) {
        print('🧭 SplashViewModel: Forcing immediate navigation to ${LoginPage.routePath}');
        context.go(LoginPage.routePath);
      }
    }
  }
}

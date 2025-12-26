import 'package:flutter/material.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplash(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (context.mounted) {
      AppStateNotifier.instance.stopShowingSplashImage();

      await Future.delayed(const Duration(milliseconds: 100));
      if (context.mounted) {
        final loggedIn = AppStateNotifier.instance.loggedIn;

        if (loggedIn) {
          context.goNamed('homePage');
        } else {
          context.goNamed('loginPage');
        }
      }
    }
  }
}

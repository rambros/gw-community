import 'package:flutter/material.dart';
import '/utils/flutter_flow_util.dart';
import '/index.dart';

class SplashViewModel extends ChangeNotifier {
  Future<void> initSplash(BuildContext context) async {
    await Future.delayed(const Duration(milliseconds: 2000));

    if (context.mounted) {
      context.goNamed(LoginPage.routeName);
    }
  }
}

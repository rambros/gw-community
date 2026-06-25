import 'package:flutter/material.dart';
import 'package:gw_community/app_state.dart';

class OnBoardingViewModel extends ChangeNotifier {
  final FFAppState _appState;

  OnBoardingViewModel({required FFAppState appState}) : _appState = appState;

  final PageController pageController = PageController(initialPage: 0);

  void nextPage() {
    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  void animateToPage(int page) {
    pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  Future<void> completeOnboarding(BuildContext context) async {
    _appState.onboardingDone = true;
    notifyListeners();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';

class NavBarViewModel extends ChangeNotifier {
  String _currentPageName = 'homePage';
  String get currentPageName => _currentPageName;

  Widget? _currentPage;
  Widget? get currentPage => _currentPage;

  void setInitialPage(String? pageName, Widget? page) {
    if (pageName != null) {
      _currentPageName = pageName;
    }
    _currentPage = page;
  }

  void selectTab(String pageName) {
    _currentPage = null;
    _currentPageName = pageName;
    notifyListeners();
  }
}

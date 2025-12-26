import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '/ui/community/community_page/community_page.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/home/home_page/home_page.dart';
import '/ui/journey/journey_page/journey_page.dart';
import '/ui/learn/learn_list_page/learn_list_page.dart';
import '/ui/profile/user_profile_page/user_profile_page.dart';
import '/utils/custom_icons.dart';
import 'view_model/nav_bar_view_model.dart';

class NavBarPage extends StatefulWidget {
  const NavBarPage({
    super.key,
    this.initialPage,
    this.page,
    this.disableResizeToAvoidBottomInset = false,
  });

  final String? initialPage;
  final Widget? page;
  final bool disableResizeToAvoidBottomInset;

  @override
  State<NavBarPage> createState() => _NavBarPageState();
}

class _NavBarPageState extends State<NavBarPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NavBarViewModel()..setInitialPage(widget.initialPage, widget.page),
      child: Consumer<NavBarViewModel>(
        builder: (context, viewModel, child) {
          final tabs = {
            'homePage': const HomePage(),
            'learnListPage': const LearnListPage(),
            'journeyPage': const JourneyPage(),
            'communityPage': const CommunityPage(),
            'userProfilePage': const UserProfilePage(),
          };
          final currentIndex = tabs.keys.toList().indexOf(viewModel.currentPageName);

          return Scaffold(
            resizeToAvoidBottomInset: !widget.disableResizeToAvoidBottomInset,
            body: viewModel.currentPage ?? tabs[viewModel.currentPageName],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: currentIndex,
              onTap: (i) => viewModel.selectTab(tabs.keys.toList()[i]),
              backgroundColor: Colors.white,
              selectedItemColor: AppTheme.of(context).primary,
              unselectedItemColor: const Color(0xFF95A1AC),
              showSelectedLabels: true,
              showUnselectedLabels: false,
              type: BottomNavigationBarType.fixed,
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.home_outlined,
                    size: 28.0,
                  ),
                  label: 'Home',
                  tooltip: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.library_music,
                    size: 24.0,
                  ),
                  label: 'Library',
                  tooltip: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    FFIcons.kiconLogo,
                    size: 24.0,
                  ),
                  activeIcon: Icon(
                    FFIcons.kiconLogo,
                    size: 24.0,
                  ),
                  label: 'Journey',
                  tooltip: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.public,
                    size: 28.0,
                  ),
                  activeIcon: Icon(
                    Icons.public,
                    size: 28.0,
                  ),
                  label: 'Community',
                  tooltip: '',
                ),
                BottomNavigationBarItem(
                  icon: Icon(
                    Icons.account_circle_outlined,
                    size: 28.0,
                  ),
                  activeIcon: Icon(
                    Icons.account_circle,
                    size: 28.0,
                  ),
                  label: 'Profile',
                  tooltip: '',
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

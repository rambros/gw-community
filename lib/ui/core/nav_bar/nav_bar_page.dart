import 'package:flutter/material.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/app_config.dart';
import 'package:gw_community/ui/community/community_page/community_page.dart';
import 'package:gw_community/ui/core/nav_bar/view_model/nav_bar_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/home/home_page/home_page.dart';
import 'package:gw_community/ui/journey/journey_list_page/journey_list_page.dart';
import 'package:gw_community/ui/journey/journey_page/journey_page.dart';
import 'package:gw_community/ui/learn/learn_list_page/learn_list_page.dart';
import 'package:gw_community/ui/profile/user_profile_page/user_profile_page.dart';
import 'package:gw_community/utils/custom_icons.dart';
import 'package:provider/provider.dart';

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
    // Watch app state for configuration
    final appState = context.watch<FFAppState>();
    final config = appState.appConfig;

    return ChangeNotifierProvider(
      create: (context) => NavBarViewModel()..setInitialPage(widget.initialPage, widget.page),
      child: Consumer<NavBarViewModel>(
        builder: (context, viewModel, child) {
          // Build tabs based on configuration and per-group module flags
          final tabs = _buildTabs(appState, config);
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
              items: _buildBottomNavItems(context, appState, config),
            ),
          );
        },
      ),
    );
  }

  /// Build tabs map based on app configuration and per-group module flags
  Map<String, Widget> _buildTabs(FFAppState appState, AppConfig config) {
    final tabs = <String, Widget>{
      'homePage': const HomePage(),
    };

    // Library tab - only include if enabled for the user's group
    if (appState.enableLibraryModule) {
      tabs['learnListPage'] = const LearnListPage();
    }

    // Journey tab - only include if enabled for the user's group
    if (appState.enableJourneyModule) {
      if (config.enableJourneyList) {
        tabs['journeyPage'] = const JourneyListPage();
      } else {
        tabs['journeyPage'] = const JourneyPage(journeyId: 1);
      }
    }

    // Community tab - enabled globally AND per-group
    if (config.enableCommunityModule && appState.enableCommunityModule) {
      tabs['communityPage'] = const CommunityPage();
    }

    tabs['userProfilePage'] = const UserProfilePage();

    return tabs;
  }

  /// Build bottom navigation items based on app configuration and per-group module flags
  List<BottomNavigationBarItem> _buildBottomNavItems(BuildContext context, FFAppState appState, AppConfig config) {
    final items = <BottomNavigationBarItem>[
      const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined, size: 28.0),
        label: 'Home',
        tooltip: '',
      ),
    ];

    // Library item - only if enabled for the user's group
    if (appState.enableLibraryModule) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.library_music, size: 24.0),
          label: 'Library',
          tooltip: '',
        ),
      );
    }

    // Journey item - only if enabled for the user's group
    if (appState.enableJourneyModule) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(FFIcons.kiconLogo, size: 24.0),
          activeIcon: Icon(FFIcons.kiconLogo, size: 24.0),
          label: 'Journey',
          tooltip: '',
        ),
      );
    }

    // Add Community tab if enabled globally AND per-group
    if (config.enableCommunityModule && appState.enableCommunityModule) {
      items.add(
        const BottomNavigationBarItem(
          icon: Icon(Icons.public, size: 28.0),
          activeIcon: Icon(Icons.public, size: 28.0),
          label: 'Community',
          tooltip: '',
        ),
      );
    }

    // Profile is always last
    items.add(
      const BottomNavigationBarItem(
        icon: Icon(Icons.account_circle_outlined, size: 28.0),
        activeIcon: Icon(Icons.account_circle, size: 28.0),
        label: 'Profile',
        tooltip: '',
      ),
    );

    return items;
  }
}

import 'package:flutter/material.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/app_config.dart';
import 'package:gw_community/l10n/l10n.dart';
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
            bottomNavigationBar: _FittingBottomNavBar(
              currentIndex: currentIndex,
              onTap: (i) => viewModel.selectTab(tabs.keys.toList()[i]),
              items: _buildBottomNavItems(context, appState, config),
              selectedColor: AppTheme.of(context).primary,
              unselectedColor: const Color(0xFF95A1AC),
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
    final l10n = context.l10n;
    final items = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: const Icon(Icons.home_outlined, size: 28.0),
        label: l10n.navHome,
        tooltip: '',
      ),
    ];

    // Library item - only if enabled for the user's group
    if (appState.enableLibraryModule) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.library_music, size: 24.0),
          label: l10n.navLibrary,
          tooltip: '',
        ),
      );
    }

    // Journey item - only if enabled for the user's group
    if (appState.enableJourneyModule) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(FFIcons.kiconLogo, size: 24.0),
          activeIcon: const Icon(FFIcons.kiconLogo, size: 24.0),
          label: l10n.navJourney,
          tooltip: '',
        ),
      );
    }

    // Add Community tab if enabled globally AND per-group
    if (config.enableCommunityModule && appState.enableCommunityModule) {
      items.add(
        BottomNavigationBarItem(
          icon: const Icon(Icons.public, size: 28.0),
          activeIcon: const Icon(Icons.public, size: 28.0),
          label: l10n.navCommunity,
          tooltip: '',
        ),
      );
    }

    // Profile is always last
    items.add(
      BottomNavigationBarItem(
        icon: const Icon(Icons.account_circle_outlined, size: 28.0),
        activeIcon: const Icon(Icons.account_circle, size: 28.0),
        label: l10n.navProfile,
        tooltip: '',
      ),
    );

    return items;
  }
}

class _FittingBottomNavBar extends StatelessWidget {
  const _FittingBottomNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.selectedColor,
    required this.unselectedColor,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> items;
  final Color selectedColor;
  final Color unselectedColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 8.0,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kBottomNavigationBarHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 2.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconTheme(
                            data: IconThemeData(
                              color: i == currentIndex ? selectedColor : unselectedColor,
                              size: 24.0,
                            ),
                            child: i == currentIndex ? items[i].activeIcon : items[i].icon,
                          ),
                          if (i == currentIndex) ...[
                            const SizedBox(height: 2.0),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                items[i].label ?? '',
                                maxLines: 1,
                                softWrap: false,
                                style: TextStyle(
                                  color: selectedColor,
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  height: 1.1,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

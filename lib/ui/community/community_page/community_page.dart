import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/ui/community/community_page/view_model/community_view_model.dart';
import 'package:gw_community/ui/community/community_page/widgets/events_tab_widget.dart';
import 'package:gw_community/ui/community/community_page/widgets/groups_tab_widget.dart';
import 'package:gw_community/ui/community/community_page/widgets/sharings_tab_widget.dart';
import 'package:gw_community/ui/community/my_experiences_page/my_experiences_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/support/support_page/support_page.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({
    super.key,
    int? tabIndex,
  }) : tabIndex = tabIndex ?? 0;

  /// parametro para controlar qual tab do tabbat mostrar
  final int tabIndex;

  static String routeName = 'communityPage';
  static String routePath = '/communityPage';

  @override
  State<CommunityPage> createState() => _CommunityPageState();
}

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin, RouteAware {
  late TabController _tabController;
  CommunityViewModel? _viewModel;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // On page load action.
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      safeSetState(() {});
    });

    _tabController = TabController(
      vsync: this,
      length: 3,
      initialIndex: min(
          valueOrDefault<int>(
            widget.tabIndex,
            0,
          ),
          2),
    )..addListener(() => safeSetState(() {}));

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Subscribe to route changes to refresh data when returning to this page
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    // Called when returning to this page from another page
    // Refresh the sharings stream to get updated data
    _viewModel?.refreshSharings();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _tabController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return ChangeNotifierProvider(
      create: (context) => CommunityViewModel(
        repository: CommunityRepository(),
        currentUserUid: context.currentUserIdOrEmpty,
      ),
      child: Consumer<CommunityViewModel>(
        builder: (context, viewModel, child) {
          // Store reference for RouteAware callback
          _viewModel = viewModel;
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primary,
              automaticallyImplyLeading: false,
              title: Text(
                'Community',
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Colors.white,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              actions: [
                PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) {
                    if (value == 'my_experiences') {
                      context.pushNamed(MyExperiencesPage.routeName);
                    } else if (value == 'help_center') {
                      context.pushNamed(
                        SupportPage.routeName,
                        queryParameters: {
                          'contextType': 'community',
                        }.withoutNulls,
                      );
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'my_experiences',
                      child: Row(
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 20,
                            color: AppTheme.of(context).secondary,
                          ),
                          const SizedBox(width: 12),
                          const Text('My Experiences'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'help_center',
                      child: Row(
                        children: [
                          Icon(
                            Icons.support_agent,
                            size: 20,
                            color: AppTheme.of(context).secondary,
                          ),
                          const SizedBox(width: 12),
                          const Text('Help'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
              centerTitle: true,
              elevation: 4.0,
            ),
            body: SafeArea(
              top: true,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Align(
                          alignment: const Alignment(0, 0),
                          child: TabBar(
                            labelColor: AppTheme.of(context).primary,
                            labelStyle: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                ),
                            unselectedLabelStyle: const TextStyle(),
                            indicatorColor: AppTheme.of(context).secondary,
                            isScrollable: true,
                            labelPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            tabs: const [
                              Tab(
                                text: 'Experiences',
                              ),

                              // Manage groups that are obtained by an action when user click on groups tab
                              Tab(
                                text: 'Groups',
                              ),

                              Tab(
                                text: 'Events',
                              ),
                            ],
                            controller: _tabController,
                            onTap: (i) async {
                              await viewModel.onTabChanged(i);
                              safeSetState(() {});
                            },
                          ),
                        ),
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              KeepAliveWidgetWrapper(
                                builder: (context) => const SharingsTabWidget(),
                              ),
                              KeepAliveWidgetWrapper(
                                builder: (context) => const GroupsTabWidget(),
                              ),
                              KeepAliveWidgetWrapper(
                                builder: (context) => const EventsTabWidget(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

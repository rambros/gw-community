import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';

import 'widgets/sharings_tab_widget.dart';
import 'widgets/groups_tab_widget.dart';
import 'widgets/events_tab_widget.dart';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'view_model/community_view_model.dart';
import '/data/repositories/community_repository.dart';
import '/utils/context_extensions.dart';

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

class _CommunityPageState extends State<CommunityPage> with TickerProviderStateMixin {
  late TabController _tabController;

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
  void dispose() {
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
          return Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).primary,
              automaticallyImplyLeading: false,
              title: Text(
                'Community',
                style: FlutterFlowTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                      ),
                      color: Colors.white,
                      fontSize: 20.0,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                    ),
              ),
              actions: const [],
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
                            labelColor: FlutterFlowTheme.of(context).primary,
                            labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                            unselectedLabelStyle: const TextStyle(),
                            indicatorColor: FlutterFlowTheme.of(context).secondary,
                            isScrollable: true,
                            labelPadding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                            tabs: const [
                              Tab(
                                text: 'Sharings',
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';

import 'view_model/journeys_list_view_model.dart';
import 'widgets/journey_card_widget.dart';
import '/ui/journey/journey_page/journey_page.dart';

class JourneysListPage extends StatefulWidget {
  const JourneysListPage({super.key});

  static String routeName = 'journeysListPage';
  static String routePath = '/journeysListPage';

  @override
  State<JourneysListPage> createState() => _JourneysListPageState();
}

class _JourneysListPageState extends State<JourneysListPage> with TickerProviderStateMixin {
  late TabController _tabBarController;

  @override
  void initState() {
    super.initState();
    _tabBarController = TabController(
      vsync: this,
      length: 2,
      initialIndex: 0,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Data is loaded in ViewModel constructor, but we can reload if needed
      // context.read<JourneysListViewModel>().loadData();
    });
  }

  @override
  void dispose() {
    _tabBarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<JourneysListViewModel>();

    return Scaffold(
      backgroundColor: FlutterFlowTheme.of(context).secondary,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        title: Text(
          'Journeys',
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
          children: [
            Expanded(
              child: Column(
                children: [
                  Align(
                    alignment: const Alignment(0.0, 0),
                    child: TabBar(
                      labelColor: FlutterFlowTheme.of(context).primaryText,
                      unselectedLabelColor: FlutterFlowTheme.of(context).alternate,
                      labelStyle: FlutterFlowTheme.of(context).titleMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                            ),
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context).titleMedium.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                          ),
                      unselectedLabelStyle: const TextStyle(),
                      indicatorColor: FlutterFlowTheme.of(context).primary,
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      tabs: const [
                        Tab(text: 'My Journeys'),
                        Tab(text: 'Available Journeys'),
                      ],
                      controller: _tabBarController,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      controller: _tabBarController,
                      children: [
                        _buildUserJourneysTab(context, viewModel),
                        _buildAvailableJourneysTab(context, viewModel),
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
  }

  Widget _buildUserJourneysTab(BuildContext context, JourneysListViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: SpinKitRipple(
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Center(child: Text(viewModel.errorMessage!));
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: viewModel.userJourneys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final item = viewModel.userJourneys[index];
                return JourneyCardWidget(
                  title: item.title ?? 'Journey',
                  stepsCompleted: item.stepsCompleted ?? 0,
                  stepsTotal: item.stepsTotal ?? 0,
                  buttonText: 'RESUME',
                  onTap: () async {
                    context.pushNamed(
                      JourneyPage.routeName,
                      queryParameters: {
                        'journeyId': serializeParam(
                          item.journeyId,
                          ParamType.int,
                        ),
                      }.withoutNulls,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableJourneysTab(BuildContext context, JourneysListViewModel viewModel) {
    if (viewModel.isLoading) {
      return Center(
        child: SizedBox(
          width: 50.0,
          height: 50.0,
          child: SpinKitRipple(
            color: FlutterFlowTheme.of(context).primary,
            size: 50.0,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(0, 8.0, 0, 8.0),
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: viewModel.availableJourneys.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16.0),
              itemBuilder: (context, index) {
                final item = viewModel.availableJourneys[index];
                return JourneyCardWidget(
                  title: item.title ?? 'Journey',
                  stepsCompleted: 0,
                  stepsTotal: item.stepsTotal ?? 0,
                  buttonText: 'View more',
                  onTap: () async {
                    context.pushNamed(
                      JourneyPage.routeName,
                      queryParameters: {
                        'journeyId': serializeParam(
                          item.id,
                          ParamType.int,
                        ),
                      }.withoutNulls,
                      extra: <String, dynamic>{
                        kTransitionInfoKey: const TransitionInfo(
                          hasTransition: true,
                          transitionType: PageTransitionType.fade,
                          duration: Duration(milliseconds: 0),
                        ),
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/ui/journey/journey_list_page/view_model/journey_list_view_model.dart';
import 'package:gw_community/ui/journey/journey_list_page/widgets/journeys_tab_widget.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class JourneyListPage extends StatefulWidget {
  const JourneyListPage({
    super.key,
  });

  static String routeName = 'journeyListPage';
  static String routePath = '/journeyListPage';

  @override
  State<JourneyListPage> createState() => _JourneyListPageState();
}

class _JourneyListPageState extends State<JourneyListPage> with RouteAware {
  JourneyListViewModel? _viewModel;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    // Journeys are loaded automatically in JourneyListViewModel._init()
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
    // Refresh the journeys list to get updated data
    _viewModel?.refreshJourneysList();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();

    return ChangeNotifierProvider(
      create: (context) => JourneyListViewModel(
        repository: JourneysRepository(),
        currentUserUid: context.currentUserIdOrEmpty,
      ),
      child: Consumer<JourneyListViewModel>(
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
                'Journeys',
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
              actions: const [],
              centerTitle: true,
              elevation: 4.0,
            ),
            body: const SafeArea(
              top: true,
              child: JourneysTabWidget(),
            ),
          );
        },
      ),
    );
  }
}

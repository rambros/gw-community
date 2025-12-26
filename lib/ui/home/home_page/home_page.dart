import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/widgets/notification_bell/notification_bell_widget.dart';
import 'view_model/home_view_model.dart';
import 'widgets/home_event_card.dart';
import 'widgets/home_journey_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'homePage';
  static String routePath = '/homePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    // Initial data load
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTheme.of(context).primaryBackground,
      body: SafeArea(
        top: true,
        child: viewModel.isLoading && viewModel.userProfile == null
            ? Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitRipple(
                    color: AppTheme.of(context).primary,
                    size: 50.0,
                  ),
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildHeader(context),
                    _buildWelcomeMessage(context, viewModel),
                    _buildCommunityMessage(context),
                    _buildSectionTitle(context, 'My Journeys'),

                    // Journey Card
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 6.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                            child: HomeJourneyCard(
                              journeyDetails: viewModel.journeyDetails,
                              userJourneyProgress: viewModel.userJourneyProgress,
                              hasStartedJourney: viewModel.userJourneys.isNotEmpty,
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildSectionTitle(context, 'Upcoming Events'),

                    // Events List
                    ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: viewModel.upcomingEvents.length,
                      itemBuilder: (context, index) {
                        final event = viewModel.upcomingEvents[index];
                        return HomeEventCard(eventRow: event);
                      },
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 0.0),
      child: Stack(
        children: [
          // Notification bell positioned at top right
          const Positioned(
            top: 0,
            right: 0,
            child: NotificationBellWidget(),
          ),
          // Centered logo
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Image.asset(
                'assets/images/GoodWishes_RGB_Logo_Stacked_600.png',
                height: 88.0,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWelcomeMessage(BuildContext context, HomeViewModel viewModel) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 36.0, 0.0, 18.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Welcome, ',
            style: AppTheme.of(context).headlineSmall,
          ),
          if (viewModel.userProfile != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 3.0, 0.0, 0.0),
              child: Text(
                viewModel.userProfile!.firstName!,
                style: AppTheme.of(context).headlineSmall,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCommunityMessage(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Where are a community of nn well wishers\ncreating together a new world',
          textAlign: TextAlign.center,
          style: AppTheme.of(context).bodyMedium.override(
                color: Colors.black,
                fontSize: 16.0,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 8.0),
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: AppTheme.of(context).headlineSmall.override(
                    color: AppTheme.of(context).secondary,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

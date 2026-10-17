import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/community_page/community_page.dart';
import 'package:gw_community/ui/community/group_details_page/group_details_page.dart';
import 'package:gw_community/ui/community/widgets/group_card.dart';
import 'package:gw_community/ui/core/nav_bar/view_model/nav_bar_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/notification_bell/notification_bell_widget.dart';
import 'package:gw_community/ui/home/home_page/view_model/home_view_model.dart';
import 'package:gw_community/ui/home/home_page/widgets/home_event_card.dart';
import 'package:gw_community/ui/home/home_page/widgets/home_journey_card.dart';
import 'package:gw_community/ui/journey/journey_list_page/journey_list_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static String routeName = 'homePage';
  static String routePath = '/homePage';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  static const _hPad = 16.0;
  static const _sectionTop = 24.0;
  static const _titleToCards = 8.0;
  static const _cardGap = 12.0;
  static const _maxHomeJourneys = 3;
  static const _maxHomeGroups = 2;

  final scaffoldKey = GlobalKey<ScaffoldState>();
  bool _subscribedRoute = false;

  @override
  void initState() {
    super.initState();

    // Initial data load
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<HomeViewModel>().loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribedRoute = true;
    }
  }

  /// Home stays mounted under group and event pages. Deletes there update
  /// the group stream, but this list is a one-shot query from [initState].
  @override
  void didPopNext() {
    if (!mounted) return;
    context.read<HomeViewModel>().loadData(blocking: false);
  }

  @override
  void dispose() {
    if (_subscribedRoute) routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();
    final appState = context.watch<FFAppState>();

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
            : RefreshIndicator(
                color: AppTheme.of(context).primary,
                onRefresh: () =>
                    context.read<HomeViewModel>().loadData(blocking: false),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader(context),
                      _buildWelcomeMessage(context, viewModel),
                      _buildCommunityMessage(context),
                      if (appState.enableJourneyModule) ...[
                        _buildSectionTitle(
                          context,
                          context.l10n.myJourneys,
                          actionLabel:
                              viewModel.userJourneyProgressList.isNotEmpty
                                  ? context.l10n.seeAllJourneys
                                  : null,
                          onAction: viewModel.userJourneyProgressList.isNotEmpty
                              ? () => _openNavTab(
                                    'journeyPage',
                                    JourneyListPage.routeName,
                                  )
                              : null,
                        ),
                        if (viewModel.userJourneyProgressList.isEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: _hPad),
                            child: Text(
                              context.l10n.noJourneysStarted,
                              style: AppTheme.of(context).bodyMedium.override(
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          )
                        else
                          _buildCardList(
                            viewModel.userJourneyProgressList
                                .take(_maxHomeJourneys)
                                .map(
                                  (progress) => HomeJourneyCard(
                                      userJourneyProgress: progress),
                                )
                                .toList(),
                          ),
                      ],
                      if (viewModel.userGroups.isNotEmpty) ...[
                        _buildSectionTitle(
                          context,
                          context.l10n.myGroups,
                          actionLabel: context.l10n.seeAllGroups,
                          onAction: () => _openNavTab(
                            'communityPage',
                            CommunityPage.routeName,
                          ),
                        ),
                        _buildCardList(
                          viewModel.userGroups
                              .take(_maxHomeGroups)
                              .map((group) => _buildGroupItem(context, group))
                              .toList(),
                        ),
                      ] else ...[
                        _buildSectionTitle(
                          context,
                          context.l10n.otherGroups,
                          actionLabel: viewModel.publicGroups.isNotEmpty
                              ? context.l10n.seeAllGroups
                              : null,
                          onAction: viewModel.publicGroups.isNotEmpty
                              ? () => _openNavTab(
                                    'communityPage',
                                    CommunityPage.routeName,
                                  )
                              : null,
                        ),
                        _buildCardList(
                          viewModel.publicGroups
                              .take(_maxHomeGroups)
                              .map((group) => _buildGroupItem(context, group))
                              .toList(),
                        ),
                      ],
                      _buildSectionTitle(context, context.l10n.upcomingEvents),
                      _buildCardList(
                        viewModel.upcomingEvents
                            .map(
                              (event) => HomeEventCard(
                                eventRow: event,
                                groupName:
                                    viewModel.getGroupNameById(event.groupId),
                                groupImageUrl:
                                    viewModel.groupImageUrlById(event.groupId),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 24.0),
                    ],
                  ),
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
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${context.l10n.welcomeComma} ',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(_hPad, 0.0, _hPad, 0.0),
      child: SizedBox(
        width: double.infinity,
        child: Text(
          context.l10n.communityTagline,
          textAlign: TextAlign.center,
          style: AppTheme.of(context).bodyMedium.override(
                color: Colors.black,
                fontSize: 15.0,
                lineHeight: 1.4,
              ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
    BuildContext context,
    String title, {
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding:
          const EdgeInsets.fromLTRB(_hPad, _sectionTop, _hPad, _titleToCards),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              textAlign: TextAlign.start,
              style: AppTheme.of(context).headlineSmall.override(
                    color: AppTheme.of(context).secondary,
                    fontSize: 22.0,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          if (actionLabel != null && onAction != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                actionLabel,
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).primary,
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  void _openNavTab(String pageName, String fallbackRoute) {
    try {
      context.read<NavBarViewModel>().selectTab(pageName);
    } on ProviderNotFoundException {
      context.goNamed(fallbackRoute);
    }
  }

  Widget _buildCardList(List<Widget> cards) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: _hPad),
      child: Column(
        children: [
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: _cardGap),
            cards[i],
          ],
        ],
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, CcGroupsRow group) {
    return InkWell(
      onTap: () async {
        await context.pushNamed(
          GroupDetailsPage.routeName,
          queryParameters: {
            'groupRow': serializeParam(
              group,
              ParamType.SupabaseRow,
            ),
          }.withoutNulls,
        );
      },
      child: GroupCard(
        key: ValueKey('home-group-${group.id}'),
        groupRow: group,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

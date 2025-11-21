import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/data/repositories/group_repository.dart';
import '/data/repositories/sharing_repository.dart';
import '/data/repositories/event_repository.dart';
import '/data/repositories/notification_repository.dart';
import '/backend/supabase/supabase.dart';
import 'view_model/group_details_view_model.dart';
import 'widgets/group_sharings_tab.dart';
import 'widgets/group_events_tab.dart';
import 'widgets/group_notifications_tab.dart';
import 'widgets/group_about_tab.dart';
import '../group_actions_page/group_actions_sheet.dart';
import 'package:webviewx_plus/webviewx_plus.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class GroupDetailsPage extends StatefulWidget {
  final CcGroupsRow groupRow;

  const GroupDetailsPage({
    super.key,
    required this.groupRow,
  });

  static String routeName = 'groupDetails';
  static String routePath = '/groupDetails';

  @override
  State<GroupDetailsPage> createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupDetailsViewModel(
        context.read<GroupRepository>(),
        context.read<SharingRepository>(),
        context.read<EventRepository>(),
        context.read<NotificationRepository>(),
        widget.groupRow,
      )..init(this),
      child: const GroupDetailsPageView(),
    );
  }
}

class GroupDetailsPageView extends StatelessWidget {
  const GroupDetailsPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          actions: const [],
          flexibleSpace: FlexibleSpaceBar(
            background: Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  FlutterFlowIconButton(
                    borderColor: Colors.transparent,
                    borderRadius: 30.0,
                    borderWidth: 1.0,
                    buttonSize: 60.0,
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: Colors.white,
                      size: 30.0,
                    ),
                    onPressed: () async {
                      context.safePop();
                    },
                  ),
                  Text(
                    'Group Details',
                    style: FlutterFlowTheme.of(context).titleLarge.override(
                          font: GoogleFonts.poppins(
                            fontWeight: FlutterFlowTheme.of(context).titleLarge.fontWeight,
                          ),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          fontSize: 20.0,
                        ),
                  ),
                  FFButtonWidget(
                    onPressed: () async {
                      await showModalBottomSheet(
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        enableDrag: false,
                        useSafeArea: true,
                        context: context,
                        builder: (context) {
                          return WebViewAware(
                            child: GestureDetector(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                FocusManager.instance.primaryFocus?.unfocus();
                              },
                              child: Padding(
                                padding: MediaQuery.viewInsetsOf(context),
                                child: GroupActionsSheet(
                                  groupId: group.id,
                                  currentMemberCount: group.numberMembers ?? 0,
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    text: '',
                    icon: const FaIcon(
                      FontAwesomeIcons.ellipsisH,
                      size: 15.0,
                    ),
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: Colors.white,
                          ),
                      elevation: 0.0,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                ],
              ),
            ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16.0),
                          child: Image.network(
                            group.groupImageUrl!,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(
                              width: 80.0,
                              height: 80.0,
                              color: Colors.grey[300],
                              child: const Icon(Icons.image_not_supported),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                          child: Text(
                            group.name!,
                            style: FlutterFlowTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.lexendDeca(),
                                ),
                          ),
                        ),
                        Text(
                          '${group.groupPrivacy} group - ${formatNumber(
                            group.numberMembers,
                            formatType: FormatType.compact,
                          )} members',
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                                color: FlutterFlowTheme.of(context).secondary,
                                fontSize: 14.0,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Tabs
              Expanded(
                child: Column(
                  children: [
                    Align(
                      alignment: const Alignment(0.0, 0),
                      child: TabBar(
                        isScrollable: true,
                        labelColor: FlutterFlowTheme.of(context).primary,
                        labelStyle: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              fontSize: 16.0,
                            ),
                        unselectedLabelStyle: const TextStyle(),
                        indicatorColor: FlutterFlowTheme.of(context).secondary,
                        tabs: const [
                          Tab(text: 'Share'),
                          Tab(text: 'Events'),
                          Tab(text: 'Notifications'),
                          Tab(text: 'About'),
                        ],
                        controller: viewModel.tabController,
                      ),
                    ),
                    Expanded(
                      child: TabBarView(
                        controller: viewModel.tabController,
                        children: const [
                          GroupSharingsTab(),
                          GroupEventsTab(),
                          GroupNotificationsTab(),
                          GroupAboutTab(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

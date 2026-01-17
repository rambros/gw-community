import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/event_repository.dart';
import 'package:gw_community/data/repositories/experience_moderation_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/sharing_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/group_about_tab.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/group_events_tab.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/group_journeys_tab.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/group_announcements_tab.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/group_sharings_tab.dart';
import 'package:gw_community/ui/community/group_details_page/member_management_page/member_management_page.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/community/group_moderation_page/group_moderation_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';

import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
        context.read<AnnouncementRepository>(),
        context.read<JourneysRepository>(),
        context.read<LearnRepository>(),
        widget.groupRow,
        currentUserId: context.currentUserIdOrEmpty,
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
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
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
                    style: AppTheme.of(context).titleLarge.override(
                          font: GoogleFonts.poppins(
                            fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                          ),
                          color: AppTheme.of(context).primaryBackground,
                          fontSize: 20.0,
                        ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Member management button (ADMIN or GROUP_MANAGER only)
                      if (FFAppState().loginUser.roles.hasAdminOrGroupManager)
                        FlutterFlowIconButton(
                          borderColor: Colors.transparent,
                          borderRadius: 30.0,
                          borderWidth: 1.0,
                          buttonSize: 48.0,
                          icon: const Icon(
                            Icons.people,
                            color: Colors.white,
                            size: 24.0,
                          ),
                          onPressed: () async {
                            await context.pushNamed(
                              MemberManagementPage.routeName,
                              queryParameters: {
                                'groupId': '${group.id}',
                                'groupName': group.name ?? 'Group',
                              },
                            );
                            viewModel.refreshGroup();
                          },
                        ),
                      // Moderation button (ADMIN or GROUP_MANAGER only)
                      if (FFAppState().loginUser.roles.hasAdminOrGroupManager)
                        FutureBuilder<int>(
                          future: ExperienceModerationRepository().getPendingCountForGroup(group.id),
                          builder: (context, snapshot) {
                            final pendingCount = snapshot.data ?? 0;
                            return Badge(
                              label: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              isLabelVisible: pendingCount > 0,
                              backgroundColor: Colors.red.shade700,
                              child: FlutterFlowIconButton(
                                borderColor: Colors.transparent,
                                borderRadius: 30.0,
                                borderWidth: 1.0,
                                buttonSize: 48.0,
                                icon: const Icon(
                                  Icons.admin_panel_settings,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                                onPressed: () async {
                                  await context.pushNamed(
                                    GroupModerationPage.routeName,
                                    queryParameters: {
                                      'groupId': '${group.id}',
                                      'groupName': group.name ?? 'Group',
                                    },
                                  );
                                  // Refresh group details after moderation
                                  viewModel.refreshGroup();
                                },
                              ),
                            );
                          },
                        ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          color: Colors.white,
                        ),
                        onSelected: (value) async {
                          if (value == 'group_resources') {
                            await context.pushNamed(
                              'learnListPage',
                              queryParameters: {
                                'groupId': '${group.id}',
                                'customTitle': 'Group Resources',
                              },
                            );
                          } else if (value == 'about') {
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
                                      child: Container(
                                        height: MediaQuery.sizeOf(context).height * 0.85,
                                        decoration: BoxDecoration(
                                          color: AppTheme.of(context).secondaryBackground,
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(16.0),
                                            topRight: Radius.circular(16.0),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.all(16.0),
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    'About this group',
                                                    style: AppTheme.of(context).titleMedium,
                                                  ),
                                                  IconButton(
                                                    icon: const Icon(Icons.close),
                                                    onPressed: () => Navigator.pop(context),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Expanded(
                                              child: ChangeNotifierProvider.value(
                                                value: viewModel,
                                                child: const GroupAboutTab(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          } else if (value == 'edit') {
                            await context.pushNamed(
                              GroupEditPage.routeName,
                              extra: <String, dynamic>{
                                'groupRow': group,
                              },
                            );
                            await viewModel.refreshGroup();
                          } else if (value == 'leave') {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (alertDialogContext) {
                                return AlertDialog(
                                  title: const Text('Leave Group'),
                                  content: const Text('Are you sure you want to leave this group?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(alertDialogContext, false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(alertDialogContext, true),
                                      child: const Text('Leave'),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (confirm == true) {
                              if (context.mounted) {
                                final success = await viewModel.leaveGroup(context);
                                if (success && context.mounted) {
                                  context.safePop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Left the group successfully',
                                        style: TextStyle(
                                          color: AppTheme.of(context).primaryText,
                                        ),
                                      ),
                                      backgroundColor: AppTheme.of(context).secondary,
                                    ),
                                  );
                                }
                              }
                            }
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'group_resources',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.library_books_outlined,
                                  size: 20,
                                  color: AppTheme.of(context).secondary,
                                ),
                                const SizedBox(width: 12),
                                const Text('Group Resources'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'about',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  size: 20,
                                  color: AppTheme.of(context).secondary,
                                ),
                                const SizedBox(width: 12),
                                const Text('About this group'),
                              ],
                            ),
                          ),
                          if (FFAppState().loginUser.roles.hasAdminOrGroupManager)
                            PopupMenuItem(
                              value: 'edit',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit_rounded,
                                    size: 20,
                                    color: AppTheme.of(context).secondary,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Edit Group'),
                                ],
                              ),
                            ),
                          if (viewModel.isMember)
                            PopupMenuItem(
                              value: 'leave',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.exit_to_app_rounded,
                                    size: 20,
                                    color: AppTheme.of(context).secondary,
                                  ),
                                  const SizedBox(width: 12),
                                  const Text('Leave Group'),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
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
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16.0),
                      child: Image.network(
                        group.groupImageUrl!,
                        width: 70.0,
                        height: 70.0,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 70.0,
                          height: 70.0,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            group.name!,
                            style: AppTheme.of(context).headlineSmall.override(
                                  font: GoogleFonts.lexendDeca(),
                                  fontSize: 20.0,
                                ),
                          ),
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 2.0, 0.0, 0.0),
                            child: Text(
                              '${group.groupPrivacy} group - ${formatNumber(
                                group.numberMembers,
                                formatType: FormatType.compact,
                              )} ${group.numberMembers == 1 ? 'member' : 'members'}',
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(),
                                    color: AppTheme.of(context).secondary,
                                    fontSize: 14.0,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Tabs
              Expanded(
                child: viewModel.isCheckingMembership
                    ? Center(
                        child: SpinKitRipple(
                          color: AppTheme.of(context).primary,
                          size: 50.0,
                        ),
                      )
                    : viewModel.shouldShowOnlyAbout
                        ? const GroupAboutTab(key: ValueKey('page_about_only'))
                        : Column(
                            children: [
                              Align(
                                alignment: const Alignment(0.0, 0),
                                child: TabBar(
                                  isScrollable: true,
                                  labelColor: AppTheme.of(context).primary,
                                  labelStyle: AppTheme.of(context).bodyMedium.override(
                                        font: GoogleFonts.lexendDeca(),
                                        fontSize: 16.0,
                                      ),
                                  unselectedLabelStyle: const TextStyle(),
                                  indicatorColor: AppTheme.of(context).secondary,
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  tabs: [
                                    const Tab(key: ValueKey('tab_experiences'), text: 'Experiences'),
                                    const Tab(key: ValueKey('tab_events'), text: 'Events'),
                                    Tab(
                                      key: const ValueKey('tab_notifications'),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Text('Announcements'),
                                          if (viewModel.unreadNotificationCount > 0) ...[
                                            const SizedBox(width: 6),
                                            Container(
                                              padding: const EdgeInsets.all(4),
                                              decoration: BoxDecoration(
                                                color: AppTheme.of(context).secondary,
                                                shape: BoxShape.circle,
                                              ),
                                              constraints: const BoxConstraints(
                                                minWidth: 16,
                                                minHeight: 16,
                                              ),
                                              child: Center(
                                                child: Text(
                                                  '${viewModel.unreadNotificationCount}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Tab(key: ValueKey('tab_journeys'), text: 'Journeys'),
                                  ],
                                  controller: viewModel.tabController,
                                ),
                              ),
                              Expanded(
                                child: TabBarView(
                                  key: const ValueKey('tab_view_content'),
                                  controller: viewModel.tabController,
                                  children: const [
                                    GroupSharingsTab(key: ValueKey('page_experiences')),
                                    GroupEventsTab(key: ValueKey('page_events')),
                                    GroupAnnouncementsTab(key: ValueKey('page_notifications')),
                                    GroupJourneysTab(key: ValueKey('page_journeys')),
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

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class GroupAnnouncementsTab extends StatelessWidget {
  const GroupAnnouncementsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        'Messages and announcements shared by the facilitator.',
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondary,
                              fontSize: 13.0,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: StreamBuilder<List<CcViewNotificationsUsersRow>>(
                  // Key baseada nos IDs lidos para forçar reconstrução quando mudarem
                  key: ValueKey(viewModel.readNotificationIds.hashCode),
                  stream: viewModel.notificationsStream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: SizedBox(
                          width: 50.0,
                          height: 50.0,
                          child: SpinKitRipple(
                            color: AppTheme.of(context).primary,
                            size: 50.0,
                          ),
                        ),
                      );
                    }
                    final notificationsList = snapshot.data!;
                    if (notificationsList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No announcements yet.',
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ),
                      );
                    }

                    // Usa os IDs lidos do viewModel (atualizados via notifyListeners)
                    final readIds = viewModel.readNotificationIds;
                    final unreadList = notificationsList.where((n) => !readIds.contains(n.id!)).toList();
                    final readList = notificationsList.where((n) => readIds.contains(n.id!)).toList();

                    return Column(
                      children: [
                        // Unread Announcements
                        if (unreadList.isEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 32.0, 24.0, 32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppTheme.of(context).success.withOpacity(0.15),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Icon(
                                        Icons.check_rounded,
                                        color: AppTheme.of(context).success,
                                        size: 32.0,
                                      ),
                                    ),
                                  ),
                                ),
                                Text(
                                  'You’re all caught up.',
                                  textAlign: TextAlign.center,
                                  style: AppTheme.of(context).headlineMedium.override(
                                        font: GoogleFonts.poppins(),
                                        color: AppTheme.of(context).secondary,
                                        fontSize: 22.0,
                                      ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                  child: Text(
                                    'There are no new announcements at the moment.',
                                    textAlign: TextAlign.center,
                                    style: AppTheme.of(context).bodyMedium.override(
                                          font: GoogleFonts.lexendDeca(),
                                          color: AppTheme.of(context).gray600,
                                        ),
                                  ),
                                ),
                                if (readList.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                    child: Text(
                                      'Past announcements are available below.',
                                      textAlign: TextAlign.center,
                                      style: AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.lexendDeca(),
                                            color: AppTheme.of(context).grayIcon,
                                          ),
                                    ),
                                  ),
                              ],
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: unreadList.length,
                            itemBuilder: (context, index) {
                              return _buildAnnouncementCard(context, viewModel, unreadList[index], false);
                            },
                          ),

                        // Past Announcements (Read)
                        if (readList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 24.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                listTileTheme: ListTileThemeData(
                                  dense: true,
                                  minVerticalPadding: 0,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  color: const Color(0xFFF1F4F8), // Light grey background
                                  child: ExpansionTile(
                                    title: Text(
                                      'Past announcements',
                                      style: AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.lexendDeca(),
                                            color: AppTheme.of(context).secondary,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    backgroundColor: const Color(0xFFF1F4F8),
                                    collapsedBackgroundColor: const Color(0xFFF1F4F8),
                                    iconColor: AppTheme.of(context).primary,
                                    collapsedIconColor: AppTheme.of(context).secondary,
                                    children: [
                                      ListView.builder(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: readList.length,
                                        itemBuilder: (context, index) {
                                          return _buildAnnouncementCard(context, viewModel, readList[index], true);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton.extended(
            onPressed: () async {
              context.pushNamed(
                AnnouncementAddPage.routeName,
                queryParameters: {
                  'groupId': serializeParam(
                    group.id,
                    ParamType.int,
                  ),
                  'groupName': serializeParam(
                    group.name,
                    ParamType.String,
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
            backgroundColor: AppTheme.of(context).primary,
            elevation: 8.0,
            icon: Icon(
              Icons.add,
              color: AppTheme.of(context).primaryBackground,
            ),
            label: Text(
              'New announcement',
              style: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(),
                    color: AppTheme.of(context).primaryBackground,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnnouncementCard(
    BuildContext context,
    GroupDetailsViewModel viewModel,
    CcViewNotificationsUsersRow notification,
    bool isRead,
  ) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
        child: InkWell(
          onTap: () async {
            // Marca como lida antes de navegar
            await viewModel.markNotificationAsRead(notification.id!);

            if (!context.mounted) return;

            await context.pushNamed(
              AnnouncementViewPage.routeName,
              queryParameters: {
                'announcementId': serializeParam(
                  notification.id,
                  ParamType.int,
                ),
              }.withoutNulls,
              extra: {
                'sharingRow': notification,
              },
            );

            // Recarrega os IDs lidos após retornar (caso o anúncio tenha sido editado)
            if (context.mounted) {
              await viewModel.refreshReadNotifications();
            }
          },
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: isRead
                  ? AppTheme.of(context).primaryBackground
                  : AppTheme.of(context).primaryBackground.withOpacity(0.95),
              boxShadow: const [
                BoxShadow(
                  blurRadius: 15.0,
                  color: Color(0x1A000000),
                  offset: Offset(0.0, 7.0),
                  spreadRadius: 3.0,
                )
              ],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(
                color: isRead ? AppTheme.of(context).primaryBackground : AppTheme.of(context).primary.withOpacity(0.3),
                width: isRead ? 1.0 : 2.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(6.0),
                              child: Icon(
                                Icons.campaign_rounded,
                                color: Colors.white,
                                size: 20.0,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            notification.title!,
                            style: AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.inter(
                                    fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                                  ),
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 16.0,
                                ),
                          ),
                        ),
                        if (!isRead)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Container(
                              width: 10.0,
                              height: 10.0,
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
                    child: Text(
                      '${dateTimeFormat('MMM d', notification.updatedAt)} - From ${notification.displayName ?? 'User'} - Facilitator',
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

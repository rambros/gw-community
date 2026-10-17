import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
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
                padding:
                    const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        context.l10n.messagesByFacilitator,
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
                padding:
                    const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
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
                            context.l10n.noMessagesYet,
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ),
                      );
                    }

                    final pinnedList = notificationsList
                        .where((n) => n.isPinned)
                        .toList()
                      ..sort(_newestPinFirst);
                    final unpinned = notificationsList.where((n) => !n.isPinned);
                    final unreadList = unpinned
                        .where((n) => viewModel.messageNeedsAttention(n.id!))
                        .toList();
                    final readList = unpinned
                        .where((n) => !viewModel.messageNeedsAttention(n.id!))
                        .toList();
                    final hasUnread = unreadList.isNotEmpty ||
                        pinnedList.any(
                            (n) => viewModel.messageNeedsAttention(n.id!));

                    return Column(
                      children: [
                        if (pinnedList.isNotEmpty)
                          ListView.builder(
                            padding: const EdgeInsets.only(top: 8.0),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: pinnedList.length,
                            itemBuilder: (context, index) {
                              final notification = pinnedList[index];
                              return _buildAnnouncementCard(
                                context,
                                viewModel,
                                notification,
                                !viewModel.messageNeedsAttention(notification.id!),
                              );
                            },
                          ),
                        if (!hasUnread)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                24.0, 32.0, 24.0, 32.0),
                            child: Text(
                              'There are no new messages at the moment.',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(),
                                    color: AppTheme.of(context).grayIcon,
                                  ),
                            ),
                          )
                        else if (unreadList.isNotEmpty)
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: unreadList.length,
                            itemBuilder: (context, index) {
                              return _buildAnnouncementCard(
                                  context, viewModel, unreadList[index], false);
                            },
                          ),

                        // Past Announcements (Read)
                        if (readList.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(
                                16.0, 8.0, 16.0, 24.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                listTileTheme: ListTileThemeData(
                                  dense: true,
                                  minVerticalPadding: 0,
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Container(
                                  color: const Color(
                                      0xFFF1F4F8), // Light grey background
                                  child: ExpansionTile(
                                    title: Text(
                                      'Past messages',
                                      style: AppTheme.of(context)
                                          .bodyMedium
                                          .override(
                                            font: GoogleFonts.lexendDeca(),
                                            color:
                                                AppTheme.of(context).secondary,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    backgroundColor: const Color(0xFFF1F4F8),
                                    collapsedBackgroundColor:
                                        const Color(0xFFF1F4F8),
                                    iconColor: AppTheme.of(context).primary,
                                    collapsedIconColor:
                                        AppTheme.of(context).secondary,
                                    children: [
                                      ListView.builder(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: readList.length,
                                        itemBuilder: (context, index) {
                                          return _buildAnnouncementCard(context,
                                              viewModel, readList[index], true);
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
        // Show FAB only for moderators or admins
        if (!viewAsBlocksWrite() &&
            (viewModel.groupManagerIds.contains(viewModel.currentUserId) ||
                context.read<FFAppState>().loginUser.roles.hasAdmin))
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
                    'groupMembers': viewModel.members,
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
                context.l10n.newMessage,
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

  int _newestPinFirst(
    CcViewNotificationsUsersRow a,
    CcViewNotificationsUsersRow b,
  ) {
    final aDate = a.pinnedAt ?? a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    final bDate = b.pinnedAt ?? b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
    return bDate.compareTo(aDate);
  }

  String _messageTime(
    BuildContext context,
    CcViewNotificationsUsersRow notification,
  ) {
    final date = notification.createdAt ?? notification.updatedAt;
    if (date == null) return '';
    return dateTimeFormat(
      'MMM d, HH:mm',
      date,
      locale: Localizations.localeOf(context).toString(),
    );
  }

  Widget _buildPrivateBadge(
    BuildContext context,
    GroupDetailsViewModel viewModel,
    CcViewNotificationsUsersRow notification,
  ) {
    final isRecipient = notification.recipientUserId == viewModel.currentUserId;
    final isSender = notification.userId == viewModel.currentUserId;

    String label;
    if (isSender && !isRecipient) {
      final recipient = viewModel.members.firstWhere(
        (m) => m.authUserId == notification.recipientUserId,
        orElse: () => CcMembersRow({}),
      );
      final name =
          recipient.displayName ?? recipient.firstName ?? context.l10n.member;
      label = 'Private → $name';
    } else {
      label = 'Private message';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.lock_outline,
            size: 12.0, color: AppTheme.of(context).primary),
        const SizedBox(width: 4.0),
        Text(
          label,
          style: AppTheme.of(context).labelSmall.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).primary,
                fontSize: 11.0,
                fontWeight: FontWeight.w600,
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
            final readAt = await viewModel.announcementReadAt(notification.id!);
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
                'experienceRow': notification,
                'commentsReadAt': readAt,
                'highlightNewComments': true,
              },
            );

            if (!context.mounted) return;
            // Replies that arrived after this open stay unread until the next open.
            await viewModel.refreshReadNotifications();
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 530.0),
            decoration: BoxDecoration(
              color: isRead
                  ? AppTheme.of(context).primaryBackground
                  : AppTheme.of(context)
                      .primaryBackground
                      .withValues(alpha: 0.95),
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
                color: notification.isPinned
                    ? AppTheme.of(context).primary.withValues(alpha: 0.45)
                    : AppTheme.of(context).primaryBackground,
                width: notification.isPinned ? 1.5 : 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 4.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 12.0, 16.0, 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 12.0, 0.0),
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
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: isRead
                                        ? FontWeight.normal
                                        : FontWeight.w600,
                                  ),
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 16.0,
                                ),
                          ),
                        ),
                        if (notification.isPinned)
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Tooltip(
                              message: context.l10n.pinnedMessage,
                              child: Icon(
                                Icons.push_pin,
                                size: 18.0,
                                color: AppTheme.of(context).primary,
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
                  if (notification.recipientUserId != null)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 6.0),
                      child:
                          _buildPrivateBadge(context, viewModel, notification),
                    ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 12.0),
                    child: Text(
                      '${_messageTime(context, notification)} - From ${notification.displayName ?? context.l10n.userFallback} - ${context.l10n.facilitator}',
                      style: AppTheme.of(context).labelSmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                  if (notification.id != null &&
                      (viewModel.replyCountFor(notification.id!) > 0 ||
                          viewModel.commentCountFor(notification.id!) > 0))
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          16.0, 0.0, 16.0, 12.0),
                      child: _buildReplyLabel(context, viewModel, notification.id!),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReplyLabel(
    BuildContext context,
    GroupDetailsViewModel viewModel,
    int messageId,
  ) {
    final unseen = viewModel.replyCountFor(messageId);
    final hasUnseen = unseen > 0;
    final color = hasUnseen
        ? AppTheme.of(context).primary
        : AppTheme.of(context).secondary;
    return Row(
      children: [
        Icon(Icons.chat_bubble_outline, size: 14.0, color: color),
        const SizedBox(width: 6.0),
        Text(
          hasUnseen
              ? context.l10n.newReplies(unseen)
              : context.l10n.commentCount(viewModel.commentCountFor(messageId)),
          style: AppTheme.of(context).labelSmall.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: hasUnseen ? FontWeight.w600 : FontWeight.w500,
                ),
                color: color,
                fontSize: 13.0,
              ),
        ),
      ],
    );
  }
}

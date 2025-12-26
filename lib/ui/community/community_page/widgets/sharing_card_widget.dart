import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/sharing_edit_page/sharing_edit_page.dart';
import 'package:gw_community/ui/community/sharing_view_page/sharing_view_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class SharingCardWidget extends StatelessWidget {
  const SharingCardWidget({
    super.key,
    required this.sharingRow,
    required this.index,
    required this.totalCount,
    this.onDelete,
  });

  final CcViewSharingsUsersRow sharingRow;
  final int index;
  final int totalCount;
  final Future<void> Function(BuildContext context)? onDelete;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
        child: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.pushNamed(
              SharingViewPage.routeName,
              queryParameters: {
                'sharingId': serializeParam(
                  sharingRow.id,
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
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(
              maxWidth: 530.0,
            ),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
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
                color: AppTheme.of(context).primaryBackground,
                width: 1.0,
              ),
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  _buildModerationStatus(context),
                  _buildText(context),
                  _buildActions(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 12.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          UserAvatar(
            key: Key('Keys09_${index}_of_$totalCount'),
            imageUrl: sharingRow.photoUrl,
            fullName: sharingRow.fullName,
            size: 36.0,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    valueOrDefault<String>(
                      sharingRow.displayName,
                      'User name',
                    ),
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: AppTheme.of(context).secondary,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  _buildVisibilityLabel(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVisibilityLabel(BuildContext context) {
    final visibility = sharingRow.visibility;
    final groupName = sharingRow.groupName;

    // visibility == 'everyone' means visible to everyone - don't show label
    // Any other value (including 'group', null, 'visible', etc.) means visible only for the group
    final isEveryone = visibility == 'everyone';

    // Only show label if it's group-only visibility
    if (!isEveryone && groupName != null && groupName.isNotEmpty) {
      return RichText(
        textScaler: MediaQuery.of(context).textScaler,
        text: TextSpan(
          children: [
            TextSpan(
              text: 'Visible only for ',
              style: TextStyle(
                color: AppTheme.of(context).primary,
                fontSize: 12.0,
              ),
            ),
            TextSpan(
              text: groupName,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(
                      fontWeight: FontWeight.bold,
                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                    ),
                    color: AppTheme.of(context).primary,
                    fontSize: 12.0,
                    letterSpacing: 0.0,
                    fontWeight: FontWeight.bold,
                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                  ),
            ),
          ],
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
                color: AppTheme.of(context).primary,
                fontSize: 12.0,
                letterSpacing: 0.0,
                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
      );
    }

    // Don't show anything for "everyone" visibility
    return const SizedBox.shrink();
  }

  Widget _buildModerationStatus(BuildContext context) {
    final isOwner = context.currentUserIdOrEmpty == sharingRow.userId;
    final status = sharingRow.moderationStatus;

    // Only show for owner and when status exists and is not approved
    if (!isOwner || status == null || status == 'approved') {
      return const SizedBox.shrink();
    }

    Color backgroundColor;
    Color textColor;
    IconData icon;
    String label;

    switch (status) {
      case 'draft':
        backgroundColor = const Color(0xFFE3F2FD);
        textColor = const Color(0xFF1976D2);
        icon = Icons.edit_note;
        label = 'Draft';
        break;
      case 'pending':
        backgroundColor = AppTheme.of(context).warning.withValues(alpha: 0.15);
        textColor = const Color(0xFFB8860B);
        icon = Icons.hourglass_empty;
        label = 'Pending Review';
        break;
      case 'rejected':
        backgroundColor = AppTheme.of(context).error.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).error;
        icon = Icons.cancel_outlined;
        label = 'Rejected';
        break;
      case 'changes_requested':
        backgroundColor = AppTheme.of(context).copperRed.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).copperRed;
        icon = Icons.edit_note;
        label = 'Changes Requested';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lexendDeca(
                fontSize: 12.0,
                fontWeight: FontWeight.w500,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final text = sharingRow.text?.trim() ?? '';

    // If text is empty, don't show anything
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
      child: Text(
        text,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.of(context).bodyMedium.override(
              font: GoogleFonts.inter(),
              color: AppTheme.of(context).secondary,
              fontSize: 14.0,
              letterSpacing: 0.0,
            ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final isAdmin = FFAppState().loginUser.roles.contains('Admin') == true;
    final isOwner = context.currentUserIdOrEmpty == sharingRow.userId;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if ((isAdmin || isOwner) && onDelete != null)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  await onDelete!(context);
                },
                text: 'Delete',
                options: FFButtonOptions(
                  height: 40.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  iconPadding: const EdgeInsets.all(0.0),
                  color: AppTheme.of(context).primaryBackground,
                  textStyle: AppTheme.of(context).labelLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                          fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).secondary,
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                  elevation: 0.0,
                  borderSide: BorderSide(
                    color: AppTheme.of(context).secondaryBackground,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          if (isOwner)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  context.pushNamed(
                    SharingEditPage.routeName,
                    extra: <String, dynamic>{
                      'sharingRow': sharingRow,
                      kTransitionInfoKey: const TransitionInfo(
                        hasTransition: true,
                        transitionType: PageTransitionType.fade,
                        duration: Duration(milliseconds: 0),
                      ),
                    },
                  );
                },
                text: 'Edit',
                options: FFButtonOptions(
                  height: 40.0,
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                  color: AppTheme.of(context).primary,
                  textStyle: AppTheme.of(context).labelLarge.override(
                        font: GoogleFonts.poppins(
                          fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                          fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                        ),
                        color: AppTheme.of(context).primaryBackground,
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                      ),
                  elevation: 1.0,
                  borderSide: BorderSide(
                    color: AppTheme.of(context).secondaryBackground,
                    width: 0.5,
                  ),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

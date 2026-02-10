import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/experience_edit_page/experience_edit_page.dart';
import 'package:gw_community/ui/community/experience_view_page/experience_view_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/widgets/confirmation_dialog.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class ExperienceCardWidget extends StatelessWidget {
  const ExperienceCardWidget({
    super.key,
    required this.experienceRow,
    required this.index,
    required this.totalCount,
    this.onDelete,
  });

  final CcViewSharingsUsersRow experienceRow;
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
              ExperienceViewPage.routeName,
              queryParameters: {'experienceId': serializeParam(experienceRow.id, ParamType.int)}.withoutNulls,
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
            constraints: const BoxConstraints(maxWidth: 530.0),
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
              boxShadow: const [
                BoxShadow(blurRadius: 15.0, color: Color(0x1A000000), offset: Offset(0.0, 7.0), spreadRadius: 3.0),
              ],
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppTheme.of(context).primaryBackground, width: 1.0),
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
            imageUrl: experienceRow.photoUrl,
            fullName: experienceRow.fullName,
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
                    valueOrDefault<String>(experienceRow.displayName, 'User name'),
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModerationStatus(BuildContext context) {
    final isOwner = context.currentUserIdOrEmpty == experienceRow.userId;
    final status = experienceRow.moderationStatus;

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
        label = 'In Reflection';
        break;
      case 'awaiting_approval':
      case 'pending':
        backgroundColor = AppTheme.of(context).warning.withValues(alpha: 0.15);
        textColor = const Color(0xFFB8860B);
        icon = Icons.hourglass_empty;
        label = 'Awaiting Approval';
        break;
      case 'rejected':
        backgroundColor = AppTheme.of(context).error.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).error;
        icon = Icons.cancel_outlined;
        label = 'Not Published';
        break;
      case 'changes_requested':
        backgroundColor = AppTheme.of(context).copperRed.withValues(alpha: 0.15);
        textColor = AppTheme.of(context).copperRed;
        icon = Icons.edit_note;
        label = 'Refinement Suggested';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        decoration: BoxDecoration(color: backgroundColor, borderRadius: BorderRadius.circular(8.0)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: textColor),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.lexendDeca(fontSize: 12.0, fontWeight: FontWeight.w500, color: textColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildText(BuildContext context) {
    final text = experienceRow.text?.trim() ?? '';

    // If text is empty, don't show anything
    if (text.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
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
        ),
        if (experienceRow.moderationStatus == 'rejected' || experienceRow.moderationStatus == 'changes_requested')
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (experienceRow.moderationReason != null && experienceRow.moderationReason!.trim().isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      experienceRow.moderationReason!,
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.italic,
                          ),
                    ),
                  ),
                Text(
                  experienceRow.moderationStatus == 'rejected'
                      ? 'You’re welcome to revise and share again whenever you feel ready.'
                      : 'Suggestions were shared to help refine this experience.',
                  style: AppTheme.of(context).bodySmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: AppTheme.of(context).secondary,
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.italic,
                      ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final isAdmin = FFAppState().loginUser.roles.hasAdmin;
    final isOwner = context.currentUserIdOrEmpty == experienceRow.userId;

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
                  final confirmed = await ConfirmationDialog.show(
                    context: context,
                    title: 'Withdraw this experience?',
                    message: 'It will be permanently removed from the group and cannot be restored.',
                    confirmLabel: 'Delete',
                    confirmColor: AppTheme.of(context).secondary,
                  );

                  if (confirmed && onDelete != null) {
                    await onDelete!(context);
                  }
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
                  borderSide: BorderSide(color: AppTheme.of(context).secondaryBackground, width: 0.5),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          if (isOwner &&
              experienceRow.moderationStatus != 'awaiting_approval' &&
              experienceRow.moderationStatus != 'pending')
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
              child: FFButtonWidget(
                onPressed: () async {
                  context.pushNamed(
                    ExperienceEditPage.routeName,
                    extra: <String, dynamic>{
                      'experienceRow': experienceRow,
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
                  borderSide: BorderSide(color: AppTheme.of(context).secondaryBackground, width: 0.5),
                  borderRadius: BorderRadius.circular(20.0),
                  disabledColor: AppTheme.of(context).alternate,
                  disabledTextColor: AppTheme.of(context).secondaryText,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

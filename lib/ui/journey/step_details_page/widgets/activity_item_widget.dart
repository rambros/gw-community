import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/ui/core/themes/app_theme.dart';
import '/data/services/supabase/supabase.dart';

class ActivityItemWidget extends StatelessWidget {
  const ActivityItemWidget({
    super.key,
    required this.activity,
    required this.onTap,
  });

  final CcViewUserActivitiesRow activity;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Status indicator
            _buildStatusIndicator(context),
            // Content - flexible height based on text
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activity.activityLabel ?? 'activity',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: activity.activityStatus == 'open'
                              ? AppTheme.of(context).primaryText
                              : AppTheme.of(context).alternate,
                          fontSize: 16.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    activity.activityPrompt ?? 'prompt',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w300,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: activity.activityStatus == 'open'
                              ? AppTheme.of(context).primaryText
                              : AppTheme.of(context).alternate,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w300,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ],
              ),
            ),
            // Icon
            _buildActivityTypeIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    final isCompleted = activity.activityStatus == 'completed';

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
      child: Container(
        width: 28.0,
        height: 28.0,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: isCompleted
                ? AppTheme.of(context).alternate
                : AppTheme.of(context).primaryBackground,
            width: 2.0,
          ),
        ),
        child: isCompleted
            ? Icon(
                Icons.check,
                color: AppTheme.of(context).alternate,
                size: 18.0,
              )
            : null,
      ),
    );
  }

  Widget _buildActivityTypeIcon(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(12.0, 0.0, 0.0, 0.0),
      child: _getActivityIcon(context),
    );
  }

  Widget _getActivityIcon(BuildContext context) {
    final iconColor = activity.activityStatus == 'open'
        ? AppTheme.of(context).primaryBackground
        : AppTheme.of(context).alternate;

    if (activity.activityType == 'audio') {
      return Icon(
        Icons.play_circle_outlined,
        color: iconColor,
        size: 36.0,
      );
    } else if (activity.activityType == 'text') {
      return Icon(
        Icons.text_snippet_outlined,
        color: iconColor,
        size: 36.0,
      );
    } else {
      return FaIcon(
        FontAwesomeIcons.solidPenToSquare,
        color: iconColor,
        size: 32.0,
      );
    }
  }
}

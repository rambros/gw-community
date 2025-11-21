import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/backend/supabase/supabase.dart';

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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onTap,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusIndicator(context),
            Expanded(
              child: Container(
                width: 100.0,
                decoration: BoxDecoration(
                  color: FlutterFlowTheme.of(context).secondary,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activity.activityLabel ?? 'activity',
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                            ),
                            color: activity.activityStatus == 'open'
                                ? FlutterFlowTheme.of(context).primaryText
                                : FlutterFlowTheme.of(context).alternate,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                    ),
                    const SizedBox(height: 2.0),
                    AutoSizeText(
                      activity.activityPrompt ?? 'prompt',
                      minFontSize: 13.0,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(
                              fontWeight: FontWeight.w300,
                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                            ),
                            color: activity.activityStatus == 'open'
                                ? FlutterFlowTheme.of(context).primaryText
                                : FlutterFlowTheme.of(context).alternate,
                            fontSize: 14.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.w300,
                            fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                          ),
                      overflow: TextOverflow.visible,
                    ),
                  ],
                ),
              ),
            ),
            _buildActivityTypeIcon(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                if (activity.activityStatus == 'open')
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: FaIcon(
                        FontAwesomeIcons.circle,
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        size: 24.0,
                      ),
                    ),
                  ),
                if (activity.activityStatus == 'completed')
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Container(
                      width: 28.0,
                      height: 28.0,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_outlined,
                        color: FlutterFlowTheme.of(context).alternate,
                        size: 28.0,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityTypeIcon(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(1.0, 0.0),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Align(
            alignment: const AlignmentDirectional(1.0, 0.0),
            child: Container(
              width: 60.0,
              height: 60.0,
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondary,
              ),
              child: _getActivityIcon(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _getActivityIcon(BuildContext context) {
    final iconColor = activity.activityStatus == 'open'
        ? FlutterFlowTheme.of(context).primaryBackground
        : FlutterFlowTheme.of(context).alternate;

    if (activity.activityType == 'audio') {
      return Align(
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Icon(
          Icons.play_circle_outlined,
          color: iconColor,
          size: 36.0,
        ),
      );
    } else if (activity.activityType == 'text') {
      return Align(
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: Icon(
          Icons.text_snippet_outlined,
          color: iconColor,
          size: 36.0,
        ),
      );
    } else {
      return Align(
        alignment: const AlignmentDirectional(0.0, 0.0),
        child: FaIcon(
          FontAwesomeIcons.solidEdit,
          color: iconColor,
          size: 32.0,
        ),
      );
    }
  }
}

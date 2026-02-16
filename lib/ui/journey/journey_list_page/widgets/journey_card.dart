import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';

class JourneyCard extends StatelessWidget {
  const JourneyCard({
    super.key,
    required this.journeyRow,
    required this.isStarted,
    this.stepsCompleted,
    this.journeyStatus,
    this.onTap,
  });

  // Accepts either CcJourneysRow or CcViewUserJourneysRow
  // Both have the required fields: title, stepsTotal, isPublic, imageUrl
  final dynamic journeyRow;
  final bool isStarted;
  final int? stepsCompleted;
  final String? journeyStatus;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: 140.0,
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
            color: const Color(0xFFF5FBFB),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Journey Title - Full Width
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 4.0),
              child: Text(
                journeyRow.title ?? 'Untitled Journey',
                style: AppTheme.of(context).titleMedium.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 18.0,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // Bottom Info and Logo
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 12.0, 12.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.end,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Steps progress
                          Text(
                            isStarted
                                ? (journeyStatus == 'completed'
                                    ? 'Completed ${journeyRow.stepsTotal ?? 0} of ${journeyRow.stepsTotal ?? 0} steps'
                                    : 'Completed ${stepsCompleted ?? 0} of ${journeyRow.stepsTotal ?? 0} steps')
                                : '${journeyRow.stepsTotal ?? 0} steps',
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 12.0,
                                ),
                          ),
                          // Privacy tag
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color:
                                    journeyRow.isPublic ? AppTheme.of(context).accent4 : AppTheme.of(context).accent3,
                                borderRadius: BorderRadius.circular(16.0),
                              ),
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                                child: Text(
                                  journeyRow.isPublic ? 'public' : 'private',
                                  style: AppTheme.of(context).bodyMedium.override(
                                        color: AppTheme.of(context).secondary,
                                        fontSize: 10.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ),
                            ),
                          ),
                          // Action button
                          Builder(
                            builder: (context) {
                              String buttonText = 'START';
                              Color buttonColor = AppTheme.of(context).secondary;
                              if (isStarted) {
                                bool isCompleted = journeyStatus == 'completed' ||
                                    (stepsCompleted != null &&
                                        journeyRow.stepsTotal != null &&
                                        stepsCompleted! >= journeyRow.stepsTotal!);

                                if (isCompleted) {
                                  buttonText = 'COMPLETED';
                                  buttonColor = AppTheme.of(context).tertiary;
                                } else {
                                  buttonText = 'RESUME';
                                  buttonColor = AppTheme.of(context).primary;
                                }
                              }

                              return FFButtonWidget(
                                onPressed: onTap,
                                text: buttonText,
                                options: FFButtonOptions(
                                  width: 110.0,
                                  height: 32.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                  color: buttonColor,
                                  textStyle: AppTheme.of(context).titleSmall.override(
                                        fontWeight: FontWeight.bold,
                                        color:
                                            (buttonText == 'COMPLETED') ? AppTheme.of(context).secondary : Colors.white,
                                        fontSize: 12.0,
                                      ),
                                  elevation: 2.0,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    // Journey Image/Logo - Aligned to bottom right
                    _buildLogo(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 0.0, 0.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: journeyRow.imageUrl != null && journeyRow.imageUrl!.isNotEmpty
            ? CachedNetworkImage(
                fadeInDuration: const Duration(milliseconds: 500),
                fadeOutDuration: const Duration(milliseconds: 500),
                imageUrl: journeyRow.imageUrl!,
                width: 74.0,
                height: 74.0,
                fit: BoxFit.cover,
                errorWidget: (context, url, error) => _buildDefaultIcon(context),
              )
            : _buildDefaultIcon(context),
      ),
    );
  }

  Widget _buildDefaultIcon(BuildContext context) {
    return Image.asset(
      'assets/images/logo_goodwishes_300.png',
      width: 74.0,
      height: 74.0,
      fit: BoxFit.scaleDown,
    );
  }
}

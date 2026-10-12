import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class HomeJourneyCard extends StatelessWidget {
  const HomeJourneyCard({
    super.key,
    required this.userJourneyProgress,
  });

  final CcViewUserJourneysRow userJourneyProgress;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.transparent,
      focusColor: Colors.transparent,
      hoverColor: Colors.transparent,
      highlightColor: Colors.transparent,
      borderRadius: BorderRadius.circular(12.0),
      onTap: () => _openJourney(context),
      child: _buildResumeCard(context),
    );
  }

  void _openJourney(BuildContext context) {
    context.pushNamed(
      JourneyPage.routeName,
      queryParameters: {
        'journeyId': serializeParam(
          userJourneyProgress.journeyId,
          ParamType.int,
        ),
      }.withoutNulls,
    );
  }

  Widget _buildResumeCard(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 118.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 15.0,
            color: Color(0x26000000),
            offset: Offset(0.0, 7.0),
            spreadRadius: 3.0,
          )
        ],
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: const Color(0xFFF5FBFB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 4.0, 8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 4.0, 0.0, 3.0),
                    child: Text(
                      valueOrDefault<String>(
                        userJourneyProgress.title,
                        'title',
                      ),
                      softWrap: true,
                      style: AppTheme.of(context).titleMedium.override(
                            color: AppTheme.of(context).secondary,
                            fontSize: 18.0,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 12.0),
                    child: Text(
                      context.l10n.stepsProgress(
                        userJourneyProgress.stepsCompleted ?? 0,
                        userJourneyProgress.stepsTotal ?? 0,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).bodySmall.override(
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                          ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(
                        0.0, 0.0, 0.0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 0.0, 8.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () => _openJourney(context),
                            text: context.l10n.resumeUpper,
                            options: FFButtonOptions(
                              height: 36.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  16.0, 0.0, 16.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(
                                  0.0, 0.0, 0.0, 0.0),
                              color: AppTheme.of(context).primary,
                              textStyle: AppTheme.of(context)
                                  .labelLarge
                                  .override(
                                    color:
                                        AppTheme.of(context).primaryBackground,
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
                  ),
                ],
              ),
            ),
          ),
          _buildLogo(),
        ],
      ),
    );
  }

  Widget _buildLogo() {
    final imageUrl = userJourneyProgress.imageUrl;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? CachedNetworkImage(
                    fadeInDuration: const Duration(milliseconds: 500),
                    fadeOutDuration: const Duration(milliseconds: 500),
                    imageUrl: imageUrl,
                    width: 74.0,
                    height: 74.0,
                    fit: BoxFit.cover,
                    errorWidget: (context, url, error) => _buildDefaultIcon(),
                  )
                : _buildDefaultIcon(),
          ),
        ),
      ],
    );
  }

  Widget _buildDefaultIcon() {
    return Image.asset(
      'assets/images/logo_goodwishes_300.png',
      width: 74.0,
      height: 74.0,
      fit: BoxFit.scaleDown,
    );
  }
}

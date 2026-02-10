import 'package:flutter/material.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
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
    return _buildResumeCard(context);
  }

  Widget _buildResumeCard(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width * 0.9,
      height: 110.0,
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
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 1.0, 1.0, 0.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            userJourneyProgress.title,
                            'title',
                          ),
                          style: AppTheme.of(context).titleMedium.override(
                                color: AppTheme.of(context).secondary,
                                fontSize: 18.0,
                              ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                        child: Text(
                          'Completed ${userJourneyProgress.stepsCompleted?.toString()} of ${userJourneyProgress.stepsTotal?.toString()} steps',
                          style: AppTheme.of(context).bodySmall.override(
                                color: AppTheme.of(context).secondary,
                                fontSize: 12.0,
                              ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                          child: FFButtonWidget(
                            onPressed: () async {
                              context.pushNamed(
                                JourneyPage.routeName,
                                queryParameters: {
                                  'journeyId': serializeParam(
                                    userJourneyProgress.journeyId,
                                    ParamType.int,
                                  ),
                                }.withoutNulls,
                              );
                            },
                            text: 'RESUME',
                            options: FFButtonOptions(
                              width: 100.0,
                              height: 32.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: AppTheme.of(context).primary,
                              textStyle: AppTheme.of(context).labelLarge.override(
                                    color: AppTheme.of(context).primaryBackground,
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
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              'assets/images/logo_goodwishes_300.png',
              width: 74.0,
              height: 74.0,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
      ],
    );
  }
}

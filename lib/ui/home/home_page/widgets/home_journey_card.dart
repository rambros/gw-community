import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/utils/flutter_flow_util.dart';
import '/data/services/supabase/supabase.dart';
import '/index.dart';

class HomeJourneyCard extends StatelessWidget {
  const HomeJourneyCard({
    super.key,
    this.journeyDetails,
    this.userJourneyProgress,
    required this.hasStartedJourney,
  });

  final CcJourneysRow? journeyDetails;
  final CcViewUserJourneysRow? userJourneyProgress;
  final bool hasStartedJourney;

  @override
  Widget build(BuildContext context) {
    if (!hasStartedJourney) {
      return _buildStartCard(context);
    } else {
      return _buildResumeCard(context);
    }
  }

  Widget _buildStartCard(BuildContext context) {
    if (journeyDetails == null) return const SizedBox.shrink();

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
                            journeyDetails?.title,
                            'Journey',
                          ),
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w500,
                                ),
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
                          'Completed 0 of ${journeyDetails?.stepsTotal?.toString()} steps',
                          style: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).secondary,
                            fontWeight: FontWeight.normal,
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
                        FFButtonWidget(
                          onPressed: () async {
                            context.pushNamed(JourneysListPage.routeName);
                          },
                          text: 'START',
                          options: FFButtonOptions(
                            width: 90.0,
                            height: 32.0,
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                            color: AppTheme.of(context).secondary,
                            textStyle: AppTheme.of(context).titleSmall.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  color: Colors.white,
                                  fontSize: 12.0,
                                ),
                            borderSide: const BorderSide(
                              color: Colors.transparent,
                              width: 1.0,
                            ),
                            borderRadius: BorderRadius.circular(8.0),
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

  Widget _buildResumeCard(BuildContext context) {
    if (userJourneyProgress == null) return const SizedBox.shrink();

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
                            userJourneyProgress?.title,
                            'title',
                          ),
                          style: AppTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w500,
                                ),
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
                          'Completed ${userJourneyProgress?.stepsCompleted?.toString()} of ${userJourneyProgress?.stepsTotal?.toString()} steps',
                          style: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).secondary,
                            fontWeight: FontWeight.normal,
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
                                    userJourneyProgress?.journeyId,
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
                                    font: GoogleFonts.poppins(),
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

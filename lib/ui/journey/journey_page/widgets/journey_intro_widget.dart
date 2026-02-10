import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneyIntroWidget extends StatefulWidget {
  const JourneyIntroWidget({
    super.key,
    required this.journey,
    required this.journeySteps,
    required this.onStart,
    this.isJourneyStarted = false,
  });

  final CcJourneysRow journey;
  final List<CcJourneyStepsRow> journeySteps;
  final VoidCallback onStart;
  final bool isJourneyStarted;

  @override
  State<JourneyIntroWidget> createState() => _JourneyIntroWidgetState();
}

class _JourneyIntroWidgetState extends State<JourneyIntroWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      scrollDirection: Axis.vertical,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 12.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.journey.title ?? 'Journey Title',
                style: AppTheme.of(context).journey.sectionTitle.override(
                      color: AppTheme.of(context).tertiary,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: MarkdownBody(
            data: widget.journey.description ?? 'Description',
            onTapLink: (text, href, title) {
              if (href != null) {
                launchURL(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              strong: GoogleFonts.lexendDeca(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              em: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              h1: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
              h2: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
              h3: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).tertiary,
                fontSize: 18.0,
                fontWeight: FontWeight.w600,
              ),
              a: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primary,
                fontSize: 14.0,
                decoration: TextDecoration.underline,
              ),
              listBullet: GoogleFonts.lexendDeca(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14.0,
              ),
            ),
          ),
        ),
        // Steps Section
        if (widget.journeySteps.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 24.0, 16.0, 16.0),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        'Steps',
                        style: AppTheme.of(context).journey.bodyText.override(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16.0,
                            ),
                      ),
                    ],
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: EdgeInsets.zero,
                  itemCount: widget.journeySteps.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16.0),
                  itemBuilder: (context, index) {
                    final step = widget.journeySteps[index];
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28.0,
                          height: 28.0,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${step.stepNumber}',
                              style: AppTheme.of(context).bodySmall.override(
                                    color: AppTheme.of(context).secondary,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.0,
                                  ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title ?? 'Step ${step.stepNumber}',
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15.0,
                                    ),
                              ),
                              if (step.description != null && step.description!.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 0.0),
                                  child: Text(
                                    step.description!,
                                    style: AppTheme.of(context).bodySmall.override(
                                          color: Colors.white.withValues(alpha: 0.7),
                                          fontSize: 14.0,
                                        ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        // Start Button - placed after Steps section
        Padding(
          padding: const EdgeInsets.all(32.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: widget.onStart,
                    text: widget.isJourneyStarted ? 'Resume' : 'Start',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).journey.buttonText.override(
                            color: AppTheme.of(context).primaryBackground,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).secondary,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

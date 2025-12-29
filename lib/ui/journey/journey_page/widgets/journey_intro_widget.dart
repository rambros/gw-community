import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneyIntroWidget extends StatelessWidget {
  const JourneyIntroWidget({
    super.key,
    required this.journey,
    required this.onStart,
  });

  final CcJourneysRow journey;
  final VoidCallback onStart;

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
                journey.title ?? 'Journey Title',
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
            data: journey.description ?? 'Description',
            onTapLink: (text, href, title) {
              if (href != null) {
                launchURL(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primaryText,
                fontSize: 14.0,
                fontWeight: FontWeight.w300,
                height: 1.5,
              ),
              strong: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primaryText,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              em: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primaryText,
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
                color: AppTheme.of(context).primaryText,
                fontSize: 14.0,
              ),
            ),
          ),
        ),
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
                    onPressed: onStart,
                    text: 'Start',
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

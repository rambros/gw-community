import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';

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
          child: Html(
            data: journey.description ?? '<p>Description</p>',
            style: {
              "body": Style(
                margin: Margins.zero,
                padding: HtmlPaddings.zero,
                fontSize: FontSize(14.0),
                fontFamily: GoogleFonts.lexendDeca().fontFamily,
                fontWeight: FontWeight.w300,
                color: AppTheme.of(context).primaryText,
              ),
              "p": Style(
                margin: Margins.only(bottom: 8.0),
              ),
              "h1, h2, h3, h4, h5, h6": Style(
                margin: Margins.only(bottom: 8.0, top: 8.0),
                fontWeight: FontWeight.bold,
              ),
              "ul, ol": Style(
                margin: Margins.only(left: 16.0, bottom: 8.0),
              ),
              "a": Style(
                color: AppTheme.of(context).primary,
                textDecoration: TextDecoration.underline,
              ),
            },
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

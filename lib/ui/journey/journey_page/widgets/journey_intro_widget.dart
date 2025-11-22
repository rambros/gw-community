import 'package:flutter/material.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/data/services/supabase/supabase.dart';
import 'package:google_fonts/google_fonts.dart';

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
                style: AppTheme.of(context).titleMedium.override(
                      font: GoogleFonts.lexendDeca(
                        fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                        fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                      ),
                      color: AppTheme.of(context).tertiary,
                      letterSpacing: 0.0,
                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                    ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              Expanded(
                child: Text(
                  journey.description ?? 'Description',
                  textAlign: TextAlign.start,
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: FontWeight.w300,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                        color: AppTheme.of(context).primaryText,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w300,
                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                      ),
                ),
              ),
            ],
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

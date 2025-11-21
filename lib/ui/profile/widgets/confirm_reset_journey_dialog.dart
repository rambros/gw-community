import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';

class ConfirmResetJourneyDialog extends StatelessWidget {
  const ConfirmResetJourneyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Container(
        width: double.infinity,
        height: 320.0,
        constraints: const BoxConstraints(
          maxWidth: double.infinity,
          maxHeight: 400.0,
        ),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).alternate,
          borderRadius: BorderRadius.circular(0.0),
          border: Border.all(
            color: FlutterFlowTheme.of(context).secondary,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                      child: Text(
                        'Reset your Good Wishes Journey',
                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                              ),
                              fontSize: 20.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                            ),
                      ),
                    ),
                  ),
                  FlutterFlowIconButton(
                    borderColor: FlutterFlowTheme.of(context).secondary,
                    borderRadius: 30.0,
                    borderWidth: 2.0,
                    buttonSize: 44.0,
                    icon: Icon(
                      Icons.close_rounded,
                      color: FlutterFlowTheme.of(context).secondary,
                      size: 24.0,
                    ),
                    onPressed: () async {
                      Navigator.pop(context, false);
                    },
                  ),
                ],
              ),
              Divider(
                height: 24.0,
                thickness: 2.0,
                color: FlutterFlowTheme.of(context).secondary,
              ),
              Text(
                'Reset the journey will delete the progress that you made so far...',
                style: FlutterFlowTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(
                        fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                        fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                      ),
                      color: FlutterFlowTheme.of(context).secondary,
                      letterSpacing: 0.0,
                      fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                      fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                    ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 42.0, 0.0, 0.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context, false);
                        },
                        text: 'Cancel',
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsets.all(0.0),
                          color: FlutterFlowTheme.of(context).primaryBackground,
                          textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).secondary,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                              ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context, true);
                        },
                        text: 'Reset Journey',
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).primary,
                          textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                font: GoogleFonts.poppins(
                                  fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                ),
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                letterSpacing: 0.0,
                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                              ),
                          elevation: 1.0,
                          borderSide: BorderSide(
                            color: FlutterFlowTheme.of(context).secondaryBackground,
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
    );
  }
}

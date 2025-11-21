import 'package:flutter/material.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:google_fonts/google_fonts.dart';

class JourneyCardWidget extends StatelessWidget {
  const JourneyCardWidget({
    super.key,
    required this.title,
    required this.stepsCompleted,
    required this.stepsTotal,
    required this.onTap,
    required this.buttonText,
  });

  final String title;
  final int stepsCompleted;
  final int stepsTotal;
  final VoidCallback onTap;
  final String buttonText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: 110.0,
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primaryBackground,
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
                            title,
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  fontSize: 18.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
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
                            'Completed $stepsCompleted of $stepsTotal steps',
                            style: GoogleFonts.lexendDeca(
                              color: FlutterFlowTheme.of(context).secondary,
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
                            onPressed: onTap,
                            text: buttonText,
                            options: FFButtonOptions(
                              width: 90.0,
                              height: 32.0,
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                              color: FlutterFlowTheme.of(context).secondary,
                              textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                    ),
                                    color: Colors.white,
                                    fontSize: 12.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
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
            Column(
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
            ),
          ],
        ),
      ),
    );
  }
}

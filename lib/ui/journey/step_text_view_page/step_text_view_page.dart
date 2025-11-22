import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';

class StepTextViewPage extends StatelessWidget {
  const StepTextViewPage({
    super.key,
    this.stepTextTitle,
    this.stepTextContent,
  });

  final String? stepTextTitle;
  final String? stepTextContent;

  static String routeName = 'stepTextViewPage';
  static String routePath = '/stepTextViewPage';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: false,
          leading: FlutterFlowIconButton(
            borderColor: Colors.transparent,
            borderRadius: 30.0,
            borderWidth: 1.0,
            buttonSize: 60.0,
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: Colors.white,
              size: 30.0,
            ),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            'Daily Practice',
            style: AppTheme.of(context).titleLarge.override(
                  font: GoogleFonts.poppins(
                    fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                    fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                  ),
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                  fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondary,
            ),
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            stepTextTitle ?? 'prompt',
                            textAlign: TextAlign.center,
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
                    SelectionArea(
                      child: Text(
                        stepTextContent ?? 'text',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: AppTheme.of(context).primaryText,
                              letterSpacing: 0.0,
                              fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                              fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

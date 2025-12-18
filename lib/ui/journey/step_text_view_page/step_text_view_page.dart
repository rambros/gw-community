import 'package:flutter/material.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/journey/themes/journey_theme_extension.dart';
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
            style: AppTheme.of(context).journey.pageTitle,
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
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 8.0),
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
                            style: AppTheme.of(context).journey.stepTitle.override(
                                  color: AppTheme.of(context).tertiary,
                                ),
                          ),
                        ],
                      ),
                    ),
                    SelectionArea(
                      child: Text(
                        stepTextContent ?? 'text',
                        style: AppTheme.of(context).journey.bodyText.override(
                              color: AppTheme.of(context).primaryText,
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

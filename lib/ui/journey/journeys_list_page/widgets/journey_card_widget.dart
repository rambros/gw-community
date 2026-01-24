import 'package:flutter/material.dart';

import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';

class JourneyCardWidget extends StatelessWidget {
  const JourneyCardWidget({
    super.key,
    required this.title,
    required this.stepsCompleted,
    required this.stepsTotal,
    required this.onTap,
    required this.buttonText,
    this.journeyStatus,
  });

  final String title;
  final int stepsCompleted;
  final int stepsTotal;
  final VoidCallback onTap;
  final String buttonText;
  final String? journeyStatus;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: 140.0,
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
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            title,
                            style: AppTheme.of(context).journey.stepTitle.override(
                                  color: AppTheme.of(context).secondary,
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
                            (stepsCompleted > 0)
                                ? 'Completed $stepsCompleted of $stepsTotal steps'
                                : '$stepsTotal steps',
                            style: AppTheme.of(context).journey.caption.override(
                                  color: AppTheme.of(context).secondary,
                                ),
                          ),
                        ),
                      ],
                    ),
                    // Privacy tag
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).accent4,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 2.0, 8.0, 2.0),
                              child: Text(
                                'public',
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).secondary,
                                      fontSize: 10.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
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
                          Builder(
                            builder: (context) {
                              Color buttonColor = AppTheme.of(context).secondary;
                              double buttonWidth = 90.0;
                              String textToDisplay = buttonText;

                              if (buttonText.toUpperCase() == 'RESUME') {
                                buttonColor = AppTheme.of(context).primary;
                                buttonWidth = 110.0;
                              } else if (buttonText.toUpperCase() == 'COMPLETED' || journeyStatus == 'completed') {
                                textToDisplay = 'COMPLETED';
                                buttonColor = AppTheme.of(context).tertiary;
                                buttonWidth = 110.0;
                              } else if (stepsTotal > 0 && stepsCompleted >= stepsTotal) {
                                textToDisplay = 'COMPLETED';
                                buttonColor = AppTheme.of(context).tertiary;
                                buttonWidth = 110.0;
                              }

                              return FFButtonWidget(
                                onPressed: onTap,
                                text: textToDisplay,
                                options: FFButtonOptions(
                                  width: buttonWidth,
                                  height: 32.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
                                  iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                  color: buttonColor,
                                  textStyle: AppTheme.of(context).journey.buttonText.override(
                                        color: (textToDisplay == 'COMPLETED')
                                            ? AppTheme.of(context).secondary
                                            : Colors.white,
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                  elevation: 2.0,
                                  borderSide: const BorderSide(
                                    color: Colors.transparent,
                                    width: 1.0,
                                  ),
                                  borderRadius: BorderRadius.circular(24.0),
                                ),
                              );
                            },
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

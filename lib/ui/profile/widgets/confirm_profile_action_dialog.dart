import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';

class ConfirmProfileActionDialog extends StatelessWidget {
  const ConfirmProfileActionDialog({
    super.key,
    required this.title,
    required this.description,
    required this.confirmLabel,
    this.cancelLabel = 'Cancel',
    this.icon,
    this.confirmColor,
  });

  final String title;
  final String description;
  final String confirmLabel;
  final String cancelLabel;
  final IconData? icon;
  final Color? confirmColor;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Container(
        width: double.infinity,
        height: 320.0,
        constraints: const BoxConstraints(
          maxWidth: 480.0,
          maxHeight: 400.0,
        ),
        decoration: BoxDecoration(
          color: theme.alternate,
          borderRadius: BorderRadius.circular(0.0),
          border: Border.all(
            color: theme.secondary,
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
                      child: Row(
                        children: [
                          if (icon != null)
                            Padding(
                              padding: const EdgeInsetsDirectional.only(end: 12.0),
                              child: Icon(
                                icon,
                                color: theme.secondary,
                                size: 28.0,
                              ),
                            ),
                          Expanded(
                            child: Text(
                              title,
                              style: theme.headlineMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: theme.headlineMedium.fontWeight,
                                  fontStyle: theme.headlineMedium.fontStyle,
                                ),
                                letterSpacing: 0.0,
                                fontSize: 20.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  FlutterFlowIconButton(
                    borderColor: theme.secondary,
                    borderRadius: 30.0,
                    borderWidth: 2.0,
                    buttonSize: 44.0,
                    icon: Icon(
                      Icons.close_rounded,
                      color: theme.secondary,
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
                color: theme.secondary,
              ),
              Text(
                description,
                style: theme.labelLarge.override(
                  font: GoogleFonts.poppins(
                    fontWeight: theme.labelLarge.fontWeight,
                    fontStyle: theme.labelLarge.fontStyle,
                  ),
                  color: theme.secondary,
                  letterSpacing: 0.0,
                ),
              ),
              const Spacer(),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context, false);
                        },
                        text: cancelLabel,
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsets.all(0.0),
                          color: theme.primaryBackground,
                          textStyle: theme.labelLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: theme.labelLarge.fontWeight,
                              fontStyle: theme.labelLarge.fontStyle,
                            ),
                            color: theme.secondary,
                            letterSpacing: 0.0,
                          ),
                          elevation: 0.0,
                          borderSide: BorderSide(
                            color: theme.secondaryBackground,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 0.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () async {
                          Navigator.pop(context, true);
                        },
                        text: confirmLabel,
                        options: FFButtonOptions(
                          height: 40.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: confirmColor ?? theme.primary,
                          textStyle: theme.labelLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: theme.labelLarge.fontWeight,
                              fontStyle: theme.labelLarge.fontStyle,
                            ),
                            color: theme.primaryBackground,
                            letterSpacing: 0.0,
                          ),
                          elevation: 1.0,
                          borderSide: BorderSide(
                            color: theme.secondaryBackground,
                            width: 0.5,
                          ),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      ),
    );
  }
}

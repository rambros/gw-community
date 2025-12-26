import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/ui/core/themes/app_theme.dart';

class ProfileMenuItemWidget extends StatelessWidget {
  const ProfileMenuItemWidget({
    super.key,
    required this.text,
    required this.onTap,
    this.textColor,
  });

  final String text;
  final VoidCallback onTap;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: onTap,
          child: Container(
            width: MediaQuery.sizeOf(context).width * 1.0,
            height: 50.0,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                  child: Text(
                    text,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.normal,
                            fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                          ),
                          color: textColor ?? AppTheme.of(context).secondary,
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.normal,
                          fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                        ),
                  ),
                ),
                const Expanded(
                  child: Align(
                    alignment: AlignmentDirectional(0.9, 0.0),
                    child: Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFF95A1AC),
                      size: 18.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

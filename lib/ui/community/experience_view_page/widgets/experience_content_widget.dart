import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

/// Widget que exibe o conteúdo do experience (título e texto Markdown)
class ExperienceContentWidget extends StatelessWidget {
  const ExperienceContentWidget({
    super.key,
    required this.experience,
  });

  final CcViewSharingsUsersRow experience;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
        child: Align(
          alignment: Alignment.centerLeft,
          child: MarkdownBody(
            data: experience.text ?? '',
            onTapLink: (text, href, title) {
              if (href != null) {
                launchURL(href);
              }
            },
            styleSheet: MarkdownStyleSheet(
              p: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).secondary,
                fontSize: 14.0,
                fontWeight: FontWeight.normal,
                height: 1.5,
              ),
              strong: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).secondary,
                fontSize: 14.0,
                fontWeight: FontWeight.bold,
                height: 1.5,
              ),
              em: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).secondary,
                fontSize: 14.0,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              a: GoogleFonts.lexendDeca(
                color: AppTheme.of(context).primary,
                fontSize: 14.0,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

/// Widget que exibe o conteúdo do sharing (título e texto Markdown)
class SharingContentWidget extends StatelessWidget {
  const SharingContentWidget({
    super.key,
    required this.sharing,
  });

  final CcViewSharingsUsersRow sharing;

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
        child: MarkdownBody(
          data: sharing.text ?? '',
          onTapLink: (text, href, title) {
            if (href != null) {
              launchURL(href);
            }
          },
          styleSheet: MarkdownStyleSheet(
            p: GoogleFonts.lexendDeca(
              color: AppTheme.of(context).primaryText,
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
              height: 1.5,
            ),
            strong: GoogleFonts.lexendDeca(
              color: AppTheme.of(context).primaryText,
              fontSize: 14.0,
              fontWeight: FontWeight.bold,
              height: 1.5,
            ),
            em: GoogleFonts.lexendDeca(
              color: AppTheme.of(context).primaryText,
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
    );
  }
}

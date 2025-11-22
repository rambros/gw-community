import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:google_fonts/google_fonts.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';

/// Widget que exibe o conteúdo do sharing (título e texto HTML)
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
      color: FlutterFlowTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Título
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Expanded(
                  child: Text(
                    valueOrDefault<String>(
                      sharing.title,
                      'title',
                    ),
                    style: FlutterFlowTheme.of(context).titleMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          color: FlutterFlowTheme.of(context).secondary,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
          // Conteúdo HTML
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 8.0),
            child: Html(
              data: sharing.text ?? '',
              onLinkTap: (url, _, __) => launchURL(url!),
            ),
          ),
        ],
      ),
    );
  }
}

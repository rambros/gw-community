import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
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
      color: AppTheme.of(context).primaryBackground,
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 12.0, 8.0),
        child: Html(
          data: sharing.text ?? '',
          onLinkTap: (url, _, __) => launchURL(url!),
        ),
      ),
    );
  }
}

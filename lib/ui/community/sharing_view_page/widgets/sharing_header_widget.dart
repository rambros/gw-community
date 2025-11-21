import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/backend/supabase/supabase.dart';
import '/components/user_avatar/user_avatar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';

/// Widget que exibe o cabeçalho do sharing com informações do autor
/// Inclui: avatar, nome do usuário, grupo (se aplicável) e visibilidade
class SharingHeaderWidget extends StatelessWidget {
  const SharingHeaderWidget({
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
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 12.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            UserAvatarWidget(
              imageUrl: sharing.photoUrl,
              fullName: sharing.fullName,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      valueOrDefault<String>(
                        sharing.displayName,
                        'name',
                      ),
                      style: FlutterFlowTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.inter(
                              fontWeight: FontWeight.normal,
                            ),
                            color: FlutterFlowTheme.of(context).secondary,
                            fontSize: 16.0,
                            letterSpacing: 0.0,
                            fontWeight: FontWeight.normal,
                          ),
                    ),
                    if (sharing.groupName != null && sharing.groupName != '')
                      Text(
                        'From group ${sharing.groupName}',
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                            ),
                      ),
                    _buildVisibilityText(context),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityText(BuildContext context) {
    final isEveryone = sharing.visibility == 'everyone';
    final text = isEveryone ? 'Sharing for everyone' : 'Sharing only for this group';

    return Text(
      text,
      style: FlutterFlowTheme.of(context).bodyMedium.override(
            font: GoogleFonts.lexendDeca(),
            color: FlutterFlowTheme.of(context).primary,
            fontSize: 12.0,
            letterSpacing: 0.0,
          ),
    );
  }
}

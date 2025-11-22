import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';

/// Widget que exibe os botões de ação do sharing
/// Inclui: comentar, deletar e lock/unlock
class SharingActionsWidget extends StatelessWidget {
  const SharingActionsWidget({
    super.key,
    required this.sharing,
    required this.onComment,
    this.onDelete,
    this.onToggleLock,
    required this.canDelete,
    required this.canLock,
  });

  final CcViewSharingsUsersRow sharing;
  final VoidCallback onComment;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleLock;
  final bool canDelete;
  final bool canLock;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão de comentar com contador
          _buildCommentButton(context),

          // Botão de deletar (apenas se tiver permissão)
          if (canDelete) _buildDeleteButton(context),

          // Botão de lock (apenas se tiver permissão)
          if (canLock) _buildLockButton(context),
        ],
      ),
    );
  }

  Widget _buildCommentButton(BuildContext context) {
    final isLocked = sharing.locked ?? false;

    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15.0),
            border: Border.all(
              color: AppTheme.of(context).alternate,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(2.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                    child: FlutterFlowIconButton(
                      borderRadius: 8.0,
                      buttonSize: 40.0,
                      icon: Icon(
                        Icons.comment_rounded,
                        color:
                            isLocked ? AppTheme.of(context).alternate : AppTheme.of(context).secondary,
                        size: 28.0,
                      ),
                      onPressed: isLocked ? null : onComment,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 10.0, 0.0),
                  child: Text(
                    valueOrDefault<String>(
                      sharing.comments?.toString(),
                      '0',
                    ),
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          fontSize: 17.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: const BoxDecoration(),
      child: FlutterFlowIconButton(
        borderRadius: 8.0,
        buttonSize: 40.0,
        icon: Icon(
          Icons.delete,
          color: AppTheme.of(context).secondary,
          size: 26.0,
        ),
        onPressed: onDelete,
      ),
    );
  }

  Widget _buildLockButton(BuildContext context) {
    return Container(
      height: 50.0,
      decoration: const BoxDecoration(),
      child: FlutterFlowIconButton(
        borderRadius: 8.0,
        buttonSize: 40.0,
        icon: Icon(
          Icons.lock,
          color: AppTheme.of(context).secondary,
          size: 26.0,
        ),
        onPressed: onToggleLock,
      ),
    );
  }
}

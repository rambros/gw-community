import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';

/// Widget que exibe os botões de ação do sharing
/// Inclui: comentar, editar, deletar e lock/unlock
class SharingActionsWidget extends StatelessWidget {
  const SharingActionsWidget({
    super.key,
    required this.sharing,
    required this.onComment,
    this.onEdit,
    this.onDelete,
    this.onToggleLock,
    this.canEdit = false,
    required this.canDelete,
    required this.canLock,
  });

  final CcViewSharingsUsersRow sharing;
  final VoidCallback onComment;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleLock;
  final bool canEdit;
  final bool canDelete;
  final bool canLock;

  @override
  Widget build(BuildContext context) {
    final hasAdminActions = canDelete || canLock;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Botão de comentar com contador
          _buildCommentButton(context),

          // Botão de editar (apenas para o autor)
          if (canEdit) _buildEditButton(context),

          // Ações de admin agrupadas (deletar, lock)
          if (hasAdminActions) _buildAdminActionsGroup(context),
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

  Widget _buildEditButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
      child: Container(
        height: 44.0,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(
            color: AppTheme.of(context).primary.withValues(alpha: 0.3),
            width: 1.0,
          ),
          color: AppTheme.of(context).primary.withValues(alpha: 0.05),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(15.0),
            onTap: onEdit,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.edit_outlined,
                    color: AppTheme.of(context).primary,
                    size: 20.0,
                  ),
                  const SizedBox(width: 6.0),
                  Text(
                    'Edit',
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).primary,
                          fontSize: 14.0,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminActionsGroup(BuildContext context) {
    final isLocked = sharing.locked ?? false;

    return Container(
      height: 44.0,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        border: Border.all(
          color: AppTheme.of(context).alternate,
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (canDelete)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14.0),
                  bottomLeft: const Radius.circular(14.0),
                  topRight: canLock ? Radius.zero : const Radius.circular(14.0),
                  bottomRight: canLock ? Radius.zero : const Radius.circular(14.0),
                ),
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Icon(
                    Icons.delete_outline,
                    color: AppTheme.of(context).secondary,
                    size: 22.0,
                  ),
                ),
              ),
            ),
          if (canDelete && canLock)
            Container(
              width: 1.0,
              height: 24.0,
              color: AppTheme.of(context).alternate,
            ),
          if (canLock)
            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.only(
                  topLeft: canDelete ? Radius.zero : const Radius.circular(14.0),
                  bottomLeft: canDelete ? Radius.zero : const Radius.circular(14.0),
                  topRight: const Radius.circular(14.0),
                  bottomRight: const Radius.circular(14.0),
                ),
                onTap: onToggleLock,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Icon(
                    isLocked ? Icons.lock : Icons.lock_open,
                    color: AppTheme.of(context).secondary,
                    size: 22.0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

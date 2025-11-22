import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';

/// Widget que exibe um comentário individual
/// Suporta indentação baseada na profundidade (depth) para respostas aninhadas
class CommentItemWidget extends StatelessWidget {
  const CommentItemWidget({
    super.key,
    required this.comment,
    required this.onReply,
    this.onDelete,
    required this.canDelete,
  });

  final CcViewOrderedCommentsRow comment;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final bool canDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          // Espaçamento para indentação baseado na profundidade
          Container(
            width: (comment.depth ?? 0) * 12.0,
            decoration: BoxDecoration(
              color: AppTheme.of(context).primaryBackground,
            ),
          ),
          // Card do comentário
          Expanded(
            child: Container(
              width: 100.0,
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
                borderRadius: BorderRadius.circular(8.0),
                border: Border.all(
                  color: const Color(0xFFF5FBFB),
                ),
              ),
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    _buildCommentHeader(context),
                    _buildCommentContent(context),
                    _buildCommentActions(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentHeader(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
          child: Text(
            valueOrDefault<String>(
              comment.displayName,
              'display_name',
            ),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: FontWeight.w600,
                  ),
                  color: AppTheme.of(context).secondary,
                  fontSize: 14.0,
                  letterSpacing: 0.0,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ),
        Text(
          dateTimeFormat(
            "relative",
            comment.createdAt!,
            locale: FFLocalizations.of(context).languageCode,
          ),
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).secondary,
                fontSize: 14.0,
                letterSpacing: 0.0,
              ),
        ),
      ],
    );
  }

  Widget _buildCommentContent(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      children: [
        Expanded(
          child: Text(
            valueOrDefault<String>(
              comment.content,
              'comment',
            ),
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).secondary,
                  letterSpacing: 0.0,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildCommentActions(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        // Botão de responder
        FlutterFlowIconButton(
          borderRadius: 8.0,
          buttonSize: 40.0,
          icon: Icon(
            Icons.reply_outlined,
            color: AppTheme.of(context).secondary,
            size: 26.0,
          ),
          onPressed: onReply,
        ),
        // Botão de deletar (apenas se tiver permissão)
        if (canDelete)
          FlutterFlowIconButton(
            borderRadius: 8.0,
            buttonSize: 40.0,
            icon: Icon(
              Icons.delete,
              color: AppTheme.of(context).secondary,
              size: 26.0,
            ),
            onPressed: onDelete,
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Dialog for moderation actions that require a reason (Reject or Request Changes)
class ModerationActionDialog extends StatefulWidget {
  final String title;
  final String hint;
  final String actionLabel;
  final Color? actionColor;

  const ModerationActionDialog({
    super.key,
    required this.title,
    required this.hint,
    required this.actionLabel,
    this.actionColor,
  });

  /// Shows a dialog for rejecting an experience
  static Future<String?> showReject(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (_) => ModerationActionDialog(
        title: l10n.setAsNotPublished,
        hint: l10n.explainNotPublished,
        actionLabel: l10n.confirm,
        actionColor: Colors.red,
      ),
    );
  }

  /// Shows a dialog for suggesting refinement on an experience
  static Future<String?> showSuggestRefinement(BuildContext context) {
    final l10n = context.l10n;
    return showDialog<String>(
      context: context,
      builder: (_) => ModerationActionDialog(
        title: l10n.suggestRefinement,
        hint: l10n.provideRefinementFeedback,
        actionLabel: l10n.suggestRefinement,
        actionColor: Colors.orange,
      ),
    );
  }

  @override
  State<ModerationActionDialog> createState() => _ModerationActionDialogState();
}

class _ModerationActionDialogState extends State<ModerationActionDialog> {
  final _controller = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.of(context).primaryBackground,
      title: Text(
        widget.title,
        style: AppTheme.of(context).headlineSmall.override(font: GoogleFonts.lexendDeca(), fontSize: 20.0),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTheme.of(context).bodySmall,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppTheme.of(context).secondaryBackground, width: 1.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(color: AppTheme.of(context).primary, width: 2.0),
            ),
          ),
          maxLines: 4,
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return context.l10n.pleaseProvideReason;
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            context.l10n.cancel,
            style: AppTheme.of(
              context,
            ).bodyMedium.override(font: GoogleFonts.lexendDeca(), color: AppTheme.of(context).secondaryText),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(context, _controller.text.trim());
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.actionColor ?? AppTheme.of(context).primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          ),
          child: Text(widget.actionLabel, style: GoogleFonts.lexendDeca(fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }
}

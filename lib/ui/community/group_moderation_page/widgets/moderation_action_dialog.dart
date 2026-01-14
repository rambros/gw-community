import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    this.hint = 'Provide a reason...',
    this.actionLabel = 'Confirm',
    this.actionColor,
  });

  /// Shows a dialog for rejecting an experience
  static Future<String?> showReject(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ModerationActionDialog(
        title: 'Reject Experience',
        hint: 'Explain why this experience is being rejected...',
        actionLabel: 'Reject',
        actionColor: Colors.red,
      ),
    );
  }

  /// Shows a dialog for requesting changes on an experience
  static Future<String?> showRequestChanges(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (_) => const ModerationActionDialog(
        title: 'Request Changes',
        hint: 'Provide feedback on what needs to be changed...',
        actionLabel: 'Request Changes',
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
        style: AppTheme.of(context).headlineSmall.override(
              font: GoogleFonts.lexendDeca(),
              fontSize: 20.0,
            ),
      ),
      content: Form(
        key: _formKey,
        child: TextFormField(
          controller: _controller,
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: AppTheme.of(context).bodySmall,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: AppTheme.of(context).secondaryBackground,
                width: 1.0,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.0),
              borderSide: BorderSide(
                color: AppTheme.of(context).primary,
                width: 2.0,
              ),
            ),
          ),
          maxLines: 4,
          autofocus: true,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please provide a reason';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).secondaryText,
                ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: Text(
            widget.actionLabel,
            style: GoogleFonts.lexendDeca(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

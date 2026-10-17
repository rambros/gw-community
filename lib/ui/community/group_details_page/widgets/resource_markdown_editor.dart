import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/transcript_markdown.dart';

/// Markdown editor with an edit field and a rendered preview.
class ResourceMarkdownEditor extends StatefulWidget {
  const ResourceMarkdownEditor({
    super.key,
    required this.controller,
    this.enabled = true,
  });

  final TextEditingController controller;
  final bool enabled;

  @override
  State<ResourceMarkdownEditor> createState() => _ResourceMarkdownEditorState();
}

class _ResourceMarkdownEditorState extends State<ResourceMarkdownEditor> {
  bool _preview = false;

  @override
  Widget build(BuildContext context) {
    final primary = AppTheme.of(context).primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _modeButton(
                context,
                label: context.l10n.edit,
                selected: !_preview,
                onTap: () => setState(() => _preview = false),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _modeButton(
                context,
                label: context.l10n.preview,
                selected: _preview,
                onTap: () => setState(() => _preview = true),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_preview)
          _buildPreview(context)
        else
          TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            minLines: 8,
            maxLines: 12,
            keyboardType: TextInputType.multiline,
            textCapitalization: TextCapitalization.sentences,
            textAlignVertical: TextAlignVertical.top,
            style: GoogleFonts.openSans(fontSize: 14, height: 1.45),
            decoration: InputDecoration(
              hintText: context.l10n.markdownPlaceholder,
              hintStyle: const TextStyle(color: Color(0xFF57636C), fontSize: 14),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.06),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: primary, width: 1.5),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          context.l10n.markdownSupported,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade600, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildPreview(BuildContext context) {
    final text = widget.controller.text.trim();

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 180),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: text.isEmpty
          ? Text(
              context.l10n.noContentAvailable,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            )
          : TranscriptMarkdown(data: text),
    );
  }

  Widget _modeButton(
    BuildContext context, {
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final primary = AppTheme.of(context).primary;

    return GestureDetector(
      onTap: widget.enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? primary.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? primary : Colors.grey.shade300,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            color: selected ? primary : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}

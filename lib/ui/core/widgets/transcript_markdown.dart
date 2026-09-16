import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Renders transcript text with a small Markdown subset for long-form reading.
class TranscriptMarkdown extends StatelessWidget {
  const TranscriptMarkdown({
    super.key,
    required this.data,
    this.textColor,
  });

  final String data;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final color = textColor ?? theme.textColor;
    final body = theme.bodyMedium.copyWith(
      color: color,
      height: 1.7,
    );

    return MarkdownBody(
      data: data,
      selectable: true,
      softLineBreak: true,
      fitContent: true,
      imageBuilder: (uri, title, alt) => const SizedBox.shrink(),
      styleSheet: MarkdownStyleSheet(
        p: body,
        pPadding: const EdgeInsets.only(bottom: 14.0),
        strong: body.copyWith(fontWeight: FontWeight.w700),
        em: body.copyWith(fontStyle: FontStyle.italic),
        del: body.copyWith(decoration: TextDecoration.lineThrough),
        h1: theme.headlineSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        h1Padding: const EdgeInsets.only(top: 8.0, bottom: 12.0),
        h2: theme.titleMedium.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        h2Padding: const EdgeInsets.only(top: 20.0, bottom: 8.0),
        h3: theme.titleSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
        h3Padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
        listBullet: body,
        blockquote: body.copyWith(fontStyle: FontStyle.italic),
        blockquotePadding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
        blockquoteDecoration: BoxDecoration(
          border: Border(
            left: BorderSide(color: theme.alternate, width: 3),
          ),
        ),
        a: body.copyWith(
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
        horizontalRuleDecoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: theme.alternate),
          ),
        ),
      ),
    );
  }
}

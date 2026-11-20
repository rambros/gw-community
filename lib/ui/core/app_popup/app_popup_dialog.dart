import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/app_popup.dart';
import 'package:gw_community/data/repositories/app_popup_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/app_popup/app_popup_celebration.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

Future<void> showAppPopupDialog(
  BuildContext context, {
  required AppPopup popup,
  required String userId,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AppPopupDialog(popup: popup, userId: userId),
  );
}

class AppPopupDialog extends StatefulWidget {
  const AppPopupDialog({
    super.key,
    required this.popup,
    required this.userId,
  });

  final AppPopup popup;
  final String userId;

  @override
  State<AppPopupDialog> createState() => _AppPopupDialogState();
}

class _AppPopupDialogState extends State<AppPopupDialog> {
  final AppPopupRepository _repository = AppPopupRepository();
  bool _saving = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final popup = widget.popup;
    final title = popup.title?.trim() ?? '';
    final body = popup.bodyMarkdown.trim();
    final imageUrl = popup.imageUrl?.trim() ?? '';
    final height = MediaQuery.sizeOf(context).height;

    final burst = popup.animation == 'confetti' || popup.animation == 'sparkle';
    return PopScope(
      canPop: false,
      child: Stack(
        children: [
          Dialog(
            insetPadding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: AppPopupCelebration(
              animation: popup.animation == 'pulse' ? 'pulse' : 'none',
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 420,
                  maxHeight: height * 0.85,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      fit: FlexFit.loose,
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (imageUrl.isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: imageUrl,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                errorWidget: (_, __, ___) =>
                                    const SizedBox.shrink(),
                              ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (title.isNotEmpty)
                                    Text(
                                      title,
                                      style: theme.titleLarge.override(
                                        font: GoogleFonts.lexendDeca(),
                                        color: theme.secondary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  if (body.isNotEmpty) ...[
                                    if (title.isNotEmpty)
                                      const SizedBox(height: 12),
                                    MarkdownBody(
                                      data: body,
                                      onTapLink: (text, href, title) {
                                        if (href != null &&
                                            href.trim().isNotEmpty) {
                                          launchURL(href);
                                        }
                                      },
                                      styleSheet: MarkdownStyleSheet(
                                        p: GoogleFonts.lexendDeca(
                                          color: theme.secondary,
                                          fontSize: 15,
                                          height: 1.45,
                                        ),
                                        strong: GoogleFonts.lexendDeca(
                                          color: theme.secondary,
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_error != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                _error!,
                                style: theme.bodySmall
                                    .override(color: theme.error),
                              ),
                            ),
                          if (popup.showsButton)
                            FilledButton(
                              onPressed: _saving
                                  ? null
                                  : () => _complete(action: 'cta'),
                              style: FilledButton.styleFrom(
                                  backgroundColor: theme.primary),
                              child: Text(popup.ctaLabel!.trim()),
                            ),
                          TextButton(
                            onPressed: _saving
                                ? null
                                : () => _complete(action: 'close'),
                            child: Text(context.l10n.close),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (burst)
            Positioned.fill(
              child: IgnorePointer(
                child: AppPopupCelebration(
                  animation: popup.animation,
                  child: const SizedBox.expand(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _complete({required String action}) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await _repository.dismiss(
        popupId: widget.popup.id,
        userId: widget.userId,
        action: action,
      );
    } catch (error) {
      debugPrint('App popup dismiss failed: $error');
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = context.l10n.failedToSaveTryAgain;
      });
      return;
    }

    if (!mounted) return;
    final router = GoRouter.of(context);
    final popup = widget.popup;
    final target = popup.ctaTarget?.trim() ?? '';
    Navigator.of(context).pop();
    if (action != 'cta') return;
    if (popup.ctaAction == 'url' &&
        RegExp(r'^https?://', caseSensitive: false).hasMatch(target)) {
      await launchURL(target);
      return;
    }
    if (popup.ctaAction == 'route' && appPopupRouteTargets.contains(target)) {
      router.go(target);
    }
  }
}

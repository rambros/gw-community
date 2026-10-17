import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

class ViewAsBanner extends StatelessWidget {
  const ViewAsBanner({
    super.key,
    required this.displayName,
    required this.onExit,
  });

  final String displayName;
  final VoidCallback onExit;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final l10n = context.l10n;
    return Material(
      color: theme.secondary,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, color: theme.primaryText, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.viewingAs(displayName),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.bodyMedium.override(
                    color: theme.primaryText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: onExit,
                child: Text(l10n.exitViewAs),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

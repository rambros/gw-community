import 'package:flutter/material.dart';
import 'package:gw_community/l10n/journey_language.dart';

/// Re-resolves `context.l10n` for a journey when a language is fixed.
class JourneyLocaleScope extends StatelessWidget {
  const JourneyLocaleScope({
    super.key,
    required this.fixedLanguage,
    required this.child,
  });

  final String? fixedLanguage;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final locale = JourneyLanguage.localeOrNull(fixedLanguage);
    if (locale == null) return child;
    return Localizations.override(
      context: context,
      locale: locale,
      child: child,
    );
  }
}

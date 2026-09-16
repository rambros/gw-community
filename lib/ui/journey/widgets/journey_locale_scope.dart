import 'package:flutter/material.dart';
import 'package:gw_community/l10n/journey_language.dart';

/// Re-resolves `context.l10n` for a journey when a language is fixed.
///
/// Use [builder] so titles read the overridden locale, not the page's
/// outer context (the app language).
class JourneyLocaleScope extends StatelessWidget {
  const JourneyLocaleScope({
    super.key,
    required this.fixedLanguage,
    required this.builder,
  });

  final String? fixedLanguage;
  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    final locale = JourneyLanguage.localeOrNull(fixedLanguage);
    if (locale == null) return builder(context);
    return Localizations.override(
      context: context,
      locale: locale,
      child: Builder(builder: builder),
    );
  }
}

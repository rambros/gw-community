import 'package:flutter/material.dart';
import 'package:gw_community/l10n/app_locale.dart';

/// Optional language lock stored in `cc_journeys.fixed_language`.
///
/// `null` follows the language selected in the app. `en` / `pt` keep
/// journey labels (welcome, actions menu, dialogs) in that language.
class JourneyLanguage {
  static const english = 'en';
  static const portuguese = 'pt';

  static Locale? localeOrNull(String? dbValue) {
    if (dbValue == null || dbValue.isEmpty) return null;
    return AppLocale.parse(dbValue);
  }

  /// Language shared by every locked journey. Mixed or unset values follow the app.
  static String? sharedFixedLanguage(Iterable<String?> codes) {
    final unique = codes
        .map((code) => code?.trim())
        .whereType<String>()
        .where((code) => code.isNotEmpty)
        .toSet();
    if (unique.length == 1) return unique.first;
    return null;
  }
}

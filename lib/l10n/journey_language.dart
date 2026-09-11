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
}

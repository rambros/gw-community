import 'package:flutter/widgets.dart';
import 'package:gw_community/l10n/app_localizations.dart';

export 'package:gw_community/l10n/app_localizations.dart';
export 'package:gw_community/l10n/l10n_format.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension TimeBasedGreeting on AppLocalizations {
  /// 05:00–11:59 morning, 12:00–17:59 afternoon, 18:00–04:59 evening.
  String greetingForTime(String name, {DateTime? now}) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 5 && hour < 12) return goodMorningGreeting(name);
    if (hour >= 12 && hour < 18) return goodAfternoonGreeting(name);
    return goodEveningGreeting(name);
  }
}

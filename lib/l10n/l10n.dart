import 'package:flutter/widgets.dart';
import 'package:gw_community/l10n/app_localizations.dart';

export 'package:gw_community/l10n/app_localizations.dart';
export 'package:gw_community/l10n/l10n_format.dart';

extension L10nContext on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

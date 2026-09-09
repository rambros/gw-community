import 'package:flutter/material.dart';
import 'package:gw_community/l10n/app_locale.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/app/view_model/app_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:provider/provider.dart';

Future<void> showLanguagePicker(BuildContext context) async {
  final l10n = context.l10n;
  final current = Localizations.localeOf(context).languageCode;

  final selected = await showModalBottomSheet<String>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.chooseLanguage,
                  style: AppTheme.of(sheetContext).titleMedium,
                ),
              ),
            ),
            ListTile(
              title: Text(l10n.languageEnglish),
              trailing: current == 'en' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(sheetContext, 'en'),
            ),
            ListTile(
              title: Text(l10n.languagePortuguese),
              trailing: current == 'pt' ? const Icon(Icons.check) : null,
              onTap: () => Navigator.pop(sheetContext, 'pt'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );

  if (selected == null || !context.mounted) return;
  await context.read<AppViewModel>().setLocaleAndPersist(selected);
}

String currentLanguageLabel(BuildContext context) {
  final code = AppLocale.parse(Localizations.localeOf(context).languageCode);
  return code == AppLocale.pt
      ? context.l10n.languagePortuguese
      : context.l10n.languageEnglish;
}

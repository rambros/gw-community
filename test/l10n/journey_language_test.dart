import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/l10n/app_locale.dart';
import 'package:gw_community/l10n/journey_language.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';

void main() {
  group('JourneyLanguage.localeOrNull', () {
    test('follows the app when the journey has no fixed language', () {
      expect(JourneyLanguage.localeOrNull(null), isNull);
      expect(JourneyLanguage.localeOrNull(''), isNull);
    });

    test('locks to English or Portuguese when a language is fixed', () {
      expect(JourneyLanguage.localeOrNull('en'), AppLocale.en);
      expect(JourneyLanguage.localeOrNull('pt'), AppLocale.pt);
      expect(JourneyLanguage.localeOrNull('pt-BR'), AppLocale.pt);
    });
  });

  group('JourneyLocaleScope', () {
    testWidgets('keeps app language when the journey is not locked', (tester) async {
      late String label;
      await tester.pumpWidget(
        MaterialApp(
          locale: AppLocale.pt,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: JourneyLocaleScope(
            fixedLanguage: null,
            builder: (context) {
              label = context.l10n.welcomeBack('Rodrigo');
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      expect(label, 'Bem-vindo de volta, Rodrigo');
    });

    testWidgets('shows English labels when the journey language is fixed', (tester) async {
      late String label;
      await tester.pumpWidget(
        MaterialApp(
          locale: AppLocale.pt,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: JourneyLocaleScope(
            fixedLanguage: 'en',
            builder: (context) {
              label = context.l10n.welcomeBack('Rodrigo');
              return Text(context.l10n.journeyResources);
            },
          ),
        ),
      );

      expect(label, 'Welcome back, Rodrigo');
      expect(find.text('Journey resources'), findsOneWidget);
    });
  });
}

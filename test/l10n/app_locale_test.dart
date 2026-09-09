import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/l10n/app_locale.dart';

void main() {
  group('AppLocale.resolve', () {
    test('uses the phone language when the user has not chosen one', () {
      expect(
        AppLocale.resolve(stored: null, device: const Locale('pt', 'BR')),
        AppLocale.pt,
      );
      expect(
        AppLocale.resolve(stored: null, device: const Locale('en', 'US')),
        AppLocale.en,
      );
    });

    test('keeps the language chosen in the profile', () {
      expect(
        AppLocale.resolve(
          stored: AppLocale.en,
          device: const Locale('pt', 'BR'),
        ),
        AppLocale.en,
      );
    });

    test('treats pt-BR as Portuguese', () {
      expect(AppLocale.parse('pt-BR'), AppLocale.pt);
      expect(AppLocale.parse('pt_BR'), AppLocale.pt);
    });
  });
}

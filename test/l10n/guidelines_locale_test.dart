import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/l10n/guidelines_locale.dart';

void main() {
  group('GuidelinesLocale.pick', () {
    test('returns Portuguese when the UI is in Portuguese', () {
      expect(
        GuidelinesLocale.pick(
          languageCode: 'pt',
          english: 'Hello',
          portuguese: 'Olá',
        ),
        'Olá',
      );
    });

    test('falls back to English when Portuguese is empty', () {
      expect(
        GuidelinesLocale.pick(
          languageCode: 'pt-BR',
          english: 'Hello',
          portuguese: '  ',
        ),
        'Hello',
      );
    });

    test('returns English for other languages', () {
      expect(
        GuidelinesLocale.pick(
          languageCode: 'en',
          english: 'Hello',
          portuguese: 'Olá',
        ),
        'Hello',
      );
    });
  });

  group('CommunityGuidelinesVersions.resolve', () {
    const versions = CommunityGuidelinesVersions(
      english: 'Hello',
      portuguese: 'Olá',
    );

    test('resolves Portuguese for pt locales', () {
      expect(versions.resolve('pt-BR'), 'Olá');
    });

    test('resolves English otherwise', () {
      expect(versions.resolve('en'), 'Hello');
    });
  });
}

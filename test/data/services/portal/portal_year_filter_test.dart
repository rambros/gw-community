import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/data/services/portal/portal_year_filter.dart';

void main() {
  group('matchesPublishedYear', () {
    test('keeps every item when year is empty', () {
      expect(
        matchesPublishedYear(
          year: '',
          datePublished: DateTime(2023, 11, 19),
          yearPublished: 2023,
        ),
        isTrue,
      );
    });

    test('matches EXTRACT year_published even when stored as a double', () {
      expect(
        matchesPublishedYear(
          year: '2024',
          datePublished: DateTime(2023, 11, 19),
          yearPublished: 2024.0,
        ),
        isTrue,
      );
    });

    test('falls back to date_published year', () {
      expect(
        matchesPublishedYear(
          year: '2023',
          datePublished: DateTime(2023, 11, 19),
          yearPublished: null,
        ),
        isTrue,
      );
    });

    test('rejects content from another year', () {
      expect(
        matchesPublishedYear(
          year: '2024',
          datePublished: DateTime(2026, 5, 26),
          yearPublished: 2026,
        ),
        isFalse,
      );
    });
  });

  group('parsePublishedYear', () {
    test('parses a trimmed year and ignores blanks', () {
      expect(parsePublishedYear(' 2024 '), 2024);
      expect(parsePublishedYear(''), isNull);
    });
  });
}

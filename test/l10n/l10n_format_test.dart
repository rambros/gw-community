import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/l10n/app_localizations_en.dart';
import 'package:gw_community/l10n/app_localizations_pt.dart';
import 'package:gw_community/l10n/l10n_format.dart';

void main() {
  group('localizedGroupPrivacy', () {
    final en = AppLocalizationsEn();
    final pt = AppLocalizationsPt();

    test('maps Public and Private without showing the stored English value', () {
      expect(localizedGroupPrivacy(en, 'Public'), 'Public');
      expect(localizedGroupPrivacy(en, 'Private'), 'Private');
      expect(localizedGroupPrivacy(pt, 'Public'), 'Público');
      expect(localizedGroupPrivacy(pt, 'Private'), 'Privado');
    });
  });

  group('localizedExperienceStatus', () {
    final pt = AppLocalizationsPt();

    test('maps stored status codes to Portuguese chrome', () {
      expect(localizedExperienceStatus(pt, 'draft'), 'Em reflexão');
      expect(localizedExperienceStatus(pt, 'awaiting_approval'), 'Aguardando aprovação');
      expect(localizedExperienceStatus(pt, 'rejected'), 'Não publicada');
      expect(localizedExperienceStatus(pt, 'changes_requested'), 'Ajuste sugerido');
    });
  });

  group('relativeLastPostLabel', () {
    final pt = AppLocalizationsPt();
    final now = DateTime(2026, 9, 9, 12);

    test('uses Portuguese copy for empty, recent, and dated posts', () {
      expect(
        relativeLastPostLabel(
          l10n: pt,
          now: now,
          lastPost: null,
          formattedDate: '11 de jul.',
        ),
        'Nenhuma publicação ainda',
      );
      expect(
        relativeLastPostLabel(
          l10n: pt,
          now: now,
          lastPost: now.subtract(const Duration(minutes: 12)),
          formattedDate: '11 de jul.',
        ),
        'Última publicação há 12 min',
      );
      expect(
        relativeLastPostLabel(
          l10n: pt,
          now: now,
          lastPost: now.subtract(const Duration(days: 10)),
          formattedDate: '11 de jul.',
        ),
        'Última publicação 11 de jul.',
      );
    });
  });

  group('libraryActiveFiltersDescription', () {
    final pt = AppLocalizationsPt();

    test('returns no-filter copy when nothing is selected', () {
      expect(libraryActiveFiltersDescription(l10n: pt), 'Nenhum filtro');
    });

    test('labels active filters in Portuguese', () {
      expect(
        libraryActiveFiltersDescription(
          l10n: pt,
          author: 'Mohini Didi',
          year: '2024',
          topics: const ['Light'],
        ),
        'Filtros → Autor: Mohini Didi | Ano: 2024 | Temas: Light',
      );
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/models/journey_step_group.dart';

void main() {
  group('firstNumberOfGroup', () {
    test('counts across sections instead of restarting at 1', () {
      const groups = [
        JourneyStepGroup<int>(sectionId: null, title: null, steps: [1, 2, 3, 4, 5]),
        JourneyStepGroup<int>(
          sectionId: 10,
          title: 'Identidade Espiritual',
          steps: [6, 7, 8, 9],
        ),
        JourneyStepGroup<int>(
          sectionId: 20,
          title: 'Ser Supremo',
          steps: [10],
        ),
      ];

      expect(firstNumberOfGroup(groups, 0), 1);
      expect(firstNumberOfGroup(groups, 1), 6);
      expect(firstNumberOfGroup(groups, 2), 10);
    });
  });

  group('groupJourneySteps', () {
    test('keeps empty named sections in order', () {
      final groups = groupJourneySteps<(int id, int? sectionId, int number)>(
        steps: const [
          (1, 10, 1),
          (2, 10, 2),
        ],
        sections: const [
          (id: 10, title: 'Fundamentos', sectionOrder: 1),
          (id: 20, title: 'Meditação', sectionOrder: 2),
        ],
        sectionIdOf: (step) => step.$2,
        stepNumberOf: (step) => step.$3,
      );

      expect(groups, hasLength(2));
      expect(groups[0].title, 'Fundamentos');
      expect(groups[0].steps, hasLength(2));
      expect(groups[1].title, 'Meditação');
      expect(groups[1].steps, isEmpty);
    });
  });

  group('expandedJourneySectionId', () {
    const groups = [
      JourneyStepGroup<int>(sectionId: 1, title: 'Fundamentos', steps: [1, 2]),
      JourneyStepGroup<int>(sectionId: 2, title: 'Alma', steps: [6, 7]),
      JourneyStepGroup<int>(sectionId: 3, title: 'Alma Suprema', steps: [10]),
    ];

    test('opens the section the user just left and leaves the others closed', () {
      expect(
        expandedJourneySectionId(
          groups: groups,
          preferredSectionId: 2,
          currentStepSectionId: 1,
        ),
        2,
      );
    });

    test('opens the current step section when nothing was just viewed', () {
      expect(
        expandedJourneySectionId(
          groups: groups,
          preferredSectionId: null,
          currentStepSectionId: 2,
        ),
        2,
      );
    });

    test('falls back to the first section that has steps', () {
      expect(
        expandedJourneySectionId(
          groups: groups,
          preferredSectionId: null,
          currentStepSectionId: null,
        ),
        1,
      );
    });
  });
}

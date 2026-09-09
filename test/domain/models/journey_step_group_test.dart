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
}

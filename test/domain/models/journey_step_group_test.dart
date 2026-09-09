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
}

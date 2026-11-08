import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/step_wait.dart';

void main() {
  group('stepWaitElapsed', () {
    final startedAt = DateTime(2026, 11, 10, 5);

    test('stays closed later the same calendar day', () {
      expect(
        stepWaitElapsed(
          startedAt: startedAt,
          daysToWait: 1,
          now: DateTime(2026, 11, 10, 23, 59),
        ),
        isFalse,
      );
    });

    test('opens at midnight of the next calendar day', () {
      expect(
        stepWaitElapsed(
          startedAt: startedAt,
          daysToWait: 1,
          now: DateTime(2026, 11, 11),
        ),
        isTrue,
      );
    });

    test('a two-day wait opens at midnight two calendar days later', () {
      expect(
        stepWaitElapsed(
          startedAt: startedAt,
          daysToWait: 2,
          now: DateTime(2026, 11, 11, 23, 59),
        ),
        isFalse,
      );
      expect(
        stepWaitElapsed(
          startedAt: startedAt,
          daysToWait: 2,
          now: DateTime(2026, 11, 12),
        ),
        isTrue,
      );
    });
  });
}

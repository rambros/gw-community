import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';

void main() {
  EventWindow? window({
    required DateTime anchor,
    required DateTime now,
    DateTime? end,
    String? recurrence,
    DateTime? until,
  }) {
    return upcomingEventWindow(
      anchor: anchor,
      end: end,
      recurrence: recurrence,
      until: until,
      now: now,
    );
  }

  group('upcomingEventWindow', () {
    test('keeps a one-off event on its day and hides it the day after', () {
      final anchor = DateTime(2026, 10, 16);
      expect(window(anchor: anchor, now: DateTime(2026, 10, 16, 23))?.start, anchor);
      expect(window(anchor: anchor, now: DateTime(2026, 10, 17)), isNull);
    });

    test('keeps a multi-day event through its last day', () {
      final shown = window(
        anchor: DateTime(2026, 10, 16),
        end: DateTime(2026, 10, 18),
        now: DateTime(2026, 10, 18, 9),
      );
      expect(shown?.start, DateTime(2026, 10, 16));
      expect(shown?.end, DateTime(2026, 10, 18));
      expect(
        window(
          anchor: DateTime(2026, 10, 16),
          end: DateTime(2026, 10, 18),
          now: DateTime(2026, 10, 19),
        ),
        isNull,
      );
    });

    test('shows the first weekly date, then only the next one', () {
      final anchor = DateTime(2026, 10, 5);
      expect(window(anchor: anchor, recurrence: 'weekly', now: DateTime(2026, 10, 5))?.start, anchor);
      expect(
        window(anchor: anchor, recurrence: 'weekly', now: DateTime(2026, 10, 6))?.start,
        DateTime(2026, 10, 12),
      );
      expect(
        window(anchor: anchor, recurrence: 'weekly', now: DateTime(2026, 10, 12, 18))?.start,
        DateTime(2026, 10, 12),
      );
      expect(
        window(anchor: anchor, recurrence: 'weekly', now: DateTime(2026, 10, 13))?.start,
        DateTime(2026, 10, 19),
      );
    });

    test('steps a two-week series by 14 days', () {
      expect(
        window(
          anchor: DateTime(2026, 10, 5),
          recurrence: 'biweekly',
          now: DateTime(2026, 10, 20),
        )?.start,
        DateTime(2026, 11, 2),
      );
    });

    test('keeps the 31st and clamps months that are shorter', () {
      expect(
        window(
          anchor: DateTime(2025, 1, 31),
          recurrence: 'monthly',
          now: DateTime(2025, 2, 1),
        )?.start,
        DateTime(2025, 2, 28),
      );
      expect(
        window(
          anchor: DateTime(2025, 1, 31),
          recurrence: 'monthly',
          now: DateTime(2025, 3, 1),
        )?.start,
        DateTime(2025, 3, 31),
      );
      expect(
        window(
          anchor: DateTime(2024, 1, 31),
          recurrence: 'monthly',
          now: DateTime(2024, 2, 1),
        )?.start,
        DateTime(2024, 2, 29),
      );
    });

    test('shifts a multi-day series together and holds it until the last day', () {
      final during = window(
        anchor: DateTime(2026, 10, 5),
        end: DateTime(2026, 10, 7),
        recurrence: 'weekly',
        now: DateTime(2026, 10, 7),
      );
      expect(during?.start, DateTime(2026, 10, 5));
      expect(during?.end, DateTime(2026, 10, 7));

      final next = window(
        anchor: DateTime(2026, 10, 5),
        end: DateTime(2026, 10, 7),
        recurrence: 'weekly',
        now: DateTime(2026, 10, 8),
      );
      expect(next?.start, DateTime(2026, 10, 12));
      expect(next?.end, DateTime(2026, 10, 14));
    });

    test('stops after the last allowed start date', () {
      expect(
        window(
          anchor: DateTime(2026, 10, 5),
          recurrence: 'weekly',
          until: DateTime(2026, 10, 12),
          now: DateTime(2026, 10, 12),
        )?.start,
        DateTime(2026, 10, 12),
      );
      expect(
        window(
          anchor: DateTime(2026, 10, 5),
          recurrence: 'weekly',
          until: DateTime(2026, 10, 12),
          now: DateTime(2026, 10, 13),
        ),
        isNull,
      );
    });
  });
}

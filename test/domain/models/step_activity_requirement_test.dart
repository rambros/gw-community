import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/models/step_activity_requirement.dart';

void main() {
  final yesterday = DateTime(2026, 10, 11, 9);
  final today = DateTime(2026, 10, 12, 16);

  StepActivityProgress required({required bool done, DateTime? at}) {
    return StepActivityProgress(
      isRequired: true,
      isCompleted: done,
      completedAt: at,
    );
  }

  StepActivityProgress optional({required bool done, DateTime? at}) {
    return StepActivityProgress(
      isRequired: false,
      isCompleted: done,
      completedAt: at,
    );
  }

  group('canAdvancePastStep', () {
    test('blocks while a required activity is still open', () {
      expect(
        canAdvancePastStep([
          required(done: true, at: yesterday),
          required(done: false),
          optional(done: false),
        ]),
        isFalse,
      );
    });

    test(
        'advances when every required activity is done and the journal is still open',
        () {
      expect(
        canAdvancePastStep([
          required(done: true, at: yesterday),
          required(done: true, at: today),
          optional(done: false),
        ]),
        isTrue,
      );
    });

    test('does not advance an empty step', () {
      expect(canAdvancePastStep(const []), isFalse);
    });

    test('does not advance a step whose activities are all optional', () {
      expect(
        canAdvancePastStep([
          optional(done: false),
          optional(done: true, at: today),
        ]),
        isFalse,
      );
    });
  });

  group('latestRequiredCompletion', () {
    test('uses the latest required completion and ignores the journal', () {
      expect(
        latestRequiredCompletion([
          required(done: true, at: yesterday),
          optional(done: true, at: today),
        ]),
        yesterday,
      );
    });

    test('returns null when required activities have no completion time', () {
      expect(
        latestRequiredCompletion([
          required(done: true),
          optional(done: true, at: today),
        ]),
        isNull,
      );
    });
  });
}

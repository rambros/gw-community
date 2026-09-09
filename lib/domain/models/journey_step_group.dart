/// Groups journey steps under optional named sections.
class JourneyStepGroup<T> {
  const JourneyStepGroup({
    required this.sectionId,
    required this.title,
    required this.steps,
  });

  final int? sectionId;
  final String? title;
  final List<T> steps;

  bool get hasHeader => title != null && title!.isNotEmpty;
}

List<JourneyStepGroup<T>> groupJourneySteps<T>({
  required List<T> steps,
  required List<({int id, String title, int sectionOrder})> sections,
  required int? Function(T step) sectionIdOf,
  required int Function(T step) stepNumberOf,
}) {
  final sortedSteps = List<T>.of(steps)
    ..sort((a, b) => stepNumberOf(a).compareTo(stepNumberOf(b)));

  if (sections.isEmpty) {
    return [
      JourneyStepGroup<T>(
        sectionId: null,
        title: null,
        steps: sortedSteps,
      ),
    ];
  }

  final bySection = <int?, List<T>>{};
  for (final step in sortedSteps) {
    bySection.putIfAbsent(sectionIdOf(step), () => <T>[]).add(step);
  }

  final groups = <JourneyStepGroup<T>>[];
  final ungrouped = bySection[null] ?? <T>[];
  if (ungrouped.isNotEmpty) {
    groups.add(
      JourneyStepGroup<T>(
        sectionId: null,
        title: null,
        steps: ungrouped,
      ),
    );
  }

  final orderedSections = List.of(sections)
    ..sort((a, b) => a.sectionOrder.compareTo(b.sectionOrder));
  for (final section in orderedSections) {
    final sectionSteps = bySection[section.id] ?? <T>[];
    if (sectionSteps.isEmpty) continue;
    groups.add(
      JourneyStepGroup<T>(
        sectionId: section.id,
        title: section.title,
        steps: sectionSteps,
      ),
    );
  }
  return groups;
}

/// 1-based index of the first step in [groups] at [groupIndex], counting
/// through the whole journey instead of restarting in each section.
int firstNumberOfGroup<T>(List<JourneyStepGroup<T>> groups, int groupIndex) {
  var number = 1;
  final last = groupIndex.clamp(0, groups.length);
  for (var i = 0; i < last; i++) {
    number += groups[i].steps.length;
  }
  return number;
}

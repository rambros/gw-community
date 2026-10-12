/// Progress of one step activity, used to decide if the next step can open.
class StepActivityProgress {
  const StepActivityProgress({
    required this.isRequired,
    required this.isCompleted,
    this.completedAt,
  });

  final bool isRequired;
  final bool isCompleted;
  final DateTime? completedAt;
}

/// A step opens the next one only when it has at least one required activity
/// and every required activity is completed. Optional activities stay available
/// and are ignored. A step with no required activity does not advance on its own.
bool canAdvancePastStep(Iterable<StepActivityProgress> activities) {
  final requiredActivities = activities
      .where((activity) => activity.isRequired)
      .toList(growable: false);
  if (requiredActivities.isEmpty) return false;
  return requiredActivities.every((activity) => activity.isCompleted);
}

/// When the wait between steps is counted, it starts at the latest required
/// completion. An optional activity completed later does not move that moment.
DateTime? latestRequiredCompletion(Iterable<StepActivityProgress> activities) {
  DateTime? latest;
  for (final activity in activities) {
    if (!activity.isRequired || !activity.isCompleted) continue;
    final completedAt = activity.completedAt;
    if (completedAt == null) continue;
    if (latest == null || completedAt.isAfter(latest)) {
      latest = completedAt;
    }
  }
  return latest;
}

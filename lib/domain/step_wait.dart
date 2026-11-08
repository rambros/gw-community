/// Local calendar days from [startedAt] to [now]. The clock time is ignored,
/// so a step finished at 05:00 on day 10 has waited one day at 00:00 on day 11.
int calendarDaysSince(DateTime startedAt, DateTime now) {
  final startLocal = startedAt.toLocal();
  final nowLocal = now.toLocal();
  final startDate = DateTime(startLocal.year, startLocal.month, startLocal.day);
  final today = DateTime(nowLocal.year, nowLocal.month, nowLocal.day);
  return today.difference(startDate).inDays;
}

/// True once [daysToWait] local midnights have passed since [startedAt].
bool stepWaitElapsed({
  required DateTime? startedAt,
  required int daysToWait,
  DateTime? now,
}) {
  if (startedAt == null) return false;
  return calendarDaysSince(startedAt, now ?? DateTime.now()) >= daysToWait;
}

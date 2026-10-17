/// One community event row can repeat. Lists show a single occurrence:
/// the first date, then the next one after that day has passed.
class EventRecurrence {
  static const none = 'none';
  static const weekly = 'weekly';
  static const biweekly = 'biweekly';
  static const monthly = 'monthly';

  static const values = [weekly, biweekly, monthly];

  static bool repeats(String? value) {
    switch (value?.trim().toLowerCase()) {
      case weekly:
      case biweekly:
      case monthly:
        return true;
      default:
        return false;
    }
  }
}

/// The dates to show for the occurrence that is still current.
class EventWindow {
  const EventWindow({required this.start, this.end});

  final DateTime start;
  final DateTime? end;
}

/// Next occurrence whose last day is still today or later.
///
/// [anchor] is the first date stored on the event. A null or unknown
/// [recurrence] is a one-off event. [until] is the last start date allowed.
EventWindow? upcomingEventWindow({
  required DateTime anchor,
  DateTime? end,
  String? recurrence,
  DateTime? until,
  required DateTime now,
}) {
  final start = _calendarDate(anchor);
  final today = _calendarDate(now);
  final span = _spanDays(start, end);
  final rule = recurrence?.trim().toLowerCase();

  EventWindow windowAt(DateTime occurrenceStart) {
    final occurrenceEnd = span == 0 ? null : occurrenceStart.add(Duration(days: span));
    return EventWindow(start: occurrenceStart, end: occurrenceEnd);
  }

  bool stillCurrent(EventWindow window) {
    final lastDay = window.end ?? window.start;
    return !_calendarDate(lastDay).isBefore(today);
  }

  bool allowed(DateTime occurrenceStart) {
    if (until == null) return true;
    return !_calendarDate(occurrenceStart).isAfter(_calendarDate(until));
  }

  if (!EventRecurrence.repeats(rule)) {
    final window = windowAt(start);
    return stillCurrent(window) ? window : null;
  }

  if (rule == EventRecurrence.monthly) {
    final monthsAhead = (today.year - start.year) * 12 + (today.month - start.month) + span + 2;
    final limit = monthsAhead < 1 ? 1 : monthsAhead;
    for (var i = 0; i <= limit; i++) {
      final occurrenceStart = _addMonths(start, i);
      final window = windowAt(occurrenceStart);
      if (!stillCurrent(window)) continue;
      if (!allowed(occurrenceStart)) return null;
      return window;
    }
    return null;
  }

  final interval = rule == EventRecurrence.biweekly ? 14 : 7;
  final lookback = today.subtract(Duration(days: span));
  var occurrenceStart = start;
  if (!lookback.isBefore(start)) {
    final steps = lookback.difference(start).inDays ~/ interval;
    occurrenceStart = start.add(Duration(days: steps * interval));
  }

  for (var i = 0; i < 4; i++) {
    final window = windowAt(occurrenceStart);
    if (stillCurrent(window)) {
      if (!allowed(occurrenceStart)) return null;
      return window;
    }
    occurrenceStart = occurrenceStart.add(Duration(days: interval));
  }
  return null;
}

DateTime _calendarDate(DateTime value) => DateTime(value.year, value.month, value.day);

int _spanDays(DateTime start, DateTime? end) {
  if (end == null) return 0;
  final days = _calendarDate(end).difference(start).inDays;
  return days < 0 ? 0 : days;
}

DateTime _addMonths(DateTime anchor, int months) {
  final monthIndex = anchor.month - 1 + months;
  final year = anchor.year + monthIndex ~/ 12;
  final month = monthIndex % 12 + 1;
  final lastDay = DateTime(year, month + 1, 0).day;
  final day = anchor.day > lastDay ? lastDay : anchor.day;
  return DateTime(year, month, day);
}

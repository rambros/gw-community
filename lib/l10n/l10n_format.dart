import 'package:gw_community/l10n/app_localizations.dart';

String localizedGroupPrivacy(AppLocalizations l10n, String? privacy) {
  switch (privacy?.trim().toLowerCase()) {
    case 'private':
      return l10n.groupPrivacyPrivate;
    default:
      return l10n.groupPrivacyPublic;
  }
}

String relativeLastPostLabel({
  required AppLocalizations l10n,
  required DateTime now,
  DateTime? lastPost,
  required String formattedDate,
}) {
  if (lastPost == null) return l10n.noPostsYet;
  final diff = now.difference(lastPost);
  if (diff.inMinutes < 1) return l10n.lastPostJustNow;
  if (diff.inMinutes < 60) return l10n.lastPostMinutesAgo(diff.inMinutes);
  if (diff.inHours < 24) return l10n.lastPostHoursAgo(diff.inHours);
  if (diff.inDays < 7) return l10n.lastPostDaysAgo(diff.inDays);
  return l10n.lastPostOn(formattedDate);
}

String localizedJourneyActivityLabel(AppLocalizations l10n, String? label) {
  final raw = label?.trim() ?? '';
  final normalized = raw.toLowerCase();
  final numbered = RegExp(r'^(.*?)(?:\s+(\d+))?$').firstMatch(normalized);
  final base = numbered?.group(1)?.trim() ?? normalized;
  final number = numbered?.group(2);
  final translated = switch (base) {
    'inspiration' || 'inspiração' || 'inspiracao' => l10n.journeyActivityInspiration,
    'meditation' || 'meditação' || 'meditacao' => l10n.journeyActivityMeditation,
    'practices' ||
    'practice' ||
    'práticas' ||
    'pratica' ||
    'praticas' ||
    'daily practice' =>
      l10n.journeyActivityPractices,
    'journal' => l10n.mediaJournal,
    _ => null,
  };
  if (translated == null) {
    return raw.isNotEmpty ? raw : l10n.activityFallback;
  }
  if (number == null) return translated;
  return '$translated $number';
}

String localizedMediaType(AppLocalizations l10n, String? type) {
  switch (type) {
    case 'audio':
      return l10n.mediaAudio;
    case 'video':
      return l10n.mediaVideo;
    case 'text':
      return l10n.mediaText;
    case 'journal':
      return l10n.mediaJournal;
    default:
      return type?.trim().isNotEmpty == true ? type! : l10n.activityFallback;
  }
}

String favoriteOriginLabel(
  AppLocalizations l10n, {
  required bool isActivity,
  String? journeyTitle,
}) {
  if (!isActivity) return l10n.fromLibrary;
  final title = journeyTitle?.trim();
  if (title != null && title.isNotEmpty) return l10n.fromSource(title);
  return l10n.fromJourney;
}

String localizedExperienceStatus(AppLocalizations l10n, String? status) {
  switch (status) {
    case 'draft':
      return l10n.inReflection;
    case 'awaiting_approval':
    case 'pending':
      return l10n.awaitingApproval;
    case 'rejected':
      return l10n.notPublished;
    case 'changes_requested':
      return l10n.refinementSuggested;
    case 'approved':
      return l10n.published;
    default:
      return status ?? '';
  }
}

String libraryActiveFiltersDescription({
  required AppLocalizations l10n,
  String? author,
  String? event,
  String? year,
  String? journey,
  String? group,
  String? location,
  String? eventType,
  List<String> topics = const [],
}) {
  final parts = <String>[];
  if (author != null && author.trim().isNotEmpty) {
    parts.add(l10n.filterByAuthor(author));
  }
  if (event != null && event.trim().isNotEmpty) {
    parts.add(l10n.filterByEvent(event));
  }
  if (year != null && year.trim().isNotEmpty) {
    parts.add(l10n.filterByYear(year));
  }
  if (journey != null && journey.trim().isNotEmpty) {
    parts.add(l10n.filterByJourney(journey));
  }
  if (group != null && group.trim().isNotEmpty) {
    parts.add(l10n.filterByGroup(group));
  }
  if (location != null && location.trim().isNotEmpty) {
    parts.add(l10n.filterByLocation(location));
  }
  if (eventType != null && eventType.trim().isNotEmpty) {
    parts.add(l10n.filterByEventType(eventType));
  }
  if (topics.isNotEmpty) {
    parts.add(l10n.filterByTopics(topics.join(', ')));
  }
  if (parts.isEmpty) return l10n.noFilter;
  return l10n.filtersApplied(parts.join(' | '));
}

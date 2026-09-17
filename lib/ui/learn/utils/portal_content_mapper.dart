import 'package:gw_community/data/repositories/learn_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

ViewContentRow viewContentFromMessages(ViewMessagesRow row) {
  return ViewContentRow({
    'content_id': row.contentId,
    'title': row.title,
    'description': row.description,
    'content_type_id': row.contentTypeId,
    'midia_type': row.midiaType,
    'authors': row.authors,
    'authors_names': row.authorsNames,
    'audio_url': row.audioUrl,
    'midia_file_url': row.midiaFileUrl,
    'text': row.text,
    'date_published': row.datePublished?.toIso8601String(),
    'year_published': row.yearPublished,
    'is_published': row.isPublished,
  });
}

ViewContentRow viewContentFromMeditations(ViewMeditationsRow row) {
  return ViewContentRow({
    'content_id': row.contentId,
    'title': row.title,
    'description': row.description,
    'content_type_id': row.contentTypeId,
    'midia_type': row.midiaType,
    'authors': row.authors,
    'authors_names': row.authorsNames,
    'cott_event_id': row.cottEventId,
    'event_name': row.eventName,
    'audio_url': row.audioUrl,
    'midia_file_url': row.midiaFileUrl,
    'text': row.text,
    'transcript': row.transcript,
    'date_published': row.datePublished?.toIso8601String(),
    'year_published': row.yearPublished,
    'is_published': row.isPublished,
  });
}

enum LibraryContentSection {
  wordsOfWisdom,
  dadiJanki,
  meditations,
  dialoguesRetreats,
  heartToHeart,
}

bool isMessageContentType(int? contentTypeId) {
  return contentTypeId == 3 || contentTypeId == 4 || contentTypeId == 5;
}

bool isMeditationContentType(int? contentTypeId) {
  return contentTypeId == 6 || contentTypeId == 9;
}

bool isDadiJankiContent(ViewContentRow? row) {
  if (row == null) return false;
  if (row.authors.contains(LearnRepository.dadiJankiAuthorId)) return true;
  return row.authorsNames.any(
    (name) => name.toLowerCase().contains('dadi janki'),
  );
}

LibraryContentSection? librarySectionFromName(String? name) {
  if (name == null || name.isEmpty) return null;
  for (final section in LibraryContentSection.values) {
    if (section.name == name) return section;
  }
  return null;
}

LibraryContentSection? inferLibraryContentSection(ViewContentRow? row) {
  if (row == null) return null;
  if (isMessageContentType(row.contentTypeId)) {
    return LibraryContentSection.wordsOfWisdom;
  }
  if (isMeditationContentType(row.contentTypeId)) {
    return LibraryContentSection.meditations;
  }
  if (isDadiJankiContent(row)) {
    return LibraryContentSection.dadiJanki;
  }
  return switch (row.dashboardGroupId) {
    1 => LibraryContentSection.dialoguesRetreats,
    2 => LibraryContentSection.heartToHeart,
    _ => null,
  };
}

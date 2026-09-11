import 'package:gw_community/data/services/supabase/supabase.dart';

ViewContentRow viewContentFromMessages(ViewMessagesRow row) {
  return ViewContentRow({
    'content_id': row.contentId,
    'title': row.title,
    'description': row.description,
    'content_type_id': row.contentTypeId,
    'midia_type': row.midiaType,
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

bool isMessageContentType(int? contentTypeId) {
  return contentTypeId == 3 || contentTypeId == 4 || contentTypeId == 5;
}

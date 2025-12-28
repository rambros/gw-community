import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserFavoriteRecordingsTable
    extends SupabaseTable<CcViewUserFavoriteRecordingsRow> {
  @override
  String get tableName => 'cc_view_user_favorite_recordings';

  @override
  CcViewUserFavoriteRecordingsRow createRow(Map<String, dynamic> data) =>
      CcViewUserFavoriteRecordingsRow(data);
}

class CcViewUserFavoriteRecordingsRow extends SupabaseDataRow {
  CcViewUserFavoriteRecordingsRow(super.data);

  @override
  SupabaseTable get table => CcViewUserFavoriteRecordingsTable();

  // Favorite fields
  int? get favoriteId => getField<int>('favorite_id');
  String? get memberId => getField<String>('member_id');
  DateTime? get favoritedAt => getField<DateTime>('favorited_at');

  // Content fields (from view_content)
  int? get contentId => getField<int>('content_id');
  String? get title => getField<String>('title');
  String? get description => getField<String>('description');
  String? get contentType => getField<String>('content_type');
  String? get midiaType => getField<String>('midia_type');
  List<String> get authorsNames => getListField<String>('authors_names');
  String? get audioUrl => getField<String>('audio_url');
  String? get audioDuration => getField<String>('audio_duration');
  String? get midiaFileUrl => getField<String>('midia_file_url');
  String? get eventName => getField<String>('event_name');
  int? get cottEventId => getField<int>('cott_event_id');
  bool? get isPublished => getField<bool>('is_published');
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class PortalItemTable extends SupabaseTable<PortalItemRow> {
  @override
  String get tableName => 'portal_item';

  @override
  PortalItemRow createRow(Map<String, dynamic> data) => PortalItemRow(data);
}

class PortalItemRow extends SupabaseDataRow {
  PortalItemRow(super.data);

  @override
  SupabaseTable get table => PortalItemTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);

  List<int> get topics => getListField<int>('topics');
  set topics(List<int>? value) => setListField<int>('topics', value);

  String get text => getField<String>('text')!;
  set text(String value) => setField<String>('text', value);

  String get audioUrl => getField<String>('audio_url')!;
  set audioUrl(String value) => setField<String>('audio_url', value);

  String get audioDuration => getField<String>('audio_duration')!;
  set audioDuration(String value) => setField<String>('audio_duration', value);

  String get filenameSelected => getField<String>('filename_selected')!;
  set filenameSelected(String value) =>
      setField<String>('filename_selected', value);

  String get videoUrl => getField<String>('video_url')!;
  set videoUrl(String value) => setField<String>('video_url', value);

  int? get authorId => getField<int>('author_id');
  set authorId(int? value) => setField<int>('author_id', value);

  int? get cottEventId => getField<int>('cott_event_id');
  set cottEventId(int? value) => setField<int>('cott_event_id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  int? get contentTypeId => getField<int>('content_type_id');
  set contentTypeId(int? value) => setField<int>('content_type_id', value);

  bool get isPublished => getField<bool>('is_published')!;
  set isPublished(bool value) => setField<bool>('is_published', value);

  DateTime? get datePublished => getField<DateTime>('date_published');
  set datePublished(DateTime? value) =>
      setField<DateTime>('date_published', value);

  String get filenameRecorded => getField<String>('filename_recorded')!;
  set filenameRecorded(String value) =>
      setField<String>('filename_recorded', value);

  int get numViews => getField<int>('num_views')!;
  set numViews(int value) => setField<int>('num_views', value);

  int get numLikes => getField<int>('num_likes')!;
  set numLikes(int value) => setField<int>('num_likes', value);

  int? get midiaTypeId => getField<int>('midia_type_id');
  set midiaTypeId(int? value) => setField<int>('midia_type_id', value);

  List<int> get authors => getListField<int>('authors');
  set authors(List<int>? value) => setListField<int>('authors', value);

  String? get midiaFileUrl => getField<String>('midia_file_url');
  set midiaFileUrl(String? value) => setField<String>('midia_file_url', value);

  String? get embedding => getField<String>('embedding');
  set embedding(String? value) => setField<String>('embedding', value);

  String get transcript => getField<String>('transcript')!;
  set transcript(String value) => setField<String>('transcript', value);
}

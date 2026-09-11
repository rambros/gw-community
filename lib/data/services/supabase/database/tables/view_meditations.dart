import 'package:gw_community/data/services/supabase/database/database.dart';

class ViewMeditationsTable extends SupabaseTable<ViewMeditationsRow> {
  @override
  String get tableName => 'view_meditations';

  @override
  ViewMeditationsRow createRow(Map<String, dynamic> data) => ViewMeditationsRow(data);
}

class ViewMeditationsRow extends SupabaseDataRow {
  ViewMeditationsRow(super.data);

  @override
  SupabaseTable get table => ViewMeditationsTable();

  int? get contentId => getField<int>('content_id');
  set contentId(int? value) => setField<int>('content_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  int? get contentTypeId => getField<int>('content_type_id');
  set contentTypeId(int? value) => setField<int>('content_type_id', value);

  String? get midiaType => getField<String>('midia_type');
  set midiaType(String? value) => setField<String>('midia_type', value);

  List<String> get authorsNames => getListField<String>('authors_names');
  set authorsNames(List<String>? value) => setListField<String>('authors_names', value);

  int? get cottEventId => getField<int>('cott_event_id');
  set cottEventId(int? value) => setField<int>('cott_event_id', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);

  String? get audioUrl => getField<String>('audio_url');
  set audioUrl(String? value) => setField<String>('audio_url', value);

  String? get midiaFileUrl => getField<String>('midia_file_url');
  set midiaFileUrl(String? value) => setField<String>('midia_file_url', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  String? get transcript => getField<String>('transcript');
  set transcript(String? value) => setField<String>('transcript', value);

  bool? get isPublished => getField<bool>('is_published');
  set isPublished(bool? value) => setField<bool>('is_published', value);

  DateTime? get datePublished => getField<DateTime>('date_published');
  set datePublished(DateTime? value) => setField<DateTime>('date_published', value);

  double? get yearPublished => getField<double>('year_published');
  set yearPublished(double? value) => setField<double>('year_published', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get contentSearchString => getField<String>('content_search_string');
  set contentSearchString(String? value) => setField<String>('content_search_string', value);
}

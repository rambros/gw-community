import '../database.dart';

class ViewContentTable extends SupabaseTable<ViewContentRow> {
  @override
  String get tableName => 'view_content';

  @override
  ViewContentRow createRow(Map<String, dynamic> data) => ViewContentRow(data);
}

class ViewContentRow extends SupabaseDataRow {
  ViewContentRow(super.data);

  @override
  SupabaseTable get table => ViewContentTable();

  int? get contentId => getField<int>('content_id');
  set contentId(int? value) => setField<int>('content_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get contentType => getField<String>('content_type');
  set contentType(String? value) => setField<String>('content_type', value);

  int? get contentTypeId => getField<int>('content_type_id');
  set contentTypeId(int? value) => setField<int>('content_type_id', value);

  String? get midiaType => getField<String>('midia_type');
  set midiaType(String? value) => setField<String>('midia_type', value);

  int? get midiaTypeId => getField<int>('midia_type_id');
  set midiaTypeId(int? value) => setField<int>('midia_type_id', value);

  List<int> get authors => getListField<int>('authors');
  set authors(List<int>? value) => setListField<int>('authors', value);

  List<String> get authorsNames => getListField<String>('authors_names');
  set authorsNames(List<String>? value) =>
      setListField<String>('authors_names', value);

  List<int> get topics => getListField<int>('topics');
  set topics(List<int>? value) => setListField<int>('topics', value);

  List<String> get topicsNames => getListField<String>('topics_names');
  set topicsNames(List<String>? value) =>
      setListField<String>('topics_names', value);

  int? get cottEventId => getField<int>('cott_event_id');
  set cottEventId(int? value) => setField<int>('cott_event_id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  int? get localId => getField<int>('local_id');
  set localId(int? value) => setField<int>('local_id', value);

  int? get eventTypeId => getField<int>('event_type_id');
  set eventTypeId(int? value) => setField<int>('event_type_id', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);

  String? get audioDuration => getField<String>('audio_duration');
  set audioDuration(String? value) => setField<String>('audio_duration', value);

  String? get audioUrl => getField<String>('audio_url');
  set audioUrl(String? value) => setField<String>('audio_url', value);

  String? get filenameSelected => getField<String>('filename_selected');
  set filenameSelected(String? value) =>
      setField<String>('filename_selected', value);

  String? get filenameRecorded => getField<String>('filename_recorded');
  set filenameRecorded(String? value) =>
      setField<String>('filename_recorded', value);

  String? get midiaFileUrl => getField<String>('midia_file_url');
  set midiaFileUrl(String? value) => setField<String>('midia_file_url', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  String? get transcript => getField<String>('transcript');
  set transcript(String? value) => setField<String>('transcript', value);

  bool? get isPublished => getField<bool>('is_published');
  set isPublished(bool? value) => setField<bool>('is_published', value);

  DateTime? get datePublished => getField<DateTime>('date_published');
  set datePublished(DateTime? value) =>
      setField<DateTime>('date_published', value);

  double? get yearPublished => getField<double>('year_published');
  set yearPublished(double? value) => setField<double>('year_published', value);

  int? get numLikes => getField<int>('num_likes');
  set numLikes(int? value) => setField<int>('num_likes', value);

  int? get numViews => getField<int>('num_views');
  set numViews(int? value) => setField<int>('num_views', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get contentSearchString => getField<String>('content_search_string');
  set contentSearchString(String? value) =>
      setField<String>('content_search_string', value);

  String? get embedding => getField<String>('embedding');
  set embedding(String? value) => setField<String>('embedding', value);
}

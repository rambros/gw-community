import '../database.dart';

class CcEventsTable extends SupabaseTable<CcEventsRow> {
  @override
  String get tableName => 'cc_events';

  @override
  CcEventsRow createRow(Map<String, dynamic> data) => CcEventsRow(data);
}

class CcEventsRow extends SupabaseDataRow {
  CcEventsRow(super.data);

  @override
  SupabaseTable get table => CcEventsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get facilitatorId => getField<String>('facilitator_id');
  set facilitatorId(String? value) => setField<String>('facilitator_id', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  DateTime? get eventDate => getField<DateTime>('event_date');
  set eventDate(DateTime? value) => setField<DateTime>('event_date', value);

  int? get duration => getField<int>('duration');
  set duration(int? value) => setField<int>('duration', value);

  String? get eventImageUrl => getField<String>('event_image_url');
  set eventImageUrl(String? value) =>
      setField<String>('event_image_url', value);

  String? get eventAudioUrl => getField<String>('event_audio_url');
  set eventAudioUrl(String? value) =>
      setField<String>('event_audio_url', value);

  String? get eventVideoUrl => getField<String>('event_video_url');
  set eventVideoUrl(String? value) =>
      setField<String>('event_video_url', value);

  String? get eventPageUrl => getField<String>('event_page_url');
  set eventPageUrl(String? value) => setField<String>('event_page_url', value);

  String? get eventStatus => getField<String>('event_status');
  set eventStatus(String? value) => setField<String>('event_status', value);

  DateTime get dateCreated => getField<DateTime>('date_created')!;
  set dateCreated(DateTime value) => setField<DateTime>('date_created', value);

  String? get facilitatorName => getField<String>('facilitator_name');
  set facilitatorName(String? value) =>
      setField<String>('facilitator_name', value);

  bool? get userRegistered => getField<bool>('user_registered');
  set userRegistered(bool? value) => setField<bool>('user_registered', value);

  PostgresTime? get eventTime => getField<PostgresTime>('event_time');
  set eventTime(PostgresTime? value) =>
      setField<PostgresTime>('event_time', value);

  String? get visibility => getField<String>('visibility');
  set visibility(String? value) => setField<String>('visibility', value);
}

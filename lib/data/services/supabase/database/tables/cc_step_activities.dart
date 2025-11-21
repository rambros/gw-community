import '../database.dart';

class CcStepActivitiesTable extends SupabaseTable<CcStepActivitiesRow> {
  @override
  String get tableName => 'cc_step_activities';

  @override
  CcStepActivitiesRow createRow(Map<String, dynamic> data) =>
      CcStepActivitiesRow(data);
}

class CcStepActivitiesRow extends SupabaseDataRow {
  CcStepActivitiesRow(super.data);

  @override
  SupabaseTable get table => CcStepActivitiesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get stepId => getField<int>('step_id');
  set stepId(int? value) => setField<int>('step_id', value);

  int? get orderInStep => getField<int>('order_in_step');
  set orderInStep(int? value) => setField<int>('order_in_step', value);

  String? get activityPrompt => getField<String>('activity_prompt');
  set activityPrompt(String? value) =>
      setField<String>('activity_prompt', value);

  String? get activityType => getField<String>('activity_type');
  set activityType(String? value) => setField<String>('activity_type', value);

  String? get activityLabel => getField<String>('activity_label');
  set activityLabel(String? value) => setField<String>('activity_label', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  String? get audioUrl => getField<String>('audio_url');
  set audioUrl(String? value) => setField<String>('audio_url', value);

  String? get audioFilename => getField<String>('audio_filename');
  set audioFilename(String? value) => setField<String>('audio_filename', value);

  String? get audioDuration => getField<String>('audio_duration');
  set audioDuration(String? value) => setField<String>('audio_duration', value);

  String? get videoUrl => getField<String>('video_url');
  set videoUrl(String? value) => setField<String>('video_url', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get journal => getField<String>('journal');
  set journal(String? value) => setField<String>('journal', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserActivitiesTable extends SupabaseTable<CcViewUserActivitiesRow> {
  @override
  String get tableName => 'cc_view_user_activities';

  @override
  CcViewUserActivitiesRow createRow(Map<String, dynamic> data) =>
      CcViewUserActivitiesRow(data);
}

class CcViewUserActivitiesRow extends SupabaseDataRow {
  CcViewUserActivitiesRow(super.data);

  @override
  SupabaseTable get table => CcViewUserActivitiesTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  int? get userStepId => getField<int>('user_step_id');
  set userStepId(int? value) => setField<int>('user_step_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get activityLabel => getField<String>('activity_label');
  set activityLabel(String? value) => setField<String>('activity_label', value);

  String? get activityPrompt => getField<String>('activity_prompt');
  set activityPrompt(String? value) =>
      setField<String>('activity_prompt', value);

  String? get activityType => getField<String>('activity_type');
  set activityType(String? value) => setField<String>('activity_type', value);

  String? get audioUrl => getField<String>('audio_url');
  set audioUrl(String? value) => setField<String>('audio_url', value);

  String? get journal => getField<String>('journal');
  set journal(String? value) => setField<String>('journal', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  int? get orderInStep => getField<int>('order_in_step');
  set orderInStep(int? value) => setField<int>('order_in_step', value);

  DateTime? get dateStarted => getField<DateTime>('date_started');
  set dateStarted(DateTime? value) => setField<DateTime>('date_started', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  String? get activityStatus => getField<String>('activity_status');
  set activityStatus(String? value) =>
      setField<String>('activity_status', value);

  String? get journalSaved => getField<String>('journal_saved');
  set journalSaved(String? value) => setField<String>('journal_saved', value);

  int? get stepActivityId => getField<int>('step_activity_id');
  set stepActivityId(int? value) => setField<int>('step_activity_id', value);
}

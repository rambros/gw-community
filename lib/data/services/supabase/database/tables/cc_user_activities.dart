import 'package:gw_community/data/services/supabase/database/database.dart';

class CcUserActivitiesTable extends SupabaseTable<CcUserActivitiesRow> {
  @override
  String get tableName => 'cc_user_activities';

  @override
  CcUserActivitiesRow createRow(Map<String, dynamic> data) =>
      CcUserActivitiesRow(data);
}

class CcUserActivitiesRow extends SupabaseDataRow {
  CcUserActivitiesRow(super.data);

  @override
  SupabaseTable get table => CcUserActivitiesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get stepActivityId => getField<int>('step_activity_id');
  set stepActivityId(int? value) => setField<int>('step_activity_id', value);

  int? get userStepId => getField<int>('user_step_id');
  set userStepId(int? value) => setField<int>('user_step_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get dateStarted => getField<DateTime>('date_started');
  set dateStarted(DateTime? value) => setField<DateTime>('date_started', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  String? get activityStatus => getField<String>('activity_status');
  set activityStatus(String? value) =>
      setField<String>('activity_status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get journalSaved => getField<String>('journal_saved');
  set journalSaved(String? value) => setField<String>('journal_saved', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcUserStepsTable extends SupabaseTable<CcUserStepsRow> {
  @override
  String get tableName => 'cc_user_steps';

  @override
  CcUserStepsRow createRow(Map<String, dynamic> data) => CcUserStepsRow(data);
}

class CcUserStepsRow extends SupabaseDataRow {
  CcUserStepsRow(super.data);

  @override
  SupabaseTable get table => CcUserStepsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get userJourneyId => getField<int>('user_journey_id');
  set userJourneyId(int? value) => setField<int>('user_journey_id', value);

  int? get journeyStepId => getField<int>('journey_step_id');
  set journeyStepId(int? value) => setField<int>('journey_step_id', value);

  DateTime? get dateStarted => getField<DateTime>('date_started');
  set dateStarted(DateTime? value) => setField<DateTime>('date_started', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  String? get stepStatus => getField<String>('step_status');
  set stepStatus(String? value) => setField<String>('step_status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}

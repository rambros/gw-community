import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserStepsTable extends SupabaseTable<CcViewUserStepsRow> {
  @override
  String get tableName => 'cc_view_user_steps';

  @override
  CcViewUserStepsRow createRow(Map<String, dynamic> data) =>
      CcViewUserStepsRow(data);
}

class CcViewUserStepsRow extends SupabaseDataRow {
  CcViewUserStepsRow(super.data);

  @override
  SupabaseTable get table => CcViewUserStepsTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  int? get userJourneyId => getField<int>('user_journey_id');
  set userJourneyId(int? value) => setField<int>('user_journey_id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  int? get stepNumber => getField<int>('step_number');
  set stepNumber(int? value) => setField<int>('step_number', value);

  DateTime? get dateStarted => getField<DateTime>('date_started');
  set dateStarted(DateTime? value) => setField<DateTime>('date_started', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  String? get stepStatus => getField<String>('step_status');
  set stepStatus(String? value) => setField<String>('step_status', value);

  int? get journeyStepId => getField<int>('journey_step_id');
  set journeyStepId(int? value) => setField<int>('journey_step_id', value);
}

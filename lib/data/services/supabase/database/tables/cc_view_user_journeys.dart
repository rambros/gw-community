import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserJourneysTable extends SupabaseTable<CcViewUserJourneysRow> {
  @override
  String get tableName => 'cc_view_user_journeys';

  @override
  CcViewUserJourneysRow createRow(Map<String, dynamic> data) =>
      CcViewUserJourneysRow(data);
}

class CcViewUserJourneysRow extends SupabaseDataRow {
  CcViewUserJourneysRow(super.data);

  @override
  SupabaseTable get table => CcViewUserJourneysTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  int? get stepsTotal => getField<int>('steps_total');
  set stepsTotal(int? value) => setField<int>('steps_total', value);

  int? get stepsCompleted => getField<int>('steps_completed');
  set stepsCompleted(int? value) => setField<int>('steps_completed', value);

  DateTime? get lastAccessDate => getField<DateTime>('last_access_date');
  set lastAccessDate(DateTime? value) =>
      setField<DateTime>('last_access_date', value);

  String? get journeyStatus => getField<String>('journey_status');
  set journeyStatus(String? value) => setField<String>('journey_status', value);

  bool get enableDateControl => getField<bool>('enable_date_control') ?? true;
  set enableDateControl(bool value) => setField<bool>('enable_date_control', value);

  int get daysToWaitBetweenSteps => getField<int>('days_to_wait_between_steps') ?? 1;
  set daysToWaitBetweenSteps(int value) => setField<int>('days_to_wait_between_steps', value);
}

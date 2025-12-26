import 'package:gw_community/data/services/supabase/database/database.dart';

class CcUserJourneysTable extends SupabaseTable<CcUserJourneysRow> {
  @override
  String get tableName => 'cc_user_journeys';

  @override
  CcUserJourneysRow createRow(Map<String, dynamic> data) =>
      CcUserJourneysRow(data);
}

class CcUserJourneysRow extends SupabaseDataRow {
  CcUserJourneysRow(super.data);

  @override
  SupabaseTable get table => CcUserJourneysTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  DateTime? get dateStarted => getField<DateTime>('date_started');
  set dateStarted(DateTime? value) => setField<DateTime>('date_started', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  DateTime? get lastAccessDate => getField<DateTime>('last_access_date');
  set lastAccessDate(DateTime? value) =>
      setField<DateTime>('last_access_date', value);

  int? get stepsCompleted => getField<int>('steps_completed');
  set stepsCompleted(int? value) => setField<int>('steps_completed', value);

  String? get journeyStatus => getField<String>('journey_status');
  set journeyStatus(String? value) => setField<String>('journey_status', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);
}

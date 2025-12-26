import 'package:gw_community/data/services/supabase/database/database.dart';

class CcJourneyStepsTable extends SupabaseTable<CcJourneyStepsRow> {
  @override
  String get tableName => 'cc_journey_steps';

  @override
  CcJourneyStepsRow createRow(Map<String, dynamic> data) =>
      CcJourneyStepsRow(data);
}

class CcJourneyStepsRow extends SupabaseDataRow {
  CcJourneyStepsRow(super.data);

  @override
  SupabaseTable get table => CcJourneyStepsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get journeyId => getField<int>('journey_id');
  set journeyId(int? value) => setField<int>('journey_id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get stepLabel => getField<String>('step_label');
  set stepLabel(String? value) => setField<String>('step_label', value);

  int get stepNumber => getField<int>('step_number')!;
  set stepNumber(int value) => setField<int>('step_number', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}

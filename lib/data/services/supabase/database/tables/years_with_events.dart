import 'package:gw_community/data/services/supabase/database/database.dart';

class YearsWithEventsTable extends SupabaseTable<YearsWithEventsRow> {
  @override
  String get tableName => 'years_with_events';

  @override
  YearsWithEventsRow createRow(Map<String, dynamic> data) =>
      YearsWithEventsRow(data);
}

class YearsWithEventsRow extends SupabaseDataRow {
  YearsWithEventsRow(super.data);

  @override
  SupabaseTable get table => YearsWithEventsTable();

  String? get year => getField<String>('year');
  set year(String? value) => setField<String>('year', value);
}

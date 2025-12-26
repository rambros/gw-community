import 'package:gw_community/data/services/supabase/database/database.dart';

class YearsWithContentTable extends SupabaseTable<YearsWithContentRow> {
  @override
  String get tableName => 'years_with_content';

  @override
  YearsWithContentRow createRow(Map<String, dynamic> data) =>
      YearsWithContentRow(data);
}

class YearsWithContentRow extends SupabaseDataRow {
  YearsWithContentRow(super.data);

  @override
  SupabaseTable get table => YearsWithContentTable();

  double? get year => getField<double>('year');
  set year(double? value) => setField<double>('year', value);
}

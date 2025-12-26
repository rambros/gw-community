import 'package:gw_community/data/services/supabase/database/database.dart';

class YearsWithContentPublishedTable
    extends SupabaseTable<YearsWithContentPublishedRow> {
  @override
  String get tableName => 'years_with_content_published';

  @override
  YearsWithContentPublishedRow createRow(Map<String, dynamic> data) =>
      YearsWithContentPublishedRow(data);
}

class YearsWithContentPublishedRow extends SupabaseDataRow {
  YearsWithContentPublishedRow(super.data);

  @override
  SupabaseTable get table => YearsWithContentPublishedTable();

  double? get year => getField<double>('year');
  set year(double? value) => setField<double>('year', value);
}

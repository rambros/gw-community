import 'package:gw_community/data/services/supabase/database/database.dart';

class CcRegionTable extends SupabaseTable<CcRegionRow> {
  @override
  String get tableName => 'cc_region';

  @override
  CcRegionRow createRow(Map<String, dynamic> data) => CcRegionRow(data);
}

class CcRegionRow extends SupabaseDataRow {
  CcRegionRow(super.data);

  @override
  SupabaseTable get table => CcRegionTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get regionName => getField<String>('region_name');
  set regionName(String? value) => setField<String>('region_name', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcCountryTable extends SupabaseTable<CcCountryRow> {
  @override
  String get tableName => 'cc_country';

  @override
  CcCountryRow createRow(Map<String, dynamic> data) => CcCountryRow(data);
}

class CcCountryRow extends SupabaseDataRow {
  CcCountryRow(super.data);

  @override
  SupabaseTable get table => CcCountryTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get countryName => getField<String>('country_name')!;
  set countryName(String value) => setField<String>('country_name', value);
}

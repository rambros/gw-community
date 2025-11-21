import '../database.dart';

class ViewLocationTable extends SupabaseTable<ViewLocationRow> {
  @override
  String get tableName => 'view_location';

  @override
  ViewLocationRow createRow(Map<String, dynamic> data) => ViewLocationRow(data);
}

class ViewLocationRow extends SupabaseDataRow {
  ViewLocationRow(super.data);

  @override
  SupabaseTable get table => ViewLocationTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get location => getField<String>('location');
  set location(String? value) => setField<String>('location', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  bool? get forOnline => getField<bool>('for_online');
  set forOnline(bool? value) => setField<bool>('for_online', value);

  String? get locationSearchString =>
      getField<String>('location_search_string');
  set locationSearchString(String? value) =>
      setField<String>('location_search_string', value);
}

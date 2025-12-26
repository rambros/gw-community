import 'package:gw_community/data/services/supabase/database/database.dart';

class CottEventTable extends SupabaseTable<CottEventRow> {
  @override
  String get tableName => 'cott_event';

  @override
  CottEventRow createRow(Map<String, dynamic> data) => CottEventRow(data);
}

class CottEventRow extends SupabaseDataRow {
  CottEventRow(super.data);

  @override
  SupabaseTable get table => CottEventTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get theme => getField<String>('theme')!;
  set theme(String value) => setField<String>('theme', value);

  List<int> get speakers => getListField<int>('speakers');
  set speakers(List<int>? value) => setListField<int>('speakers', value);

  String get year => getField<String>('year')!;
  set year(String value) => setField<String>('year', value);

  DateTime? get startDate => getField<DateTime>('start_date');
  set startDate(DateTime? value) => setField<DateTime>('start_date', value);

  DateTime? get endDate => getField<DateTime>('end_date');
  set endDate(DateTime? value) => setField<DateTime>('end_date', value);

  String get imageUrl => getField<String>('image_url')!;
  set imageUrl(String value) => setField<String>('image_url', value);

  int get eventTypeId => getField<int>('event_type_id')!;
  set eventTypeId(int value) => setField<int>('event_type_id', value);

  int? get localId => getField<int>('local_id');
  set localId(int? value) => setField<int>('local_id', value);
}

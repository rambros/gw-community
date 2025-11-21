import '../database.dart';

class LocalWithEventTable extends SupabaseTable<LocalWithEventRow> {
  @override
  String get tableName => 'local_with_event';

  @override
  LocalWithEventRow createRow(Map<String, dynamic> data) =>
      LocalWithEventRow(data);
}

class LocalWithEventRow extends SupabaseDataRow {
  LocalWithEventRow(super.data);

  @override
  SupabaseTable get table => LocalWithEventTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get local => getField<String>('local');
  set local(String? value) => setField<String>('local', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  bool? get forOnline => getField<bool>('for_online');
  set forOnline(bool? value) => setField<bool>('for_online', value);

  bool? get hasEvent => getField<bool>('has_event');
  set hasEvent(bool? value) => setField<bool>('has_event', value);
}

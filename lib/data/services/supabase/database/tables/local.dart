import 'package:gw_community/data/services/supabase/database/database.dart';

class LocalTable extends SupabaseTable<LocalRow> {
  @override
  String get tableName => 'local';

  @override
  LocalRow createRow(Map<String, dynamic> data) => LocalRow(data);
}

class LocalRow extends SupabaseDataRow {
  LocalRow(super.data);

  @override
  SupabaseTable get table => LocalTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get local => getField<String>('local')!;
  set local(String value) => setField<String>('local', value);

  String get region => getField<String>('region')!;
  set region(String value) => setField<String>('region', value);

  bool get forOnline => getField<bool>('for_online')!;
  set forOnline(bool value) => setField<bool>('for_online', value);
}

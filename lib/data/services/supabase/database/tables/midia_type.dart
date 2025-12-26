import 'package:gw_community/data/services/supabase/database/database.dart';

class MidiaTypeTable extends SupabaseTable<MidiaTypeRow> {
  @override
  String get tableName => 'midia_type';

  @override
  MidiaTypeRow createRow(Map<String, dynamic> data) => MidiaTypeRow(data);
}

class MidiaTypeRow extends SupabaseDataRow {
  MidiaTypeRow(super.data);

  @override
  SupabaseTable get table => MidiaTypeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get midiaType => getField<String>('midia_type')!;
  set midiaType(String value) => setField<String>('midia_type', value);
}

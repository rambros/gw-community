import '../database.dart';

class ContentTypeTable extends SupabaseTable<ContentTypeRow> {
  @override
  String get tableName => 'content_type';

  @override
  ContentTypeRow createRow(Map<String, dynamic> data) => ContentTypeRow(data);
}

class ContentTypeRow extends SupabaseDataRow {
  ContentTypeRow(super.data);

  @override
  SupabaseTable get table => ContentTypeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get midiaTypeEnum => getField<String>('midia_type_enum')!;
  set midiaTypeEnum(String value) => setField<String>('midia_type_enum', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class AuthorTable extends SupabaseTable<AuthorRow> {
  @override
  String get tableName => 'author';

  @override
  AuthorRow createRow(Map<String, dynamic> data) => AuthorRow(data);
}

class AuthorRow extends SupabaseDataRow {
  AuthorRow(super.data);

  @override
  SupabaseTable get table => AuthorTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get name => getField<String>('name')!;
  set name(String value) => setField<String>('name', value);

  String get info => getField<String>('info')!;
  set info(String value) => setField<String>('info', value);

  String get photo => getField<String>('photo')!;
  set photo(String value) => setField<String>('photo', value);
}

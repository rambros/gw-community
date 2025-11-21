import '../database.dart';

class AuthorWithContentTable extends SupabaseTable<AuthorWithContentRow> {
  @override
  String get tableName => 'author_with_content';

  @override
  AuthorWithContentRow createRow(Map<String, dynamic> data) =>
      AuthorWithContentRow(data);
}

class AuthorWithContentRow extends SupabaseDataRow {
  AuthorWithContentRow(super.data);

  @override
  SupabaseTable get table => AuthorWithContentTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  bool? get hasContent => getField<bool>('has_content');
  set hasContent(bool? value) => setField<bool>('has_content', value);
}

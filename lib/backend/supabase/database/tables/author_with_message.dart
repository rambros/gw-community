import '../database.dart';

class AuthorWithMessageTable extends SupabaseTable<AuthorWithMessageRow> {
  @override
  String get tableName => 'author_with_message';

  @override
  AuthorWithMessageRow createRow(Map<String, dynamic> data) =>
      AuthorWithMessageRow(data);
}

class AuthorWithMessageRow extends SupabaseDataRow {
  AuthorWithMessageRow(super.data);

  @override
  SupabaseTable get table => AuthorWithMessageTable();

  int? get authorId => getField<int>('author_id');
  set authorId(int? value) => setField<int>('author_id', value);

  String? get authorName => getField<String>('author_name');
  set authorName(String? value) => setField<String>('author_name', value);
}

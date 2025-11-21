import '../database.dart';

class AuthorEventTable extends SupabaseTable<AuthorEventRow> {
  @override
  String get tableName => 'author_event';

  @override
  AuthorEventRow createRow(Map<String, dynamic> data) => AuthorEventRow(data);
}

class AuthorEventRow extends SupabaseDataRow {
  AuthorEventRow(super.data);

  @override
  SupabaseTable get table => AuthorEventTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get authorId => getField<int>('author_id');
  set authorId(int? value) => setField<int>('author_id', value);

  int? get cottEventId => getField<int>('cott_event_id');
  set cottEventId(int? value) => setField<int>('cott_event_id', value);
}

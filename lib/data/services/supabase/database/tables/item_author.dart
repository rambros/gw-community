import 'package:gw_community/data/services/supabase/database/database.dart';

class ItemAuthorTable extends SupabaseTable<ItemAuthorRow> {
  @override
  String get tableName => 'item_author';

  @override
  ItemAuthorRow createRow(Map<String, dynamic> data) => ItemAuthorRow(data);
}

class ItemAuthorRow extends SupabaseDataRow {
  ItemAuthorRow(super.data);

  @override
  SupabaseTable get table => ItemAuthorTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get itemId => getField<int>('item_id')!;
  set itemId(int value) => setField<int>('item_id', value);

  int get authorId => getField<int>('author_id')!;
  set authorId(int value) => setField<int>('author_id', value);
}

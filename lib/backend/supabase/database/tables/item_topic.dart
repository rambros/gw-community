import '../database.dart';

class ItemTopicTable extends SupabaseTable<ItemTopicRow> {
  @override
  String get tableName => 'item_topic';

  @override
  ItemTopicRow createRow(Map<String, dynamic> data) => ItemTopicRow(data);
}

class ItemTopicRow extends SupabaseDataRow {
  ItemTopicRow(super.data);

  @override
  SupabaseTable get table => ItemTopicTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int? get topicId => getField<int>('topic_id');
  set topicId(int? value) => setField<int>('topic_id', value);

  int? get itemId => getField<int>('item_id');
  set itemId(int? value) => setField<int>('item_id', value);
}

import '../database.dart';

class TopicTable extends SupabaseTable<TopicRow> {
  @override
  String get tableName => 'topic';

  @override
  TopicRow createRow(Map<String, dynamic> data) => TopicRow(data);
}

class TopicRow extends SupabaseDataRow {
  TopicRow(super.data);

  @override
  SupabaseTable get table => TopicTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String get topicName => getField<String>('topic_name')!;
  set topicName(String value) => setField<String>('topic_name', value);

  String get description => getField<String>('description')!;
  set description(String value) => setField<String>('description', value);
}

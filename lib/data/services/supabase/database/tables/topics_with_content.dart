import '../database.dart';

class TopicsWithContentTable extends SupabaseTable<TopicsWithContentRow> {
  @override
  String get tableName => 'topics_with_content';

  @override
  TopicsWithContentRow createRow(Map<String, dynamic> data) =>
      TopicsWithContentRow(data);
}

class TopicsWithContentRow extends SupabaseDataRow {
  TopicsWithContentRow(super.data);

  @override
  SupabaseTable get table => TopicsWithContentTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get topicName => getField<String>('topic_name');
  set topicName(String? value) => setField<String>('topic_name', value);
}

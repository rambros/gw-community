import '../database.dart';

class EventTypeTable extends SupabaseTable<EventTypeRow> {
  @override
  String get tableName => 'event_type';

  @override
  EventTypeRow createRow(Map<String, dynamic> data) => EventTypeRow(data);
}

class EventTypeRow extends SupabaseDataRow {
  EventTypeRow(super.data);

  @override
  SupabaseTable get table => EventTypeTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  int? get dashboardGroupId => getField<int>('dashboard_group_id');
  set dashboardGroupId(int? value) =>
      setField<int>('dashboard_group_id', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class DashboardGroupTable extends SupabaseTable<DashboardGroupRow> {
  @override
  String get tableName => 'dashboard_group';

  @override
  DashboardGroupRow createRow(Map<String, dynamic> data) =>
      DashboardGroupRow(data);
}

class DashboardGroupRow extends SupabaseDataRow {
  DashboardGroupRow(super.data);

  @override
  SupabaseTable get table => DashboardGroupTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);
}

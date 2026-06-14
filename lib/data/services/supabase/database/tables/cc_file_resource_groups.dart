import 'package:gw_community/data/services/supabase/database/database.dart';

class CcFileResourceGroupsTable
    extends SupabaseTable<CcFileResourceGroupsRow> {
  @override
  String get tableName => 'cc_file_resource_groups';

  @override
  CcFileResourceGroupsRow createRow(Map<String, dynamic> data) =>
      CcFileResourceGroupsRow(data);
}

class CcFileResourceGroupsRow extends SupabaseDataRow {
  CcFileResourceGroupsRow(super.data);

  @override
  SupabaseTable get table => CcFileResourceGroupsTable();

  int get id => getField<int>('id')!;

  int get resourceId => getField<int>('resource_id')!;
  set resourceId(int value) => setField<int>('resource_id', value);

  int get groupId => getField<int>('group_id')!;
  set groupId(int value) => setField<int>('group_id', value);

  String? get addedBy => getField<String>('added_by');
  set addedBy(String? value) => setField<String>('added_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcGroupMembersTable extends SupabaseTable<CcGroupMembersRow> {
  @override
  String get tableName => 'cc_group_members';

  @override
  CcGroupMembersRow createRow(Map<String, dynamic> data) =>
      CcGroupMembersRow(data);
}

class CcGroupMembersRow extends SupabaseDataRow {
  CcGroupMembersRow(super.data);

  @override
  SupabaseTable get table => CcGroupMembersTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userRole => getField<String>('user_role');
  set userRole(String? value) => setField<String>('user_role', value);
}

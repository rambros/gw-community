import '../database.dart';

class CcViewGroupFacilitatorsTable
    extends SupabaseTable<CcViewGroupFacilitatorsRow> {
  @override
  String get tableName => 'cc_view_group_facilitators';

  @override
  CcViewGroupFacilitatorsRow createRow(Map<String, dynamic> data) =>
      CcViewGroupFacilitatorsRow(data);
}

class CcViewGroupFacilitatorsRow extends SupabaseDataRow {
  CcViewGroupFacilitatorsRow(super.data);

  @override
  SupabaseTable get table => CcViewGroupFacilitatorsTable();

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  List<String> get managerNames => getListField<String>('manager_names');
  set managerNames(List<String>? value) =>
      setListField<String>('manager_names', value);
}

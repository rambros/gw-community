import 'package:gw_community/data/services/supabase/database/database.dart';

class CcCommentsTable extends SupabaseTable<CcCommentsRow> {
  @override
  String get tableName => 'cc_comments';

  @override
  CcCommentsRow createRow(Map<String, dynamic> data) => CcCommentsRow(data);
}

class CcCommentsRow extends SupabaseDataRow {
  CcCommentsRow(super.data);

  @override
  SupabaseTable get table => CcCommentsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  int? get parentId => getField<int>('parent_id');
  set parentId(int? value) => setField<int>('parent_id', value);

  int? get sharingId => getField<int>('sharing_id');
  set sharingId(int? value) => setField<int>('sharing_id', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewOrderedCommentsTable extends SupabaseTable<CcViewOrderedCommentsRow> {
  @override
  String get tableName => 'cc_view_ordered_comments';

  @override
  CcViewOrderedCommentsRow createRow(Map<String, dynamic> data) => CcViewOrderedCommentsRow(data);
}

class CcViewOrderedCommentsRow extends SupabaseDataRow {
  CcViewOrderedCommentsRow(super.data);

  @override
  SupabaseTable get table => CcViewOrderedCommentsTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  int? get parentId => getField<int>('parent_id');
  set parentId(int? value) => setField<int>('parent_id', value);

  int? get rootId => getField<int>('root_id');
  set rootId(int? value) => setField<int>('root_id', value);

  int? get depth => getField<int>('depth');
  set depth(int? value) => setField<int>('depth', value);

  int? get sharingId => getField<int>('sharing_id');
  set sharingId(int? value) => setField<int>('sharing_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  String? get content => getField<String>('content');
  set content(String? value) => setField<String>('content', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get sortPath => getField<String>('sort_path');
  set sortPath(String? value) => setField<String>('sort_path', value);
}

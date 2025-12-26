import 'package:gw_community/data/services/supabase/database/database.dart';

class CcChatsTable extends SupabaseTable<CcChatsRow> {
  @override
  String get tableName => 'cc_chats';

  @override
  CcChatsRow createRow(Map<String, dynamic> data) => CcChatsRow(data);
}

class CcChatsRow extends SupabaseDataRow {
  CcChatsRow(super.data);

  @override
  SupabaseTable get table => CcChatsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  List<String> get userIds => getListField<String>('user_ids');
  set userIds(List<String>? value) => setListField<String>('user_ids', value);

  List<String> get userNames => getListField<String>('user_names');
  set userNames(List<String>? value) =>
      setListField<String>('user_names', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}

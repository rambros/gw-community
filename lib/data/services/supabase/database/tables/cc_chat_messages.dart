import 'package:gw_community/data/services/supabase/database/database.dart';

class CcChatMessagesTable extends SupabaseTable<CcChatMessagesRow> {
  @override
  String get tableName => 'cc_chat_messages';

  @override
  CcChatMessagesRow createRow(Map<String, dynamic> data) =>
      CcChatMessagesRow(data);
}

class CcChatMessagesRow extends SupabaseDataRow {
  CcChatMessagesRow(super.data);

  @override
  SupabaseTable get table => CcChatMessagesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get message => getField<String>('message');
  set message(String? value) => setField<String>('message', value);

  int? get chatId => getField<int>('chat_id');
  set chatId(int? value) => setField<int>('chat_id', value);
}

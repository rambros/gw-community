import 'package:gw_community/data/services/supabase/database/database.dart';

class CcNotificationsTable extends SupabaseTable<CcNotificationsRow> {
  @override
  String get tableName => 'cc_notifications';

  @override
  CcNotificationsRow createRow(Map<String, dynamic> data) =>
      CcNotificationsRow(data);
}

class CcNotificationsRow extends SupabaseDataRow {
  CcNotificationsRow(super.data);

  @override
  SupabaseTable get table => CcNotificationsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get message => getField<String>('message');
  set message(String? value) => setField<String>('message', value);

  bool get isRead => getField<bool>('is_read') ?? false;
  set isRead(bool value) => setField<bool>('is_read', value);

  String? get referenceType => getField<String>('reference_type');
  set referenceType(String? value) => setField<String>('reference_type', value);

  int? get referenceId => getField<int>('reference_id');
  set referenceId(int? value) => setField<int>('reference_id', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get readAt => getField<DateTime>('read_at');
  set readAt(DateTime? value) => setField<DateTime>('read_at', value);

  dynamic get metadata => getField<dynamic>('metadata');
  set metadata(dynamic value) => setField<dynamic>('metadata', value);
}

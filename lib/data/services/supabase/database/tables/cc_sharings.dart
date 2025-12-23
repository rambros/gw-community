import '../database.dart';

class CcSharingsTable extends SupabaseTable<CcSharingsRow> {
  @override
  String get tableName => 'cc_sharings';

  @override
  CcSharingsRow createRow(Map<String, dynamic> data) => CcSharingsRow(data);
}

class CcSharingsRow extends SupabaseDataRow {
  CcSharingsRow(super.data);

  @override
  SupabaseTable get table => CcSharingsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get privacy => getField<String>('privacy');
  set privacy(String? value) => setField<String>('privacy', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  bool get locked => getField<bool>('locked')!;
  set locked(bool value) => setField<bool>('locked', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get visibility => getField<String>('visibility');
  set visibility(String? value) => setField<String>('visibility', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get moderationStatus => getField<String>('moderation_status');
  set moderationStatus(String? value) =>
      setField<String>('moderation_status', value);

  String? get moderationReason => getField<String>('moderation_reason');
  set moderationReason(String? value) =>
      setField<String>('moderation_reason', value);

  String? get moderatedBy => getField<String>('moderated_by');
  set moderatedBy(String? value) => setField<String>('moderated_by', value);

  DateTime? get moderatedAt => getField<DateTime>('moderated_at');
  set moderatedAt(DateTime? value) =>
      setField<DateTime>('moderated_at', value);
}

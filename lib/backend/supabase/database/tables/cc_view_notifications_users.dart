import '../database.dart';

class CcViewNotificationsUsersTable
    extends SupabaseTable<CcViewNotificationsUsersRow> {
  @override
  String get tableName => 'cc_view_notifications_users';

  @override
  CcViewNotificationsUsersRow createRow(Map<String, dynamic> data) =>
      CcViewNotificationsUsersRow(data);
}

class CcViewNotificationsUsersRow extends SupabaseDataRow {
  CcViewNotificationsUsersRow(super.data);

  @override
  SupabaseTable get table => CcViewNotificationsUsersTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  String? get privacy => getField<String>('privacy');
  set privacy(String? value) => setField<String>('privacy', value);

  bool? get locked => getField<bool>('locked');
  set locked(bool? value) => setField<bool>('locked', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  String? get visibility => getField<String>('visibility');
  set visibility(String? value) => setField<String>('visibility', value);

  String? get groupName => getField<String>('group_name');
  set groupName(String? value) => setField<String>('group_name', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  int? get comments => getField<int>('comments');
  set comments(int? value) => setField<int>('comments', value);
}

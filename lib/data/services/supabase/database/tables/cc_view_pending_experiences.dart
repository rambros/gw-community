import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewPendingExperiencesTable extends SupabaseTable<CcViewPendingExperiencesRow> {
  @override
  String get tableName => 'cc_view_pending_experiences';

  @override
  CcViewPendingExperiencesRow createRow(Map<String, dynamic> data) => CcViewPendingExperiencesRow(data);
}

class CcViewPendingExperiencesRow extends SupabaseDataRow {
  CcViewPendingExperiencesRow(super.data);

  @override
  SupabaseTable get table => CcViewPendingExperiencesTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get text => getField<String>('text');
  set text(String? value) => setField<String>('text', value);

  String? get privacy => getField<String>('privacy');
  set privacy(String? value) => setField<String>('privacy', value);

  String? get visibility => getField<String>('visibility');
  set visibility(String? value) => setField<String>('visibility', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  bool? get locked => getField<bool>('locked');
  set locked(bool? value) => setField<bool>('locked', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get groupId => getField<int>('group_id');
  set groupId(int? value) => setField<int>('group_id', value);

  DateTime? get createdAt => getField<DateTime>('created_at');
  set createdAt(DateTime? value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get moderationStatus => getField<String>('moderation_status');
  set moderationStatus(String? value) => setField<String>('moderation_status', value);

  String? get moderationReason => getField<String>('moderation_reason');
  set moderationReason(String? value) => setField<String>('moderation_reason', value);

  String? get moderatedBy => getField<String>('moderated_by');
  set moderatedBy(String? value) => setField<String>('moderated_by', value);

  DateTime? get moderatedAt => getField<DateTime>('moderated_at');
  set moderatedAt(DateTime? value) => setField<DateTime>('moderated_at', value);

  String? get authorName => getField<String>('author_name');
  set authorName(String? value) => setField<String>('author_name', value);

  String? get authorDisplayName => getField<String>('author_display_name');
  set authorDisplayName(String? value) => setField<String>('author_display_name', value);

  String? get authorPhotoUrl => getField<String>('author_photo_url');
  set authorPhotoUrl(String? value) => setField<String>('author_photo_url', value);

  String? get authorEmail => getField<String>('author_email');
  set authorEmail(String? value) => setField<String>('author_email', value);

  String? get groupName => getField<String>('group_name');
  set groupName(String? value) => setField<String>('group_name', value);

  List<String> get groupManagers {
    final field = getField<dynamic>('group_managers');
    if (field == null) return [];
    if (field is List) return field.map((e) => e.toString()).toList();
    return [];
  }

  set groupManagers(List<String> value) => setField<List<String>>('group_managers', value);
}

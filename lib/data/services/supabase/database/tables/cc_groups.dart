import 'package:gw_community/data/services/supabase/database/database.dart';

class CcGroupsTable extends SupabaseTable<CcGroupsRow> {
  @override
  String get tableName => 'cc_groups';

  @override
  CcGroupsRow createRow(Map<String, dynamic> data) => CcGroupsRow(data);
}

class CcGroupsRow extends SupabaseDataRow {
  CcGroupsRow(super.data);

  @override
  SupabaseTable get table => CcGroupsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get name => getField<String>('name');
  set name(String? value) => setField<String>('name', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get groupPrivacy => getField<String>('group_privacy');
  set groupPrivacy(String? value) => setField<String>('group_privacy', value);

  String? get groupImageUrl => getField<String>('group_image_url');
  set groupImageUrl(String? value) => setField<String>('group_image_url', value);

  String? get welcomeMessage => getField<String>('welcome_message');
  set welcomeMessage(String? value) => setField<String>('welcome_message', value);

  String? get policyMessage => getField<String>('policy_message');
  set policyMessage(String? value) => setField<String>('policy_message', value);

  int? get numberMembers => getField<int>('number_members');
  set numberMembers(int? value) => setField<int>('number_members', value);

  // group_managers removed

  DateTime get dateCreated => getField<DateTime>('date_created')!;
  set dateCreated(DateTime value) => setField<DateTime>('date_created', value);

  // group_facilitators removed

  String? get groupStatus => getField<String>('group_status');
  set groupStatus(String? value) => setField<String>('group_status', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);
}

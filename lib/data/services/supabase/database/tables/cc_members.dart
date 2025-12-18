import '../database.dart';

class CcMembersTable extends SupabaseTable<CcMembersRow> {
  @override
  String get tableName => 'cc_members';

  @override
  CcMembersRow createRow(Map<String, dynamic> data) => CcMembersRow(data);
}

class CcMembersRow extends SupabaseDataRow {
  CcMembersRow(super.data);

  @override
  SupabaseTable get table => CcMembersTable();

  String get id => getField<String>('id')!;
  set id(String value) => setField<String>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  DateTime? get updatedAt => getField<DateTime>('updated_at');
  set updatedAt(DateTime? value) => setField<DateTime>('updated_at', value);

  String? get authUserId => getField<String>('auth_user_id');
  set authUserId(String? value) => setField<String>('auth_user_id', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get phone => getField<String>('phone');
  set phone(String? value) => setField<String>('phone', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  String? get bio => getField<String>('bio');
  set bio(String? value) => setField<String>('bio', value);

  String? get country => getField<String>('country');
  set country(String? value) => setField<String>('country', value);

  String? get language => getField<String>('language');
  set language(String? value) => setField<String>('language', value);

  String? get source => getField<String>('source');
  set source(String? value) => setField<String>('source', value);

  String? get participantId => getField<String>('participant_id');
  set participantId(String? value) => setField<String>('participant_id', value);

  String? get referredBy => getField<String>('referred_by');
  set referredBy(String? value) => setField<String>('referred_by', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  String? get membershipType => getField<String>('membership_type');
  set membershipType(String? value) => setField<String>('membership_type', value);

  DateTime? get lastAccess => getField<DateTime>('last_access');
  set lastAccess(DateTime? value) => setField<DateTime>('last_access', value);

  int? get totalJourneysStarted => getField<int>('total_journeys_started');
  set totalJourneysStarted(int? value) => setField<int>('total_journeys_started', value);

  int? get totalJourneysCompleted => getField<int>('total_journeys_completed');
  set totalJourneysCompleted(int? value) => setField<int>('total_journeys_completed', value);

  bool? get notificationsEnabled => getField<bool>('notifications_enabled');
  set notificationsEnabled(bool? value) => setField<bool>('notifications_enabled', value);

  bool? get emailNotifications => getField<bool>('email_notifications');
  set emailNotifications(bool? value) => setField<bool>('email_notifications', value);

  List<int> get startedJourneys => getListField<int>('started_journeys');
  set startedJourneys(List<int>? value) => setListField<int>('started_journeys', value);

  bool? get hideLastName => getField<bool>('hide_last_name');
  set hideLastName(bool? value) => setField<bool>('hide_last_name', value);

  List<String> get userRole => getListField<String>('user_role');
  set userRole(List<String>? value) => setListField<String>('user_role', value);
}

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

  String? get fullName => getField<String>('full_name');
  set fullName(String? value) => setField<String>('full_name', value);

  String? get email => getField<String>('email');
  set email(String? value) => setField<String>('email', value);

  String? get firstName => getField<String>('first_name');
  set firstName(String? value) => setField<String>('first_name', value);

  String? get lastName => getField<String>('last_name');
  set lastName(String? value) => setField<String>('last_name', value);

  bool? get hideLastName => getField<bool>('hide_last_name');
  set hideLastName(bool? value) => setField<bool>('hide_last_name', value);

  String? get displayName => getField<String>('display_name');
  set displayName(String? value) => setField<String>('display_name', value);

  String? get userStatus => getField<String>('user_status');
  set userStatus(String? value) => setField<String>('user_status', value);

  List<String> get userRole => getListField<String>('user_role');
  set userRole(List<String> value) => setListField<String>('user_role', value);

  String? get info => getField<String>('info');
  set info(String? value) => setField<String>('info', value);

  String? get contact => getField<String>('contact');
  set contact(String? value) => setField<String>('contact', value);

  String? get photoUrl => getField<String>('photo_url');
  set photoUrl(String? value) => setField<String>('photo_url', value);

  DateTime get dateCreated => getField<DateTime>('date_created')!;
  set dateCreated(DateTime value) => setField<DateTime>('date_created', value);

  DateTime? get dateLastAccess => getField<DateTime>('date_last_access');
  set dateLastAccess(DateTime? value) =>
      setField<DateTime>('date_last_access', value);

  List<int> get startedJourneys => getListField<int>('started_journeys');
  set startedJourneys(List<int>? value) =>
      setListField<int>('started_journeys', value);

  int? get countryId => getField<int>('country_id');
  set countryId(int? value) => setField<int>('country_id', value);
}

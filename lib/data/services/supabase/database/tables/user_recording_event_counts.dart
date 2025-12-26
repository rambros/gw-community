import 'package:gw_community/data/services/supabase/database/database.dart';

class UserRecordingEventCountsTable
    extends SupabaseTable<UserRecordingEventCountsRow> {
  @override
  String get tableName => 'user_recording_event_counts';

  @override
  UserRecordingEventCountsRow createRow(Map<String, dynamic> data) =>
      UserRecordingEventCountsRow(data);
}

class UserRecordingEventCountsRow extends SupabaseDataRow {
  UserRecordingEventCountsRow(super.data);

  @override
  SupabaseTable get table => UserRecordingEventCountsTable();

  int? get numberOfUsers => getField<int>('number_of_users');
  set numberOfUsers(int? value) => setField<int>('number_of_users', value);

  int? get numberOfRecordings => getField<int>('number_of_recordings');
  set numberOfRecordings(int? value) =>
      setField<int>('number_of_recordings', value);

  int? get numberOfEvents => getField<int>('number_of_events');
  set numberOfEvents(int? value) => setField<int>('number_of_events', value);
}

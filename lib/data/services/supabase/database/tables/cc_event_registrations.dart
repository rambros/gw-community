import 'package:gw_community/data/services/supabase/database/database.dart';

class CcEventRegistrationsTable extends SupabaseTable<CcEventRegistrationsRow> {
  @override
  String get tableName => 'cc_event_registrations';

  @override
  CcEventRegistrationsRow createRow(Map<String, dynamic> data) =>
      CcEventRegistrationsRow(data);
}

class CcEventRegistrationsRow extends SupabaseDataRow {
  CcEventRegistrationsRow(super.data);

  @override
  SupabaseTable get table => CcEventRegistrationsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  int? get eventId => getField<int>('event_id');
  set eventId(int? value) => setField<int>('event_id', value);

  DateTime get dateRegistration => getField<DateTime>('date_registration')!;
  set dateRegistration(DateTime value) =>
      setField<DateTime>('date_registration', value);
}

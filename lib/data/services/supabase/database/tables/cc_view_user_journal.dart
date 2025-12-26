import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewUserJournalTable extends SupabaseTable<CcViewUserJournalRow> {
  @override
  String get tableName => 'cc_view_user_journal';

  @override
  CcViewUserJournalRow createRow(Map<String, dynamic> data) =>
      CcViewUserJournalRow(data);
}

class CcViewUserJournalRow extends SupabaseDataRow {
  CcViewUserJournalRow(super.data);

  @override
  SupabaseTable get table => CcViewUserJournalTable();

  int? get userActivityId => getField<int>('user_activity_id');
  set userActivityId(int? value) => setField<int>('user_activity_id', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  DateTime? get dateCompleted => getField<DateTime>('date_completed');
  set dateCompleted(DateTime? value) =>
      setField<DateTime>('date_completed', value);

  String? get journalSaved => getField<String>('journal_saved');
  set journalSaved(String? value) => setField<String>('journal_saved', value);

  String? get stepTitle => getField<String>('step_title');
  set stepTitle(String? value) => setField<String>('step_title', value);

  int? get stepNumber => getField<int>('step_number');
  set stepNumber(int? value) => setField<int>('step_number', value);

  String? get journeyTitle => getField<String>('journey_title');
  set journeyTitle(String? value) => setField<String>('journey_title', value);
}

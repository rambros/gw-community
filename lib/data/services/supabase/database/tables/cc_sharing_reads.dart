import 'package:gw_community/data/services/supabase/database/database.dart';

class CcSharingReadsTable extends SupabaseTable<CcExperienceReadsRow> {
  @override
  String get tableName => 'cc_sharing_reads';

  @override
  CcExperienceReadsRow createRow(Map<String, dynamic> data) => CcExperienceReadsRow(data);
}

class CcExperienceReadsRow extends SupabaseDataRow {
  CcExperienceReadsRow(super.data);

  @override
  SupabaseTable get table => CcSharingReadsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get experienceId => getField<int>('sharing_id')!;
  set experienceId(int value) => setField<int>('sharing_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime get readAt => getField<DateTime>('read_at')!;
  set readAt(DateTime value) => setField<DateTime>('read_at', value);
}

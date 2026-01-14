import 'package:gw_community/data/services/supabase/database/database.dart';

class CcSharingReadsTable extends SupabaseTable<CcSharingReadsRow> {
  @override
  String get tableName => 'cc_sharing_reads';

  @override
  CcSharingReadsRow createRow(Map<String, dynamic> data) => CcSharingReadsRow(data);
}

class CcSharingReadsRow extends SupabaseDataRow {
  CcSharingReadsRow(super.data);

  @override
  SupabaseTable get table => CcSharingReadsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get sharingId => getField<int>('sharing_id')!;
  set sharingId(int value) => setField<int>('sharing_id', value);

  String get userId => getField<String>('user_id')!;
  set userId(String value) => setField<String>('user_id', value);

  DateTime get readAt => getField<DateTime>('read_at')!;
  set readAt(DateTime value) => setField<DateTime>('read_at', value);
}

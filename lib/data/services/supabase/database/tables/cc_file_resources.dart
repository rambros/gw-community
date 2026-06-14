import 'package:gw_community/data/services/supabase/database/database.dart';

class CcFileResourcesTable extends SupabaseTable<CcFileResourcesRow> {
  @override
  String get tableName => 'cc_file_resources';

  @override
  CcFileResourcesRow createRow(Map<String, dynamic> data) =>
      CcFileResourcesRow(data);
}

class CcFileResourcesRow extends SupabaseDataRow {
  CcFileResourcesRow(super.data);

  @override
  SupabaseTable get table => CcFileResourcesTable();

  int get id => getField<int>('id')!;

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String get url => getField<String>('url')!;
  set url(String value) => setField<String>('url', value);

  String get type => getField<String>('type')!;
  set type(String value) => setField<String>('type', value);

  String get status => getField<String>('status') ?? 'draft';
  set status(String value) => setField<String>('status', value);

  DateTime? get publishedAt => getField<DateTime>('published_at');
  set publishedAt(DateTime? value) => setField<DateTime>('published_at', value);

  int? get portalItemId => getField<int>('portal_item_id');

  String? get createdBy => getField<String>('created_by');
  set createdBy(String? value) => setField<String>('created_by', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  DateTime? get updatedAt => getField<DateTime>('updated_at');
}

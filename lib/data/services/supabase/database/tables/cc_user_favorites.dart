import 'package:gw_community/data/services/supabase/database/database.dart';

class CcUserFavoritesTable extends SupabaseTable<CcUserFavoritesRow> {
  @override
  String get tableName => 'cc_user_favorites';

  @override
  CcUserFavoritesRow createRow(Map<String, dynamic> data) =>
      CcUserFavoritesRow(data);
}

class CcUserFavoritesRow extends SupabaseDataRow {
  CcUserFavoritesRow(super.data);

  @override
  SupabaseTable get table => CcUserFavoritesTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  /// ID do membro da comunidade (cc_members.id)
  String? get memberId => getField<String>('member_id');
  set memberId(String? value) => setField<String>('member_id', value);

  String? get contentType => getField<String>('content_type');
  set contentType(String? value) => setField<String>('content_type', value);

  int? get contentId => getField<int>('content_id');
  set contentId(int? value) => setField<int>('content_id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}

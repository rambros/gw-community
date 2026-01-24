import 'package:gw_community/data/services/supabase/database/database.dart';

class CcViewAvailJourneysTable extends SupabaseTable<CcViewAvailJourneysRow> {
  @override
  String get tableName => 'cc_view_avail_journeys';

  @override
  CcViewAvailJourneysRow createRow(Map<String, dynamic> data) => CcViewAvailJourneysRow(data);
}

class CcViewAvailJourneysRow extends SupabaseDataRow {
  CcViewAvailJourneysRow(super.data);

  @override
  SupabaseTable get table => CcViewAvailJourneysTable();

  int? get id => getField<int>('id');
  set id(int? value) => setField<int>('id', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  int? get stepsTotal => getField<int>('steps_total');
  set stepsTotal(int? value) => setField<int>('steps_total', value);

  String? get userId => getField<String>('user_id');
  set userId(String? value) => setField<String>('user_id', value);

  bool get isFeatured => getField<bool>('is_featured') ?? false;
  set isFeatured(bool value) => setField<bool>('is_featured', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcJourneySectionsTable extends SupabaseTable<CcJourneySectionsRow> {
  @override
  String get tableName => 'cc_journey_sections';

  @override
  CcJourneySectionsRow createRow(Map<String, dynamic> data) =>
      CcJourneySectionsRow(data);
}

class CcJourneySectionsRow extends SupabaseDataRow {
  CcJourneySectionsRow(super.data);

  @override
  SupabaseTable get table => CcJourneySectionsTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  int get journeyId => getField<int>('journey_id')!;
  set journeyId(int value) => setField<int>('journey_id', value);

  String get title => getField<String>('title')!;
  set title(String value) => setField<String>('title', value);

  int get sectionOrder => getField<int>('section_order')!;
  set sectionOrder(int value) => setField<int>('section_order', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);
}

import 'package:gw_community/data/services/supabase/database/database.dart';

class CcJourneysTable extends SupabaseTable<CcJourneysRow> {
  @override
  String get tableName => 'cc_journeys';

  @override
  CcJourneysRow createRow(Map<String, dynamic> data) => CcJourneysRow(data);
}

class CcJourneysRow extends SupabaseDataRow {
  CcJourneysRow(super.data);

  @override
  SupabaseTable get table => CcJourneysTable();

  int get id => getField<int>('id')!;
  set id(int value) => setField<int>('id', value);

  DateTime get createdAt => getField<DateTime>('created_at')!;
  set createdAt(DateTime value) => setField<DateTime>('created_at', value);

  String? get title => getField<String>('title');
  set title(String? value) => setField<String>('title', value);

  String? get description => getField<String>('description');
  set description(String? value) => setField<String>('description', value);

  String? get imageFilename => getField<String>('image_filename');
  set imageFilename(String? value) => setField<String>('image_filename', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  int? get stepsTotal => getField<int>('steps_total');
  set stepsTotal(int? value) => setField<int>('steps_total', value);

  String? get journeyLabel => getField<String>('journey_label');
  set journeyLabel(String? value) => setField<String>('journey_label', value);

  String? get status => getField<String>('status');
  set status(String? value) => setField<String>('status', value);

  bool get enableDateControl => getField<bool>('enable_date_control') ?? true;
  set enableDateControl(bool value) => setField<bool>('enable_date_control', value);

  int get daysToWaitBetweenSteps => getField<int>('days_to_wait_between_steps') ?? 1;
  set daysToWaitBetweenSteps(int value) => setField<int>('days_to_wait_between_steps', value);

  bool get isPublic => getField<bool>('is_public') ?? false;
  set isPublic(bool value) => setField<bool>('is_public', value);

  bool get isFeatured => getField<bool>('is_featured') ?? false;
  set isFeatured(bool value) => setField<bool>('is_featured', value);
}

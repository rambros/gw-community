import 'package:gw_community/data/services/supabase/database/database.dart';

class ViewEventsTable extends SupabaseTable<ViewEventsRow> {
  @override
  String get tableName => 'view_events';

  @override
  ViewEventsRow createRow(Map<String, dynamic> data) => ViewEventsRow(data);
}

class ViewEventsRow extends SupabaseDataRow {
  ViewEventsRow(super.data);

  @override
  SupabaseTable get table => ViewEventsTable();

  int? get eventId => getField<int>('event_id');
  set eventId(int? value) => setField<int>('event_id', value);

  int? get localId => getField<int>('local_id');
  set localId(int? value) => setField<int>('local_id', value);

  int? get eventTypeId => getField<int>('event_type_id');
  set eventTypeId(int? value) => setField<int>('event_type_id', value);

  String? get local => getField<String>('local');
  set local(String? value) => setField<String>('local', value);

  String? get region => getField<String>('region');
  set region(String? value) => setField<String>('region', value);

  String? get eventName => getField<String>('event_name');
  set eventName(String? value) => setField<String>('event_name', value);

  String? get year => getField<String>('year');
  set year(String? value) => setField<String>('year', value);

  String? get theme => getField<String>('theme');
  set theme(String? value) => setField<String>('theme', value);

  String? get imageUrl => getField<String>('image_url');
  set imageUrl(String? value) => setField<String>('image_url', value);

  String? get type => getField<String>('type');
  set type(String? value) => setField<String>('type', value);

  String? get dashboard => getField<String>('dashboard');
  set dashboard(String? value) => setField<String>('dashboard', value);

  int? get dashboardGroupId => getField<int>('dashboard_group_id');
  set dashboardGroupId(int? value) =>
      setField<int>('dashboard_group_id', value);

  List<String> get authorNames => getListField<String>('author_names');
  set authorNames(List<String>? value) =>
      setListField<String>('author_names', value);

  DateTime? get start => getField<DateTime>('start');
  set start(DateTime? value) => setField<DateTime>('start', value);

  DateTime? get end => getField<DateTime>('end');
  set end(DateTime? value) => setField<DateTime>('end', value);

  String? get eventSearchString => getField<String>('event_search_string');
  set eventSearchString(String? value) =>
      setField<String>('event_search_string', value);
}

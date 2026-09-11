import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalEventRepository {
  Future<List<ViewEventsRow>> getAll({required int dashboardGroupId}) async {
    final data = await SupaFlow.client
        .from('view_events')
        .select('*')
        .eq('dashboard_group_id', dashboardGroupId)
        .order('start', ascending: false);

    return (data as List).map((row) => ViewEventsRow(row)).toList();
  }

  Future<ViewEventsRow?> getById(int eventId) async {
    final data = await SupaFlow.client
        .from('view_events')
        .select('*')
        .eq('event_id', eventId)
        .maybeSingle();

    return data != null ? ViewEventsRow(data) : null;
  }

  Future<List<ViewEventsRow>> search({
    required String searchString,
    required int dashboardGroupId,
  }) async {
    if (searchString.trim().isEmpty) {
      return getAll(dashboardGroupId: dashboardGroupId);
    }

    final finalString = searchString.replaceAll('&', '-&-').trim().replaceAll(' ', '&');

    final data = await SupaFlow.client
        .from('view_events')
        .select('*')
        .eq('dashboard_group_id', dashboardGroupId)
        .textSearch('event_search_string', finalString)
        .order('start', ascending: false);

    return (data as List).map((row) => ViewEventsRow(row)).toList();
  }

  Future<List<ViewEventsRow>> filter({
    required int dashboardGroupId,
    String year = '',
    int eventId = 0,
    int locationId = 0,
    int eventTypeId = 0,
  }) async {
    dynamic query = SupaFlow.client
        .from('view_events')
        .select('*')
        .eq('dashboard_group_id', dashboardGroupId);

    if (eventId != 0) {
      query = query.eq('event_id', eventId);
    }
    if (locationId != 0) {
      query = query.eq('local_id', locationId);
    }
    if (eventTypeId != 0) {
      query = query.eq('event_type_id', eventTypeId);
    }
    if (year.trim().isNotEmpty) {
      query = query.eq('year', year);
    }

    final data = await query.order('start', ascending: false);
    return (data as List).map((row) => ViewEventsRow(row)).toList();
  }

  Future<List<ViewContentRow>> getEventContents(int eventId) async {
    final data = await SupaFlow.client
        .from('view_content')
        .select('*')
        .eq('is_published', true)
        .eq('cott_event_id', eventId)
        .order('title', ascending: true);

    return (data as List).map((row) => ViewContentRow(row)).toList();
  }
}

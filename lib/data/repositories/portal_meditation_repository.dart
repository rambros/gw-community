import 'package:gw_community/data/services/portal/portal_year_filter.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalMeditationRepository {
  Future<List<ViewMeditationsRow>> getAll() async {
    final data = await SupaFlow.client
        .from('view_meditations')
        .select('*')
        .order('date_published', ascending: false);

    return (data as List).map((row) => ViewMeditationsRow(row)).toList();
  }

  Future<List<ViewMeditationsRow>> filter({
    int authorId = 0,
    String year = '',
    int eventId = 0,
  }) async {
    dynamic query = SupaFlow.client.from('view_meditations').select('*').eq('is_published', true);

    if (authorId != 0) {
      query = query.contains('authors', [authorId]);
    }
    if (year.trim().isNotEmpty) {
      query = applyDatePublishedYearFilter(query, year);
    }
    if (eventId != 0) {
      query = query.eq('cott_event_id', eventId);
    }

    final data = await query.order('date_published', ascending: false);
    return (data as List).map((row) => ViewMeditationsRow(row)).toList();
  }

  Future<List<ViewMeditationsRow>> textSearch(String searchString) async {
    if (searchString.trim().isEmpty) {
      return getAll();
    }

    final finalString = searchString.replaceAll('&', '-&-').trim().replaceAll(' ', '&');

    final data = await SupaFlow.client
        .from('view_meditations')
        .select('*')
        .textSearch('content_search_string', finalString)
        .order('date_published', ascending: false);

    return (data as List).map((row) => ViewMeditationsRow(row)).toList();
  }
}

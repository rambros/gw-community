import 'package:gw_community/data/services/portal/portal_year_filter.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalMessageRepository {
  Future<List<ViewMessagesRow>> getAll() async {
    final data = await SupaFlow.client
        .from('view_messages')
        .select('*')
        .order('date_published', ascending: false);

    return (data as List).map((row) => ViewMessagesRow(row)).toList();
  }

  Future<List<ViewMessagesRow>> filter({
    int authorId = 0,
    String year = '',
  }) async {
    dynamic query = SupaFlow.client.from('view_messages').select('*');

    if (authorId != 0) {
      query = query.contains('authors', [authorId]);
    }
    if (year.trim().isNotEmpty) {
      query = applyDatePublishedYearFilter(query, year);
    }

    final data = await query.order('date_published', ascending: false);
    return (data as List).map((row) => ViewMessagesRow(row)).toList();
  }

  Future<List<ViewMessagesRow>> textSearch(String searchString) async {
    if (searchString.trim().isEmpty) {
      return getAll();
    }

    final finalString = searchString.replaceAll('&', '-&-').trim().replaceAll(' ', '&');

    final data = await SupaFlow.client
        .from('view_messages')
        .select('*')
        .textSearch('content_search_string', finalString)
        .order('date_published', ascending: false);

    return (data as List).map((row) => ViewMessagesRow(row)).toList();
  }
}

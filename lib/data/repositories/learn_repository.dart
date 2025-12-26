import 'package:gw_community/data/services/supabase/supabase.dart';

class LearnRepository {
  // Columns to select for list view to avoid fetching heavy data
  static final String _listColumns =
      'content_id, title, description, authors_names, midia_type, is_published, cott_event_id, event_name, audio_url, midia_file_url';

  Future<List<ViewContentRow>> searchContent(
    String searchString, {
    bool ascending = true,
    String sortColumn = 'title',
    int? limit,
    int? offset,
  }) async {
    String finalString = searchString.replaceAll('&', '-&-');
    finalString = finalString.trim();
    finalString = finalString.replaceAll(' ', '&');

    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .textSearch('content_search_string', finalString)
        .order(sortColumn, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      query = query.range(offset, offset + limit! - 1);
    }

    final response = await query;
    return (response as List).map((row) => ViewContentRow(row)).toList();
  }

  Future<List<ViewContentRow>> filterContent({
    int filterByAuthorId = 0,
    String filterByYear = '',
    int filterByEventId = 0,
    List<String> filterByTopics = const [],
    int filterByJourneyId = 0,
    int filterByGroupId = 0,
    bool ascending = true,
    String sortColumn = 'title',
    int? limit,
    int? offset,
  }) async {
    dynamic query = SupaFlow.client.from('view_content').select(_listColumns).eq('is_published', true);

    if (filterByAuthorId != 0) {
      query = query.contains('authors', [filterByAuthorId]);
    }
    if (filterByTopics.isNotEmpty) {
      query = query.contains('topics_names', filterByTopics);
    }
    if (filterByEventId != 0) {
      query = query.eq('cott_event_id', filterByEventId);
    }
    if (filterByYear.trim().isNotEmpty) {
      query = query.eq('year_published', filterByYear);
    }
    if (filterByGroupId != 0) {
      query = query.contains('groups', [filterByGroupId]);
    }
    if (filterByJourneyId != 0) {
      query = query.contains('journeys', [filterByJourneyId]);
    }

    query = query.order(sortColumn, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      query = query.range(offset, offset + limit! - 1);
    }

    final response = await query;
    return (response as List).map((row) => ViewContentRow(row)).toList();
  }

  Future<List<ViewContentRow>> getAllContent({
    bool ascending = true,
    String sortColumn = 'title',
    int? limit,
    int? offset,
  }) async {
    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .eq('is_published', true)
        .order(sortColumn, ascending: ascending);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      query = query.range(offset, offset + limit! - 1);
    }

    final response = await query;
    return (response as List).map((row) => ViewContentRow(row)).toList();
  }

  Future<List<AuthorWithContentRow>> getAuthors() async {
    return AuthorWithContentTable().queryRows(
      queryFn: (q) => q.eqOrNull('has_content', true).order('name', ascending: true),
    );
  }

  Future<List<ViewEventsRow>> getEvents() async {
    return ViewEventsTable().queryRows(
      queryFn: (q) => q,
    );
  }

  Future<List<YearsWithContentRow>> getYears() async {
    return YearsWithContentTable().queryRows(
      queryFn: (q) => q,
    );
  }

  Future<List<CcJourneysRow>> getJourneys() async {
    return CcJourneysTable().queryRows(
      queryFn: (q) => q.order('title', ascending: true),
    );
  }

  Future<List<CcGroupsRow>> getGroups() async {
    return CcGroupsTable().queryRows(
      queryFn: (q) => q.order('name', ascending: true),
    );
  }

  Future<List<TopicsWithContentRow>> getTopics() async {
    return TopicsWithContentTable().queryRows(
      queryFn: (q) => q.order('topic_name', ascending: true),
    );
  }
}

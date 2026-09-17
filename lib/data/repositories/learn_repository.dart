import 'package:flutter/foundation.dart';
import 'package:gw_community/data/services/portal/portal_hybrid_search.dart';
import 'package:gw_community/data/services/portal/portal_year_filter.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class LearnRepository {
  static const int dadiJankiAuthorId = 1;

  static final String _listColumns =
      'content_id, title, description, content_type_id, authors, authors_names, midia_type, is_published, '
      'cott_event_id, event_type_id, event_name, audio_url, midia_file_url, date_published, year_published, transcript';

  Future<ViewContentRow?> getById(int contentId) async {
    final data = await SupaFlow.client
        .from('view_content')
        .select('*')
        .eq('content_id', contentId)
        .eq('is_published', true)
        .maybeSingle();

    return data != null ? ViewContentRow(data) : null;
  }

  Future<List<ViewContentRow>> hybridSearch(
    String query, {
    List<int>? contentTypeIds,
    List<int>? authorIds,
  }) async {
    final results = await PortalHybridSearch.search(
      query: query,
      contentTypeIds: contentTypeIds,
      authorIds: authorIds,
    );
    return results.map((item) => item.toViewContentRow()).toList();
  }

  Future<List<ViewContentRow>> searchContent(
    String searchString, {
    int filterByAuthorId = 0,
    String filterByYear = '',
    int filterByEventId = 0,
    List<String> filterByTopics = const [],
    int filterByJourneyId = 0,
    int filterByGroupId = 0,
    int filterByLocalId = 0,
    int filterByEventTypeId = 0,
    bool useHybridSearch = true,
    bool ascending = false,
    String sortColumn = 'date_published',
    int? limit,
    int? offset,
  }) async {
    if (useHybridSearch && filterByJourneyId == 0 && filterByGroupId == 0) {
      try {
        final hybridResults = await hybridSearch(searchString);
        if (hybridResults.isNotEmpty) {
          return _sortContent(hybridResults,
              sortColumn: sortColumn, ascending: ascending);
        }
      } catch (e) {
        debugPrint('Hybrid search failed, falling back to text search: $e');
      }
    }

    String finalString = searchString.replaceAll('&', '-&-');
    finalString = finalString.trim();
    finalString = finalString.replaceAll(' ', '&');

    final groupContentIds = filterByGroupId != 0
        ? await _contentIdsForGroup(filterByGroupId)
        : null;
    final journeyContentIds = filterByJourneyId != 0
        ? await _contentIdsForJourney(filterByJourneyId)
        : null;

    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .eq('is_published', true)
        .textSearch('content_search_string', finalString);

    query = _applyFilters(
      query,
      filterByAuthorId: filterByAuthorId,
      filterByYear: filterByYear,
      filterByEventId: filterByEventId,
      filterByTopics: filterByTopics,
      filterByLocalId: filterByLocalId,
      filterByEventTypeId: filterByEventTypeId,
      groupContentIds: groupContentIds,
      journeyContentIds: journeyContentIds,
    );

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

  Future<List<ViewContentRow>> filterContent({
    int filterByAuthorId = 0,
    String filterByYear = '',
    int filterByEventId = 0,
    List<String> filterByTopics = const [],
    int filterByJourneyId = 0,
    int filterByGroupId = 0,
    int filterByLocalId = 0,
    int filterByEventTypeId = 0,
    bool ascending = true,
    String sortColumn = 'title',
    int? limit,
    int? offset,
  }) async {
    final groupContentIds = filterByGroupId != 0
        ? await _contentIdsForGroup(filterByGroupId)
        : null;
    final journeyContentIds = filterByJourneyId != 0
        ? await _contentIdsForJourney(filterByJourneyId)
        : null;

    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .eq('is_published', true);

    query = _applyFilters(
      query,
      filterByAuthorId: filterByAuthorId,
      filterByYear: filterByYear,
      filterByEventId: filterByEventId,
      filterByTopics: filterByTopics,
      filterByLocalId: filterByLocalId,
      filterByEventTypeId: filterByEventTypeId,
      groupContentIds: groupContentIds,
      journeyContentIds: journeyContentIds,
    );

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
    bool excludeExclusive = true,
  }) async {
    final exclusiveIds =
        excludeExclusive ? await _exclusiveContentIds() : <int>[];

    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .eq('is_published', true);

    if (exclusiveIds.isNotEmpty) {
      query = query.not('content_id', 'in', exclusiveIds);
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

  Future<List<ViewContentRow>> getByAuthorId(
    int authorId, {
    int? limit,
    int? offset,
  }) async {
    dynamic query = SupaFlow.client
        .from('view_content')
        .select(_listColumns)
        .eq('is_published', true)
        .contains('authors', [authorId]).order('date_published',
            ascending: false);

    if (limit != null) {
      query = query.limit(limit);
    }
    if (offset != null) {
      query = query.range(offset, offset + limit! - 1);
    }

    final response = await query;
    return (response as List).map((row) => ViewContentRow(row)).toList();
  }

  /// Must stay synchronous: Postgrest builders are Futures, so returning one
  /// from an `async` method executes the request before order/limit are applied.
  dynamic _applyFilters(
    dynamic query, {
    required int filterByAuthorId,
    required String filterByYear,
    required int filterByEventId,
    required List<String> filterByTopics,
    required int filterByLocalId,
    required int filterByEventTypeId,
    List<int>? groupContentIds,
    List<int>? journeyContentIds,
  }) {
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
      query = applyDatePublishedYearFilter(query, filterByYear);
    }
    if (filterByLocalId != 0) {
      query = query.eq('local_id', filterByLocalId);
    }
    if (filterByEventTypeId != 0) {
      query = query.eq('event_type_id', filterByEventTypeId);
    }
    if (groupContentIds != null) {
      query = groupContentIds.isNotEmpty
          ? query.inFilter('content_id', groupContentIds)
          : query.eq('content_id', -1);
    }
    if (journeyContentIds != null) {
      query = journeyContentIds.isNotEmpty
          ? query.inFilter('content_id', journeyContentIds)
          : query.eq('content_id', -1);
    }
    return query;
  }

  Future<List<int>> _contentIdsForGroup(int groupId) async {
    final res = await SupaFlow.client
        .from('cc_group_resources')
        .select('portal_item_id')
        .eq('group_id', groupId)
        .isFilter('deleted_at', null);
    return (res as List).map((row) => row['portal_item_id'] as int).toList();
  }

  Future<List<int>> _contentIdsForJourney(int journeyId) async {
    final res = await SupaFlow.client
        .from('cc_journey_resources')
        .select('item_id')
        .eq('journey_id', journeyId)
        .isFilter('deleted_at', null);
    return (res as List).map((row) => row['item_id'] as int).toList();
  }

  List<ViewContentRow> _sortContent(
    List<ViewContentRow> items, {
    required String sortColumn,
    required bool ascending,
  }) {
    final sorted = List<ViewContentRow>.from(items);
    sorted.sort((a, b) {
      if (sortColumn == 'title') {
        final cmp = (a.title ?? '')
            .toLowerCase()
            .compareTo((b.title ?? '').toLowerCase());
        return ascending ? cmp : -cmp;
      }
      final dateA = a.datePublished;
      final dateB = b.datePublished;
      if (dateA == null && dateB == null) return 0;
      if (dateA == null) return 1;
      if (dateB == null) return -1;
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    return sorted;
  }

  Future<List<int>> _exclusiveContentIds() async {
    final exclusiveResponse = await SupaFlow.client
        .from('cc_group_resources')
        .select('portal_item_id')
        .eq('visibility', 'exclusive');

    return (exclusiveResponse as List)
        .map((row) => row['portal_item_id'] as int)
        .toList();
  }

  Future<List<AuthorWithContentRow>> getAuthors() async {
    return AuthorWithContentTable()
        .queryRows(queryFn: (q) => q.order('name', ascending: true));
  }

  Future<List<ViewEventsRow>> getEvents() async {
    return ViewEventsTable().queryRows(queryFn: (q) => q);
  }

  Future<List<YearsWithContentRow>> getYears() async {
    return YearsWithContentTable().queryRows(queryFn: (q) => q);
  }

  Future<List<CcJourneysRow>> getJourneys() async {
    return CcJourneysTable().queryRows(
      queryFn: (q) => q.inFilter(
          'status', ['published', 'Published']).order('title', ascending: true),
    );
  }

  Future<List<CcGroupsRow>> getGroups() async {
    return CcGroupsTable()
        .queryRows(queryFn: (q) => q.order('name', ascending: true));
  }

  Future<List<TopicsWithContentRow>> getTopics() async {
    return TopicsWithContentTable()
        .queryRows(queryFn: (q) => q.order('topic_name', ascending: true));
  }

  Future<List<LocalWithEventRow>> getLocations() async {
    return LocalWithEventTable()
        .queryRows(queryFn: (q) => q.order('local', ascending: true));
  }

  Future<List<EventTypeRow>> getEventTypes() async {
    return EventTypeTable()
        .queryRows(queryFn: (q) => q.order('name', ascending: true));
  }

  Future<int?> getDashboardGroupIdForEvent(int eventId) async {
    final data = await SupaFlow.client
        .from('view_events')
        .select('dashboard_group_id')
        .eq('event_id', eventId)
        .maybeSingle();
    if (data == null) return null;
    return ViewEventsRow(data).dashboardGroupId;
  }
}

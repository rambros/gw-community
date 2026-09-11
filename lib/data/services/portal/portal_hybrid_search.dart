import 'package:gw_community/data/services/supabase/supabase.dart';

class PortalHybridSearchResult {
  PortalHybridSearchResult({
    required this.contentId,
    required this.title,
    this.eventName,
    this.cottEventId,
    this.contentTypeId,
    this.midiaType,
    this.yearPublished,
    this.authorsNames = const [],
    this.datePublished,
  });

  final int contentId;
  final String title;
  final String? eventName;
  final int? cottEventId;
  final int? contentTypeId;
  final String? midiaType;
  final int? yearPublished;
  final List<String> authorsNames;
  final DateTime? datePublished;

  factory PortalHybridSearchResult.fromMap(Map<String, dynamic> data) {
    return PortalHybridSearchResult(
      contentId: data['content_id'] as int? ?? 0,
      title: data['title'] as String? ?? '',
      eventName: data['event_name'] as String?,
      cottEventId: data['cott_event_id'] as int?,
      contentTypeId: data['content_type_id'] as int?,
      midiaType: data['midia_type'] as String?,
      yearPublished: data['year_published'] is num
          ? (data['year_published'] as num).toInt()
          : int.tryParse('${data['year_published']}'),
      authorsNames: (data['authors_names'] as List?)?.map((e) => '$e').toList() ?? const [],
      datePublished: data['date_published'] is String
          ? DateTime.tryParse(data['date_published'] as String)
          : data['date_published'] as DateTime?,
    );
  }

  ViewContentRow toViewContentRow() {
    return ViewContentRow({
      'content_id': contentId,
      'title': title,
      'event_name': eventName,
      'cott_event_id': cottEventId,
      'content_type_id': contentTypeId,
      'midia_type': midiaType,
      'year_published': yearPublished,
      'authors_names': authorsNames,
      'date_published': datePublished?.toIso8601String(),
    });
  }
}

class PortalHybridSearch {
  static Future<List<PortalHybridSearchResult>> search({
    required String query,
    List<int>? contentTypeIds,
    List<int>? authorIds,
  }) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) {
      return [];
    }

    try {
      final response = await SupaFlow.client.functions.invoke(
        'hybrid-search-portal-items',
        body: {
          'search': trimmed,
          'content_type_ids': contentTypeIds,
          'author_ids': authorIds,
        },
      );

      if (response.status != 200 || response.data == null) {
        return [];
      }

      final data = response.data;
      if (data is! Map) {
        return [];
      }

      final results = data['result'];
      if (results is! List) {
        return [];
      }

      return results
          .whereType<Map>()
          .map((row) => PortalHybridSearchResult.fromMap(row.cast<String, dynamic>()))
          .where((item) => item.contentId != 0)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

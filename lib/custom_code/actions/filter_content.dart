// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<ViewContentRow>> filterContent(
  int filterByAuthorId,
  String filterByYear,
  int filterByEventId,
  String? filterByLocationId,
  List<String> filterByTopics,
  SortContentType sortContentBy,
  int filterByJourneyId,
  int filterByGroupId,
) async {
  // Add your function code here!

  final supabase = SupaFlow.client;
  var response =
      supabase.from('view_content').select('*').eq('is_published', true);

  if (filterByAuthorId != 0) {
    response = response.contains('authors',
        filterByAuthorId.toString().split(' ').map(int.parse).toList());
  }
  if (filterByTopics.isNotEmpty) {
    response = response.contains('topics_names', filterByTopics);
  }
  if (filterByEventId != 0) {
    response = response.eq('cott_event_id', filterByEventId);
  }
  //if (filterByJourneyId != 0) {
  //  response = response.eq('journey_id', filterByJourneyId);
  //}

  if (filterByYear.trim() != '') {
    response = response.eq('year_published', filterByYear);
  }

  if (filterByGroupId != 0) {
    response = response.contains('groups',
        filterByGroupId.toString().split(' ').map(int.parse).toList());
  }

  if (filterByJourneyId != 0) {
    response = response.contains('journeys',
        filterByJourneyId.toString().split(' ').map(int.parse).toList());
  }

  OrderSQLTypeStruct orderSQL = getOrderSQL(sortContentBy);
  final data = await response.order(orderSQL.column, ascending: orderSQL.asc);

  List<ViewContentRow> contentList = [];
  for (var row in data) {
    contentList.add(ViewContentRow(row));
  }

  return contentList;
}

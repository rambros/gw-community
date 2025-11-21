// Automatic FlutterFlow imports
import '/backend/schema/structs/index.dart';
import '/backend/schema/enums/enums.dart';
import '/backend/supabase/supabase.dart';
// Imports other custom actions
import '/flutter_flow/custom_functions.dart'; // Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<ViewContentRow>> searchContent(
  String searchString,
  SortContentType sortContentBy,
) async {
  // Add your function code here!

  String finalString = searchString.replaceAll('&', '-&-');
  finalString = finalString.trim();
  finalString = finalString.replaceAll(' ', '&');

  OrderSQLTypeStruct orderSQL = getOrderSQL(sortContentBy);

  final supabase = SupaFlow.client;
  var response = supabase
      .from('view_content')
      .select()
      .textSearch('content_search_string', finalString)
      .order(orderSQL.column, ascending: orderSQL.asc);

  final data = await response;

  List<ViewContentRow> contentList = [];
  for (var row in data) {
    contentList.add(ViewContentRow(row));
  }

  return contentList;
}

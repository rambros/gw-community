// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<CcGroupsRow>> getAvailableGroups(String? userId) async {
  final supabase = SupaFlow.client;
  final data = await supabase
      .rpc('get_available_groups', params: {'user_input': userId});

  List<CcGroupsRow> groupsList = [];
  for (var row in data) {
    groupsList.add(CcGroupsRow(row));
  }
  return groupsList;
}

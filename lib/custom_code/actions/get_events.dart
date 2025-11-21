// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<CcEventsRow>> getEvents(String userId) async {
  final supabase = SupaFlow.client;
  final data =
      await supabase.rpc('get_user_events', params: {'user_id_input': userId});

  List<CcEventsRow> eventsList = [];
  for (var row in data) {
    eventsList.add(CcEventsRow(row));
  }
  return eventsList;
}

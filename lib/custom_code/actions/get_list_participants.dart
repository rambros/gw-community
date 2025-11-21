// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<CcUsersRow>> getListParticipants(String? eventIdInput) async {
  final supabase = SupaFlow.client;
  final data = await supabase
      .rpc('get_list_participants', params: {'event_id_input': eventIdInput});

  List<CcUsersRow> participantsList = [];
  for (var row in data) {
    participantsList.add(CcUsersRow(row));
  }
  return participantsList;
}

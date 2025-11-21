// Automatic FlutterFlow imports
import '/backend/supabase/supabase.dart';
// Imports other custom actions
// Imports custom functions
// Begin custom action code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

Future<List<CcJourneysRow>> getAvailableJourneys(String? userId) async {
  final supabase = SupaFlow.client;
  final data = await supabase
      .rpc('get_available_journeys', params: {'user_input': userId});

  List<CcJourneysRow> journeysList = [];
  for (var row in data) {
    journeysList.add(CcJourneysRow(row));
  }
  return journeysList;
}

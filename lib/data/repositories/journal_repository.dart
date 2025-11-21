import '/backend/supabase/supabase.dart';

class JournalRepository {
  Future<void> saveJournalEntry(int activityId, String journalContent) async {
    await CcUserActivitiesTable().update(
      data: {
        'journal_saved': journalContent,
      },
      matchingRows: (rows) => rows.eqOrNull('id', activityId),
    );
  }
}

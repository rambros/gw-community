import '/backend/supabase/supabase.dart';
import '/custom_code/actions/index.dart' as actions;

class CommunityRepository {
  Stream<List<CcViewSharingsUsersRow>> getSharingsStream() {
    return SupaFlow.client
        .from("cc_view_sharings_users")
        .stream(primaryKey: ['id'])
        .eqOrNull(
          'visibility',
          'everyone',
        )
        .order('updated_at')
        .map((list) => list.map((item) => CcViewSharingsUsersRow(item)).toList());
  }

  Future<List<CcEventsRow>> getEvents(String currentUserUid) async {
    final events = await actions.getEvents(currentUserUid);
    return events.toList().cast<CcEventsRow>();
  }

  Future<List<CcGroupsRow>> getAvailableGroups(String currentUserUid) async {
    final groups = await actions.getAvailableGroups(currentUserUid);
    return groups.toList().cast<CcGroupsRow>();
  }

  Future<List<CcGroupsRow>> getMyGroups(String currentUserUid) async {
    final groups = await actions.getMyGroups(currentUserUid);
    return groups.toList().cast<CcGroupsRow>();
  }

  Future<void> deleteSharing(int id) async {
    await CcSharingsTable().delete(
      matchingRows: (rows) => rows.eqOrNull(
        'id',
        id,
      ),
    );
  }
}

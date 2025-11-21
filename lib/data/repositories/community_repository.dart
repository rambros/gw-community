import '/data/services/supabase/supabase.dart';

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
    final response = await SupaFlow.client.rpc(
      'get_user_events',
      params: {
        'user_id_input': currentUserUid,
      },
    );

    if (response is List) {
      return response.map((row) => CcEventsRow(row as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<CcGroupsRow>> getAvailableGroups(String currentUserUid) async {
    final response = await SupaFlow.client.rpc(
      'get_available_groups',
      params: {
        'user_input': currentUserUid,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
    }
    return [];
  }

  Future<List<CcGroupsRow>> getMyGroups(String currentUserUid) async {
    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {
        'user_input': currentUserUid,
      },
    );

    if (response is List) {
      return response.map((row) => CcGroupsRow(row as Map<String, dynamic>)).toList();
    }
    return [];
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

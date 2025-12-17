import '/data/models/enums/enums.dart';
import '/data/services/supabase/supabase.dart';
import '/utils/flutter_flow_util.dart';

class NotificationRepository {
  Future<CcMembersRow?> getUserById(String userId) async {
    final result = await CcMembersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', userId),
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> createNotification({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    int? groupId,
    String visibility = 'group_only',
  }) async {
    await CcSharingsTable().insert({
      'title': title,
      'privacy': privacy,
      'user_id': userId,
      'text': text,
      'group_id': groupId,
      'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
      'visibility': visibility,
      'type': SharingType.notification.name,
    });
  }

  Future<CcViewNotificationsUsersRow?> getNotificationById(int id) async {
    final result = await CcViewNotificationsUsersTable().querySingleRow(
      queryFn: (q) => q.eqOrNull('id', id),
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<CcViewOrderedCommentsRow>> getComments(int sharingId) async {
    return CcViewOrderedCommentsTable().queryRows(
      queryFn: (q) => q.eqOrNull('sharing_id', sharingId).order('sort_path', ascending: true),
    );
  }

  Future<void> deleteNotification(int id) async {
    await CcCommentsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('sharing_id', id),
    );
    await CcSharingsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  Future<void> updateNotification({
    required int id,
    required String title,
    required String text,
    required String privacy,
    required String visibility,
  }) async {
    await CcSharingsTable().update(
      data: {
        'title': title,
        'text': text,
        'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
        'privacy': privacy,
        'visibility': visibility,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  Future<void> toggleLock(int id, bool locked) async {
    await CcSharingsTable().update(
      data: {
        'locked': locked,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );
  }

  Future<void> deleteComment(int commentId) async {
    await CcCommentsTable().delete(
      matchingRows: (rows) => rows.eqOrNull('id', commentId),
    );
  }

  Stream<List<CcViewNotificationsUsersRow>> getNotificationsStream(int groupId) {
    return SupaFlow.client
        .from("cc_view_notifications_users")
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('updated_at')
        .map((list) => list.map((item) => CcViewNotificationsUsersRow(item)).toList());
  }
}

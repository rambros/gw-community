import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class NotificationRepository {
  Future<CcMembersRow?> getUserById(String authUserId) async {
    final result = await CcMembersTable().querySingleRow(queryFn: (q) => q.eqOrNull('auth_user_id', authUserId));
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
    final result = await CcViewNotificationsUsersTable().querySingleRow(queryFn: (q) => q.eqOrNull('id', id));
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<CcViewOrderedCommentsRow>> getComments(int sharingId) async {
    return CcViewOrderedCommentsTable().queryRows(
      queryFn: (q) => q.eqOrNull('sharing_id', sharingId).order('sort_path', ascending: true),
    );
  }

  Future<void> deleteNotification(int id) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('sharing_id', id));
    await CcSharingsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', id));
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
    await CcSharingsTable().update(data: {'locked': locked}, matchingRows: (rows) => rows.eqOrNull('id', id));
  }

  Future<void> deleteComment(int commentId) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', commentId));
  }

  Stream<List<CcViewNotificationsUsersRow>> getNotificationsStream(int groupId) {
    return SupaFlow.client
        .from("cc_view_notifications_users")
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('updated_at')
        .map((list) => list.map((item) => CcViewNotificationsUsersRow(item)).toList())
        .asBroadcastStream();
  }

  /// Marca uma notificação como lida para o usuário atual
  Future<void> markNotificationAsRead(int notificationId, String userId) async {
    try {
      // Verifica se já existe um registro
      final existing = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('sharing_id', notificationId).eq('user_id', userId),
      );

      if (existing.isEmpty) {
        // Se não existe, cria um novo registro
        await CcSharingReadsTable().insert({
          'sharing_id': notificationId,
          'user_id': userId,
          'read_at': supaSerialize<DateTime>(getCurrentTimestamp),
        });
      }
    } catch (e) {
      // Ignora erro silenciosamente - se falhar não deve impedir o fluxo
      print('Error marking notification as read: $e');
    }
  }

  /// Busca os IDs de notificações lidas pelo usuário atual no grupo
  Future<Set<int>> getReadNotificationIds(int groupId, String userId) async {
    try {
      final notifications = await CcViewNotificationsUsersTable().queryRows(queryFn: (q) => q.eq('group_id', groupId));

      final notificationIds = notifications.map((n) => n.id!).toList();

      if (notificationIds.isEmpty) {
        return {};
      }

      final reads = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', notificationIds),
      );

      return reads.map((r) => r.sharingId).toSet();
    } catch (e) {
      print('Error fetching read notification IDs: $e');
      return {};
    }
  }

  /// Conta quantas notificações não lidas existem no grupo para o usuário
  Future<int> getUnreadNotificationCount(int groupId, String userId) async {
    try {
      final notifications = await CcViewNotificationsUsersTable().queryRows(queryFn: (q) => q.eq('group_id', groupId));

      final notificationIds = notifications.map((n) => n.id!).toList();

      if (notificationIds.isEmpty) {
        return 0;
      }

      final reads = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', notificationIds),
      );

      final readIds = reads.map((r) => r.sharingId).toSet();
      return notificationIds.where((id) => !readIds.contains(id)).length;
    } catch (e) {
      print('Error fetching unread notification count: $e');
      return 0;
    }
  }

  // ==========================================================================
  // MODERATION NOTIFICATIONS
  // ==========================================================================

  /// Creates a group notification for experience approval
  Future<void> createApprovalNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required int? groupId,
  }) async {
    if (groupId == null) return;

    await createNotification(
      title: 'Experience Approved',
      text: 'Your experience "$experienceTitle" has been approved and is now visible.',
      privacy: 'public',
      userId: userId,
      groupId: groupId,
      visibility: 'group_only',
    );
  }

  /// Creates a group notification for experience rejection
  Future<void> createRejectionNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required String reason,
    required int? groupId,
  }) async {
    if (groupId == null) return;

    await createNotification(
      title: 'Experience Not Published',
      text: 'Your experience "$experienceTitle" was not published. Reason: $reason',
      privacy: 'public',
      userId: userId,
      groupId: groupId,
      visibility: 'group_only',
    );
  }

  /// Creates a group notification for changes requested
  Future<void> createChangesRequestedNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required String reason,
    required int? groupId,
  }) async {
    if (groupId == null) return;

    await createNotification(
      title: 'Refinement Suggested',
      text: 'Please update your experience "$experienceTitle". Feedback: $reason',
      privacy: 'public',
      userId: userId,
      groupId: groupId,
      visibility: 'group_only',
    );
  }
}

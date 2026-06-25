import 'package:flutter/foundation.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class AnnouncementRepository {
  Future<CcMembersRow?> getUserById(String authUserId) async {
    final result = await CcMembersTable().querySingleRow(queryFn: (q) => q.eqOrNull('auth_user_id', authUserId));
    return result.isNotEmpty ? result.first : null;
  }

  Future<void> createAnnouncement({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    int? groupId,
    String visibility = 'group_only',
    String? recipientUserId,
  }) async {
    await CcSharingsTable().insert({
      'title': title,
      'privacy': privacy,
      'user_id': userId,
      'text': text,
      'group_id': groupId,
      'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
      'visibility': visibility,
      'type': ExperienceType.notification.name,
      if (recipientUserId != null) 'recipient_user_id': recipientUserId,
    });
  }

  Future<CcViewNotificationsUsersRow?> getAnnouncementById(int id) async {
    final result = await CcViewNotificationsUsersTable().querySingleRow(queryFn: (q) => q.eqOrNull('id', id));
    return result.isNotEmpty ? result.first : null;
  }

  Future<List<CcViewOrderedCommentsRow>> getComments(int experienceId) async {
    return CcViewOrderedCommentsTable().queryRows(
      queryFn: (q) => q.eqOrNull('sharing_id', experienceId).order('sort_path', ascending: true),
    );
  }

  Future<void> deleteAnnouncement(int id) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('sharing_id', id));
    await CcSharingsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', id));
  }

  Future<void> updateAnnouncement({
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

    // Reset read status for all users so it shows as new
    await CcSharingReadsTable().delete(matchingRows: (rows) => rows.eq('sharing_id', id));
  }

  Future<void> toggleLock(int id, bool locked) async {
    await CcSharingsTable().update(data: {'locked': locked}, matchingRows: (rows) => rows.eqOrNull('id', id));
  }

  Future<void> deleteComment(int commentId) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', commentId));
  }

  Stream<List<CcViewNotificationsUsersRow>> getAnnouncementsStream(int groupId) {
    return SupaFlow.client
        .from("cc_view_notifications_users")
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .order('updated_at')
        .map((list) => list.map((item) => CcViewNotificationsUsersRow(item)).toList())
        .asBroadcastStream();
  }

  /// Marca um anúncio como lido para o usuário atual
  Future<void> markAnnouncementAsRead(int announcementId, String userId) async {
    try {
      // Verifica se já existe um registro
      final existing = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('sharing_id', announcementId).eq('user_id', userId),
      );

      if (existing.isEmpty) {
        // Se não existe, cria um novo registro
        await CcSharingReadsTable().insert({
          'sharing_id': announcementId,
          'user_id': userId,
          'read_at': supaSerialize<DateTime>(getCurrentTimestamp),
        });
      }
    } catch (e) {
      // Ignora erro silenciosamente - se falhar não deve impedir o fluxo
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Busca a data de entrada do usuário no grupo.
  /// Retorna null se o usuário não for membro.
  Future<DateTime?> _getMemberJoinDate(int groupId, String userId) async {
    try {
      final rows = await CcGroupMembersTable().queryRows(
        queryFn: (q) => q.eq('group_id', groupId).eq('user_id', userId),
      );
      return rows.isNotEmpty ? rows.first.createdAt : null;
    } catch (e) {
      return null;
    }
  }

  /// Busca os IDs de anúncios lidos pelo usuário no grupo.
  /// Apenas anúncios publicados APÓS a entrada do usuário no grupo são considerados.
  /// Mensagens privadas só são consideradas se forem para o usuário ou enviadas por ele.
  Future<Set<int>> getReadAnnouncementIds(int groupId, String userId) async {
    try {
      final joinDate = await _getMemberJoinDate(groupId, userId);

      final notifications = await CcViewNotificationsUsersTable().queryRows(
        queryFn: (q) => q.eq('group_id', groupId),
      );

      final relevantIds = notifications
          .where((n) =>
              n.id != null &&
              // Só mensagens após a entrada do membro
              (joinDate == null || (n.updatedAt != null && n.updatedAt!.isAfter(joinDate))) &&
              // Broadcast ou privado endereçado a / enviado por este usuário
              (n.recipientUserId == null || n.recipientUserId == userId || n.userId == userId))
          .map((n) => n.id!)
          .toList();

      if (relevantIds.isEmpty) return {};

      final reads = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', relevantIds),
      );

      return reads.map((r) => r.experienceId).toSet();
    } catch (e) {
      debugPrint('Error fetching read notification IDs: $e');
      return {};
    }
  }

  /// Conta quantos anúncios não lidos existem no grupo para o usuário.
  /// Apenas mensagens publicadas APÓS a entrada do usuário no grupo contam.
  /// Mensagens privadas só contam se forem para o usuário ou enviadas por ele.
  Future<int> getUnreadAnnouncementCount(int groupId, String userId) async {
    try {
      final joinDate = await _getMemberJoinDate(groupId, userId);

      final notifications = await CcViewNotificationsUsersTable().queryRows(
        queryFn: (q) => q.eq('group_id', groupId),
      );

      final relevant = notifications.where((n) =>
          n.id != null &&
          (joinDate == null || (n.updatedAt != null && n.updatedAt!.isAfter(joinDate))) &&
          (n.recipientUserId == null || n.recipientUserId == userId || n.userId == userId));

      final relevantIds = relevant.map((n) => n.id!).toList();
      if (relevantIds.isEmpty) return 0;

      final reads = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', relevantIds),
      );

      final readIds = reads.map((r) => r.experienceId).toSet();
      return relevantIds.where((id) => !readIds.contains(id)).length;
    } catch (e) {
      debugPrint('Error fetching unread announcement count: $e');
      return 0;
    }
  }

  /// Total de anúncios não lidos em todos os grupos do usuário (para o badge da notification bell).
  /// Só conta mensagens publicadas APÓS a entrada do usuário em cada grupo.
  Future<int> getTotalUnreadForUser(String userId) async {
    try {
      final memberships = await CcGroupMembersTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId),
      );
      if (memberships.isEmpty) return 0;

      int total = 0;

      for (final membership in memberships) {
        final groupId = membership.groupId;
        if (groupId == null) continue;

        final joinDate = membership.createdAt;

        final notifications = await CcViewNotificationsUsersTable().queryRows(
          queryFn: (q) => q.eq('group_id', groupId),
        );

        // Só mensagens após a entrada do membro, broadcast ou privadas para/por este usuário
        final relevant = notifications.where((n) =>
            n.id != null &&
            n.updatedAt != null &&
            n.updatedAt!.isAfter(joinDate) &&
            (n.recipientUserId == null || n.recipientUserId == userId || n.userId == userId));

        final relevantIds = relevant.map((n) => n.id!).toList();
        if (relevantIds.isEmpty) continue;

        final reads = await CcSharingReadsTable().queryRows(
          queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', relevantIds),
        );
        final readIds = reads.map((r) => r.experienceId).toSet();

        total += relevantIds.where((id) => !readIds.contains(id)).length;
      }

      return total;
    } catch (e) {
      debugPrint('Error fetching total unread announcements: $e');
      return 0;
    }
  }

  /// Returns the [createdAt] of the most recent post (sharing) in the group,
  /// or null if no posts exist yet.
  Future<DateTime?> getLatestPostDate(int groupId) async {
    try {
      final rows = await CcSharingsTable().queryRows(
        queryFn: (q) => q
            .eq('group_id', groupId)
            .order('created_at', ascending: false)
            .limit(1),
      );
      return rows.isNotEmpty ? rows.first.createdAt : null;
    } catch (e) {
      debugPrint('Error fetching latest post date: $e');
      return null;
    }
  }

  // ==========================================================================
  // MODERATION NOTIFICATIONS (uses cc_notifications table like admin portal)
  // ==========================================================================

  /// Creates a notification in cc_notifications table (same as admin portal)
  Future<CcNotificationsRow> _createModerationNotification({
    required String userId,
    required String type,
    required String title,
    String? message,
    String? referenceType,
    int? referenceId,
    int? groupId,
  }) async {
    return await CcNotificationsTable().insert({
      'user_id': userId,
      'type': type,
      'title': title,
      if (message != null) 'message': message,
      if (referenceType != null) 'reference_type': referenceType,
      if (referenceId != null) 'reference_id': referenceId,
      if (groupId != null) 'group_id': groupId,
      'is_read': false,
    });
  }

  /// Creates a notification for experience approval (visible only to author)
  Future<void> createApprovalNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required int? groupId,
  }) async {
    await _createModerationNotification(
      userId: userId,
      type: 'experience_approved',
      title: 'Experience Approved',
      message: 'Your experience "$experienceTitle" has been approved and is now visible.',
      referenceType: 'experience',
      referenceId: experienceId,
      groupId: groupId,
    );
  }

  /// Creates a notification for experience rejection (visible only to author)
  Future<void> createRejectionNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required String reason,
    required int? groupId,
  }) async {
    await _createModerationNotification(
      userId: userId,
      type: 'experience_rejected',
      title: 'Experience Not Published',
      message: 'Your experience "$experienceTitle" was not published. Reason: $reason',
      referenceType: 'experience',
      referenceId: experienceId,
      groupId: groupId,
    );
  }

  /// Creates a notification for changes requested (visible only to author)
  Future<void> createChangesRequestedNotification({
    required String userId,
    required int experienceId,
    required String experienceTitle,
    required String reason,
    required int? groupId,
  }) async {
    await _createModerationNotification(
      userId: userId,
      type: 'experience_changes_requested',
      title: 'Refinement Suggested',
      message: 'Please update your experience "$experienceTitle". Feedback: $reason',
      referenceType: 'experience',
      referenceId: experienceId,
      groupId: groupId,
    );
  }
}

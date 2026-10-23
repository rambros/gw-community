import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/reply_attention.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class AnnouncementRepository {
  Future<CcMembersRow?> getUserById(String authUserId) async {
    final result = await CcMembersTable().querySingleRow(queryFn: (q) => q.eqOrNull('auth_user_id', authUserId));
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> createAnnouncement({
    required String title,
    required String text,
    required String privacy,
    required String userId,
    int? groupId,
    String visibility = 'group_only',
    String? recipientUserId,
    bool isPinned = false,
  }) async {
    final row = await CcSharingsTable().insert({
      'title': title,
      'privacy': privacy,
      'user_id': userId,
      'text': text,
      'group_id': groupId,
      'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
      'visibility': visibility,
      'type': ExperienceType.notification.name,
      'is_pinned': isPinned,
      if (isPinned) 'pinned_at': supaSerialize<DateTime>(getCurrentTimestamp),
      if (recipientUserId != null) 'recipient_user_id': recipientUserId,
    });
    return row.id;
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
    required bool isPinned,
    required bool wasPinned,
    bool resetReads = true,
  }) async {
    await CcSharingsTable().update(
      data: {
        'title': title,
        'text': text,
        'updated_at': supaSerialize<DateTime>(getCurrentTimestamp),
        'privacy': privacy,
        'visibility': visibility,
        'is_pinned': isPinned,
        if (isPinned && !wasPinned) 'pinned_at': supaSerialize<DateTime>(getCurrentTimestamp),
        if (!isPinned) 'pinned_at': null,
      },
      matchingRows: (rows) => rows.eqOrNull('id', id),
    );

    // A content edit shows the message as new. Pinning alone does not.
    if (resetReads) {
      await CcSharingReadsTable().delete(matchingRows: (rows) => rows.eq('sharing_id', id));
    }
  }

  Future<void> toggleLock(int id, bool locked) async {
    await CcSharingsTable().update(data: {'locked': locked}, matchingRows: (rows) => rows.eqOrNull('id', id));
  }

  Future<void> deleteComment(int commentId) async {
    await CcCommentsTable().delete(matchingRows: (rows) => rows.eqOrNull('id', commentId));
  }

  // Supabase Realtime does not support views — subscribe to the underlying
  // table (cc_sharings) and re-query the view on every change.
  Stream<List<CcViewNotificationsUsersRow>> getAnnouncementsStream(int groupId) {
    final controller = StreamController<List<CcViewNotificationsUsersRow>>();

    Future<List<CcViewNotificationsUsersRow>> fetchFromView() =>
        CcViewNotificationsUsersTable().queryRows(
          queryFn: (q) => q.eq('group_id', groupId).order('updated_at', ascending: false),
        );

    fetchFromView().then((data) {
      if (!controller.isClosed) controller.add(data);
    });

    final subscription = SupaFlow.client
        .from('cc_sharings')
        .stream(primaryKey: ['id'])
        .eq('group_id', groupId)
        .listen(
          (_) async {
            final data = await fetchFromView();
            if (!controller.isClosed) controller.add(data);
          },
          onError: (Object error) {
            debugPrint('ℹ️ cc_sharings (notifications) realtime closed: $error');
          },
          cancelOnError: false,
        );

    controller.onCancel = () {
      subscription.cancel();
      if (!controller.isClosed) controller.close();
    };

    return controller.stream.asBroadcastStream();
  }

  /// Horário em que esta pessoa abriu a mensagem pela última vez.
  /// Nulo se ela nunca abriu.
  Future<DateTime?> getAnnouncementReadAt(int announcementId, String userId) async {
    try {
      final rows = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('sharing_id', announcementId).eq('user_id', userId),
      );
      if (rows.isEmpty) return null;
      return rows.first.readAt;
    } catch (e) {
      debugPrint('Error fetching announcement read time: $e');
      return null;
    }
  }

  /// Marca um anúncio como visto agora. Reabrir atualiza [read_at], para que
  /// respostas anteriores deixem de contar como novas.
  Future<void> markAnnouncementAsRead(int announcementId, String userId) async {
    try {
      await SupaFlow.client.from('cc_sharing_reads').upsert(
        {
          'sharing_id': announcementId,
          'user_id': userId,
          'read_at': supaSerialize<DateTime>(getCurrentTimestamp.toUtc()),
        },
        onConflict: 'sharing_id,user_id',
      );
    } catch (e) {
      debugPrint('Error marking notification as read: $e');
    }
  }

  /// Busca a data de entrada do usuário no grupo.
  /// Retorna null se o usuário não for membro.
  Future<DateTime?> memberJoinDate(int groupId, String userId) async {
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
  /// Uma leitura já gravada permanece, mesmo se a mensagem for anterior à
  /// entrada no grupo. Mensagens privadas só entram se forem para o usuário
  /// ou enviadas por ele.
  Future<Set<int>> getReadAnnouncementIds(int groupId, String userId) async {
    try {
      final notifications = await CcViewNotificationsUsersTable().queryRows(
        queryFn: (q) => q.eq('group_id', groupId),
      );

      final relevantIds = notifications
          .where((n) =>
              n.id != null &&
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
      final membership = await _membership(groupId, userId);
      final joinDate = membership?.createdAt;

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
      final replyCounts = await _replyCountsFor(
        userId: userId,
        isFacilitator: _isFacilitatorRole(membership?.userRole),
        sharingIds: relevantIds,
        reads: reads,
      );
      return messagesNeedingAttention(
        messageIds: relevantIds,
        readIds: readIds,
        replyCounts: replyCounts,
      );
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
        final replyCounts = await _replyCountsFor(
          userId: userId,
          isFacilitator: _isFacilitatorRole(membership.userRole),
          sharingIds: relevantIds,
          reads: reads,
        );

        total += messagesNeedingAttention(
          messageIds: relevantIds,
          readIds: readIds,
          replyCounts: replyCounts,
        );
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

  /// Replies from other people after this person last opened each message.
  /// A member only counts replies in their own thread. Keys are sharing ids
  /// the caller can see.
  Future<FacilitatorCommentSnapshot> getReplyAttention({
    required String userId,
    required Map<int, int> sharingGroupIds,
  }) async {
    if (sharingGroupIds.isEmpty) return FacilitatorCommentSnapshot.empty;
    try {
      final groupIds = sharingGroupIds.values.toSet().toList();
      final memberships = await CcGroupMembersTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('group_id', groupIds),
      );
      final facilitatorGroups = memberships
          .where((m) => m.groupId != null && _isFacilitatorRole(m.userRole))
          .map((m) => m.groupId!)
          .toSet();
      final sharingIds = sharingGroupIds.keys.toList();
      final reads = await CcSharingReadsTable().queryRows(
        queryFn: (q) => q.eq('user_id', userId).inFilter('sharing_id', sharingIds),
      );
      return await _replyAttention(
        userId: userId,
        sharingIds: sharingIds,
        facilitatorSharingIds: {
          for (final entry in sharingGroupIds.entries)
            if (facilitatorGroups.contains(entry.value)) entry.key,
        },
        readAtBySharing: {
          for (final read in reads) read.experienceId: read.readAt,
        },
      );
    } catch (e) {
      debugPrint('Error fetching reply attention: $e');
      return FacilitatorCommentSnapshot.empty;
    }
  }

  /// True when [userId] is a facilitator of this group, not merely an app admin.
  Future<bool> isGroupFacilitator({
    required int? groupId,
    required String userId,
  }) async {
    if (groupId == null || userId.isEmpty) return false;
    try {
      final membership = await _membership(groupId, userId);
      return _isFacilitatorRole(membership?.userRole);
    } catch (e) {
      debugPrint('Error checking group facilitator: $e');
      return false;
    }
  }

  Future<CcGroupMembersRow?> _membership(int groupId, String userId) async {
    final rows = await CcGroupMembersTable().queryRows(
      queryFn: (q) => q.eq('group_id', groupId).eq('user_id', userId),
    );
    return rows.isNotEmpty ? rows.first : null;
  }

  bool _isFacilitatorRole(String? role) =>
      UserRole.fromString(role) == UserRole.groupManager;

  Future<Map<int, int>> _replyCountsFor({
    required String userId,
    required bool isFacilitator,
    required List<int> sharingIds,
    required List<CcExperienceReadsRow> reads,
  }) async {
    if (sharingIds.isEmpty) return {};
    final attention = await _replyAttention(
      userId: userId,
      sharingIds: sharingIds,
      facilitatorSharingIds: isFacilitator ? sharingIds.toSet() : const {},
      readAtBySharing: {
        for (final read in reads) read.experienceId: read.readAt,
      },
    );
    return {
      for (final entry in attention.unseen.entries) entry.key: entry.value.count,
    };
  }

  Future<FacilitatorCommentSnapshot> _replyAttention({
    required String userId,
    required List<int> sharingIds,
    required Set<int> facilitatorSharingIds,
    required Map<int, DateTime> readAtBySharing,
  }) async {
    if (sharingIds.isEmpty) return FacilitatorCommentSnapshot.empty;
    final rows = await SupaFlow.client
        .from('cc_comments')
        .select('id, parent_id, sharing_id, user_id, created_at')
        .inFilter('sharing_id', sharingIds);

    final comments = <SharingComment>[];
    for (final row in rows) {
      final sharingId = _asInt(row['sharing_id']);
      final createdAt = _asDateTime(row['created_at']);
      if (sharingId == null || createdAt == null) continue;
      comments.add(SharingComment(
        id: _asInt(row['id']),
        parentId: _asInt(row['parent_id']),
        sharingId: sharingId,
        createdAt: createdAt,
        userId: row['user_id']?.toString(),
      ));
    }

    final counted = <SharingComment>[];
    for (final sharingId in sharingIds) {
      final onMessage = comments.where((comment) => comment.sharingId == sharingId);
      if (facilitatorSharingIds.contains(sharingId)) {
        counted.addAll(onMessage);
        continue;
      }
      final visibleIds = commentIdsVisibleToMember(
        viewerId: userId,
        comments: onMessage,
      );
      counted.addAll(onMessage.where((comment) => visibleIds.contains(comment.id)));
    }

    return FacilitatorCommentSnapshot(
      unseen: replyAttentionBySharing(
        viewerId: userId,
        readAtBySharing: readAtBySharing,
        comments: counted,
      ),
      totals: commentCountBySharing(counted),
    );
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return null;
  }

  DateTime? _asDateTime(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value);
    return null;
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

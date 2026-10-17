/// A comment used to decide whether a group message still needs a facilitator.
class SharingComment {
  const SharingComment({
    required this.sharingId,
    required this.createdAt,
    this.userId,
  });

  final int sharingId;
  final DateTime createdAt;
  final String? userId;
}

/// Every comment on a message, including the viewer's own.
Map<int, int> commentCountBySharing(Iterable<SharingComment> comments) {
  final counts = <int, int>{};
  for (final comment in comments) {
    counts[comment.sharingId] = (counts[comment.sharingId] ?? 0) + 1;
  }
  return counts;
}

/// Unseen replies from other people, plus the total comment count on each message.
class FacilitatorCommentSnapshot {
  const FacilitatorCommentSnapshot({
    this.unseen = const {},
    this.totals = const {},
  });

  final Map<int, ReplyAttention> unseen;
  final Map<int, int> totals;

  static const empty = FacilitatorCommentSnapshot();
}

/// Replies from other people that arrived after the viewer last opened the message.
class ReplyAttention {
  const ReplyAttention({required this.count, required this.latestAt});

  final int count;
  final DateTime latestAt;
}

enum CommentListOrder { conversation, oldestFirst, newestFirst }

/// Next order when the date icon is tapped: conversation, oldest first, newest first.
CommentListOrder cycleCommentListOrder(CommentListOrder current) {
  return switch (current) {
    CommentListOrder.conversation => CommentListOrder.oldestFirst,
    CommentListOrder.oldestFirst => CommentListOrder.newestFirst,
    CommentListOrder.newestFirst => CommentListOrder.conversation,
  };
}

/// A reply from someone else that arrived after [readAt]. The viewer's own
/// comments stay in the read group. With no previous open, every other comment
/// is new.
bool commentIsNewSinceRead({
  required String? authorId,
  required String viewerId,
  required DateTime? createdAt,
  required DateTime? readAt,
}) {
  if (createdAt == null || authorId == viewerId) return false;
  if (readAt == null) return true;
  return createdAt.isAfter(readAt);
}

/// Comments by someone other than [viewerId], posted after that person's last
/// open. A message with no read time counts every other person's comment.
Map<int, ReplyAttention> replyAttentionBySharing({
  required String viewerId,
  required Map<int, DateTime> readAtBySharing,
  required Iterable<SharingComment> comments,
}) {
  final counts = <int, int>{};
  final latest = <int, DateTime>{};

  for (final comment in comments) {
    if (comment.userId == viewerId) continue;
    final readAt = readAtBySharing[comment.sharingId];
    if (readAt != null && !comment.createdAt.isAfter(readAt)) continue;

    counts[comment.sharingId] = (counts[comment.sharingId] ?? 0) + 1;
    final previous = latest[comment.sharingId];
    if (previous == null || comment.createdAt.isAfter(previous)) {
      latest[comment.sharingId] = comment.createdAt;
    }
  }

  return {
    for (final id in counts.keys)
      id: ReplyAttention(count: counts[id]!, latestAt: latest[id]!),
  };
}

/// A message still needs attention when someone else replied after the last
/// open. A read with no new replies does not, even if it was published before
/// the viewer joined. A never-opened message counts only when it was published
/// after they joined.
bool announcementNeedsAttention({
  required bool hasRead,
  required bool publishedAfterJoin,
  required int newReplies,
}) {
  if (newReplies > 0) return true;
  if (hasRead) return false;
  return publishedAfterJoin;
}

/// Messages that were never opened, plus messages that already were opened
/// but have new replies. Each message counts once.
int messagesNeedingAttention({
  required Iterable<int> messageIds,
  required Set<int> readIds,
  required Map<int, int> replyCounts,
}) {
  return messageIds
      .where((id) => !readIds.contains(id) || (replyCounts[id] ?? 0) > 0)
      .length;
}

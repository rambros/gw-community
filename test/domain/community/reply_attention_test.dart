import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/reply_attention.dart';

void main() {
  final earlier = DateTime.utc(2026, 10, 1, 12);
  final opened = DateTime.utc(2026, 10, 1, 13);
  final later = DateTime.utc(2026, 10, 1, 14);

  SharingComment comment({
    required int sharingId,
    required DateTime createdAt,
    String? userId = 'member',
    int? id,
    int? parentId,
  }) {
    return SharingComment(
      id: id,
      parentId: parentId,
      sharingId: sharingId,
      createdAt: createdAt,
      userId: userId,
    );
  }

  group('cycleCommentListOrder', () {
    test('walks conversation, oldest, newest, then back', () {
      expect(cycleCommentListOrder(CommentListOrder.conversation), CommentListOrder.oldestFirst);
      expect(cycleCommentListOrder(CommentListOrder.oldestFirst), CommentListOrder.newestFirst);
      expect(cycleCommentListOrder(CommentListOrder.newestFirst), CommentListOrder.conversation);
    });
  });

  group('commentIsNewSinceRead', () {
    test('marks another person after the last open', () {
      expect(
        commentIsNewSinceRead(
          authorId: 'member',
          viewerId: 'facilitator',
          createdAt: later,
          readAt: opened,
        ),
        isTrue,
      );
    });

    test('keeps an older comment and the viewer\'s own comment as read', () {
      expect(
        commentIsNewSinceRead(
          authorId: 'member',
          viewerId: 'facilitator',
          createdAt: earlier,
          readAt: opened,
        ),
        isFalse,
      );
      expect(
        commentIsNewSinceRead(
          authorId: 'facilitator',
          viewerId: 'facilitator',
          createdAt: later,
          readAt: opened,
        ),
        isFalse,
      );
    });

    test('treats every other comment as new when the message was never opened', () {
      expect(
        commentIsNewSinceRead(
          authorId: 'member',
          viewerId: 'facilitator',
          createdAt: earlier,
          readAt: null,
        ),
        isTrue,
      );
    });
  });

  group('replyAttentionBySharing', () {
    test('counts another person only after the message was opened', () {
      final attention = replyAttentionBySharing(
        viewerId: 'facilitator',
        readAtBySharing: {1: opened},
        comments: [
          comment(sharingId: 1, createdAt: earlier),
          comment(sharingId: 1, createdAt: later),
          comment(sharingId: 1, createdAt: later, userId: 'facilitator'),
        ],
      );

      expect(attention[1]?.count, 1);
      expect(attention[1]?.latestAt, later);
    });

    test('counts every other person when the message was never opened', () {
      final attention = replyAttentionBySharing(
        viewerId: 'facilitator',
        readAtBySharing: const {},
        comments: [
          comment(sharingId: 4, createdAt: earlier),
          comment(sharingId: 4, createdAt: later, userId: 'facilitator'),
        ],
      );

      expect(attention[4]?.count, 1);
    });
  });

  group('commentIdsVisibleToMember', () {
    test('includes the member comment and replies under it', () {
      final visible = commentIdsVisibleToMember(
        viewerId: 'member',
        comments: [
          comment(sharingId: 1, createdAt: earlier, userId: 'member', id: 10),
          comment(sharingId: 1, createdAt: later, userId: 'facilitator', id: 11, parentId: 10),
          comment(sharingId: 1, createdAt: later, userId: 'other', id: 12),
        ],
      );

      expect(visible, {10, 11});
    });

    test('counts only a reply in the member thread', () {
      final comments = [
        comment(sharingId: 1, createdAt: earlier, userId: 'member', id: 10),
        comment(sharingId: 1, createdAt: later, userId: 'facilitator', id: 11, parentId: 10),
        comment(sharingId: 1, createdAt: later, userId: 'other', id: 12),
      ];
      final visible = commentIdsVisibleToMember(viewerId: 'member', comments: comments);
      final attention = replyAttentionBySharing(
        viewerId: 'member',
        readAtBySharing: {1: opened},
        comments: comments.where((item) => visible.contains(item.id)),
      );

      expect(attention[1]?.count, 1);
    });
  });

  group('commentCountBySharing', () {
    test('counts the viewer\'s own comments', () {
      final counts = commentCountBySharing([
        comment(sharingId: 88, createdAt: earlier, userId: 'facilitator'),
        comment(sharingId: 88, createdAt: later),
      ]);

      expect(counts[88], 2);
    });
  });

  group('announcementNeedsAttention', () {
    test('keeps a read message read when it was published before the viewer joined', () {
      expect(
        announcementNeedsAttention(
          hasRead: true,
          publishedAfterJoin: false,
          newReplies: 0,
        ),
        isFalse,
      );
    });

    test('shows a read message again when someone else replied', () {
      expect(
        announcementNeedsAttention(
          hasRead: true,
          publishedAfterJoin: false,
          newReplies: 2,
        ),
        isTrue,
      );
    });

    test('ignores a never-opened message from before the viewer joined', () {
      expect(
        announcementNeedsAttention(
          hasRead: false,
          publishedAfterJoin: false,
          newReplies: 0,
        ),
        isFalse,
      );
    });
  });

  group('messagesNeedingAttention', () {
    test('counts an unread message with replies once', () {
      final total = messagesNeedingAttention(
        messageIds: const [1, 2, 3],
        readIds: const {2},
        replyCounts: const {1: 4, 2: 2},
      );

      // 1 never opened, 2 opened but has replies, 3 never opened.
      expect(total, 3);
    });

    test('leaves a read message with no new replies out', () {
      final total = messagesNeedingAttention(
        messageIds: const [7],
        readIds: const {7},
        replyCounts: const {},
      );

      expect(total, 0);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:gw_community/domain/community/comment_delete.dart';

void main() {
  test('a comment with a reply cannot be deleted first', () {
    expect(
      commentHasReplies(commentId: 8, parentIds: [null, 8, 3]),
      isTrue,
    );
    expect(
      commentHasReplies(commentId: 4, parentIds: [null, 8]),
      isFalse,
    );
  });

  test('the parent comment foreign key is the reply block', () {
    const error = 'violates foreign key constraint "cc_comments_parent_id_fkey"';
    expect(commentDeleteBlockedByReplies(error), isTrue);
    expect(commentDeleteBlockedByReplies('network down'), isFalse);
  });
}

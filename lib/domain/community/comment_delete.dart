enum CommentDeleteOutcome { deleted, blockedByReplies, failed }

/// A reply stores the comment it answers in `parent_id`. Deleting that
/// comment fails while any reply still points at it.
bool commentHasReplies({
  required int commentId,
  required Iterable<int?> parentIds,
}) {
  return parentIds.contains(commentId);
}

bool commentDeleteBlockedByReplies(Object error) {
  return error.toString().contains('cc_comments_parent_id_fkey');
}

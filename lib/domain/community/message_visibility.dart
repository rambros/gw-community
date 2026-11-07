/// Who can see a group message. Facilitator messages stay with the author and
/// the facilitators of that group. A private message stays with its recipient.
bool canSeeGroupMessage({
  required String? audience,
  required String? recipientUserId,
  required String? authorUserId,
  required String viewerId,
  required bool viewerIsFacilitator,
}) {
  if (audience == 'facilitators') {
    return authorUserId == viewerId || viewerIsFacilitator;
  }
  if (recipientUserId == null || recipientUserId.isEmpty) return true;
  return recipientUserId == viewerId || authorUserId == viewerId;
}

/// The member who wrote to the facilitators sees every reply on that message.
/// A facilitator comment on that thread has no parent, so the usual member
/// filter (own comments and replies under them) would hide it.
bool authorSeesFacilitatorReplies({
  required String? audience,
  required String? authorUserId,
  required String viewerId,
}) {
  return audience == 'facilitators' &&
      authorUserId != null &&
      authorUserId.isNotEmpty &&
      authorUserId == viewerId;
}

/// A message written to this facilitator: a member's note to the facilitators,
/// or a private message that names them.
bool isMessageForFacilitator({
  required String? audience,
  required String? recipientUserId,
  required String? authorUserId,
  required String viewerId,
}) {
  if (authorUserId == viewerId) return false;
  if (audience == 'facilitators') return true;
  return recipientUserId == viewerId;
}

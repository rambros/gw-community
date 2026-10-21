/// Who may see a community event.
///
/// `everyone` is visible to any signed-in member. `group_only` (and a blank
/// visibility on an event that belongs to a group) is visible to members of
/// that group. The facilitator keeps access to the event they created.
bool eventVisibleToUser({
  required String? visibility,
  required int? groupId,
  required String? facilitatorId,
  required String? userId,
  required Set<int> memberGroupIds,
}) {
  if (userId != null && userId.isNotEmpty && facilitatorId == userId) {
    return true;
  }

  final access = visibility?.trim();
  if (access == 'everyone') return true;
  if (groupId == null) {
    return access == null || access.isEmpty;
  }
  if (access == null || access.isEmpty || access == 'group_only') {
    return memberGroupIds.contains(groupId);
  }
  return false;
}

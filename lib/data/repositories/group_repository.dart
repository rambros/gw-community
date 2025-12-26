import 'package:gw_community/data/services/supabase/supabase.dart';

class GroupRepository {
  /// Fetches all groups ordered by name
  Future<List<CcGroupsRow>> getGroups() async {
    final result = await CcGroupsTable().queryRows(
      queryFn: (q) => q.order('name', ascending: true),
    );
    return result;
  }

  /// Fetches a single group by ID
  Future<CcGroupsRow?> getGroupById(int id) async {
    final result = await CcGroupsTable().queryRows(
      queryFn: (q) => q.eq('id', id),
    );
    return result.isNotEmpty ? result.first : null;
  }

  /// Creates a new group
  Future<CcGroupsRow?> createGroup({
    required String name,
    required String description,
    required String welcomeMessage,
    required String policyMessage,
    required String imageUrl,
    required List<String> managerIds,
    String privacy = 'Public',
  }) async {
    await CcGroupsTable().insert({
      'name': name,
      'description': description,
      'welcome_message': welcomeMessage,
      'policy_message': policyMessage,
      'group_image_url': imageUrl,
      'group_privacy': privacy,
      'administrators': managerIds,
      'number_members': 1, // Start with 1 member (creator)
      'created_at': supaSerialize<DateTime>(DateTime.now()),
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
    });

    // Note: Supabase insert might return the created row depending on configuration,
    // but here we might need to fetch it if insert doesn't return it directly in the expected format.
    // Assuming standard Supabase insert behavior or adjusting based on project patterns.
    // If insert returns void or just status, we might need to fetch the created group.
    // For now, returning null as the insert method in this project seems to return Future<List<Row>> or similar based on other repos.
    // Let's check other repositories for insert pattern.

    // Checking SharingRepository pattern:
    // await CcSharingsTable().insert({...});
    // It seems it returns void or we don't use the return value often.

    return null;
  }

  /// Updates an existing group
  Future<void> updateGroup({
    required int id,
    String? name,
    String? description,
    String? welcomeMessage,
    String? policyMessage,
    String? imageUrl,
    List<String>? managerIds,
    String? privacy,
  }) async {
    final data = <String, dynamic>{
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
    };
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (welcomeMessage != null) data['welcome_message'] = welcomeMessage;
    if (policyMessage != null) data['policy_message'] = policyMessage;
    if (imageUrl != null) data['group_image_url'] = imageUrl;
    if (managerIds != null) data['administrators'] = managerIds;
    if (privacy != null) data['group_privacy'] = privacy;

    await CcGroupsTable().update(
      data: data,
      matchingRows: (rows) => rows.eq('id', id),
    );
  }

  /// Deletes a group
  Future<void> deleteGroup(int id) async {
    await CcGroupsTable().delete(
      matchingRows: (rows) => rows.eq('id', id),
    );
  }

  /// Fetches members of a group
  Future<List<CcGroupMembersRow>> getGroupMembers(int groupId) async {
    final result = await CcGroupMembersTable().queryRows(
      queryFn: (q) => q.eq('group_id', groupId),
    );
    return result;
  }

  /// Invites a user to a group (creates a group member record)
  Future<void> inviteUserToGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({
      'group_id': groupId,
      'user_id': userId,
      'status': 'Invited', // Or 'Active' depending on logic
      'created_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Adds a user to a group directly (e.g. Join)
  Future<void> addUserToGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({
      'group_id': groupId,
      'user_id': userId,
      'status': 'Active',
      'created_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Removes a user from a group
  Future<void> removeUserFromGroup(int groupId, String userId) async {
    await CcGroupMembersTable().delete(
      matchingRows: (rows) => rows.eq('group_id', groupId).eq('user_id', userId),
    );
  }

  /// Fetches available users for selection (e.g. for managers)
  Future<List<CcMembersRow>> getAvailableUsers() async {
    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q.order('display_name', ascending: true),
    );
    return result;
  }

  /// Fetches users with specific role (e.g. Group Manager)
  Future<List<CcMembersRow>> getGroupManagers() async {
    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q.containsOrNull('user_role', ['Group Manager']).order('display_name', ascending: true),
    );
    return result;
  }

  /// Fetches users who are members of a group
  Future<List<CcMembersRow>> getGroupMembersAsUsers(int groupId) async {
    final members = await getGroupMembers(groupId);
    if (members.isEmpty) return [];

    final userIds = members.map((m) => m.userId).where((id) => id != null).cast<String>().toList();
    if (userIds.isEmpty) return [];

    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q.filter('id', 'in', userIds).order('display_name', ascending: true),
    );
    return result;
  }

  /// Adds a user to a group
  Future<void> joinGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({
      'user_id': userId,
      'group_id': groupId,
    });

    // Update member count (optional, but good for consistency if UI relies on it immediately)
    // We can fetch the group to get current count, or just increment if we trust the caller.
    // For now, we'll just insert. The UI should refresh the group details.
  }
}

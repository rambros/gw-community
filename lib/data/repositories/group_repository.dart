import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

class GroupRepository {
  /// Fetches all groups ordered by name
  Future<List<CcGroupsRow>> getGroups() async {
    final result = await CcGroupsTable().queryRows(queryFn: (q) => q.order('name', ascending: true));
    return result;
  }

  /// Fetches a single group by ID
  Future<CcGroupsRow?> getGroupById(int id) async {
    final result = await CcGroupsTable().queryRows(queryFn: (q) => q.eq('id', id));
    return result.isNotEmpty ? result.first : null;
  }

  /// Creates a new group
  Future<CcGroupsRow?> createGroup({
    required String name,
    required String description,
    required String welcomeMessage,
    required String policyMessage,
    required String imageUrl,
    String privacy = 'Public',
  }) async {
    return await CcGroupsTable().insert({
      'name': name,
      'description': description,
      'welcome_message': welcomeMessage,
      'policy_message': policyMessage,
      'group_image_url': imageUrl,
      'group_privacy': privacy,
      'number_members': 1, // Start with 1 member (creator)
      'created_at': supaSerialize<DateTime>(DateTime.now()),
      'updated_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Updates an existing group
  Future<void> updateGroup({
    required int id,
    String? name,
    String? description,
    String? welcomeMessage,
    String? policyMessage,
    String? imageUrl,
    String? privacy,
  }) async {
    final data = <String, dynamic>{'updated_at': supaSerialize<DateTime>(DateTime.now())};
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (welcomeMessage != null) data['welcome_message'] = welcomeMessage;
    if (policyMessage != null) data['policy_message'] = policyMessage;
    if (imageUrl != null) data['group_image_url'] = imageUrl;
    if (privacy != null) data['group_privacy'] = privacy;

    await CcGroupsTable().update(data: data, matchingRows: (rows) => rows.eq('id', id));
  }

  /// Deletes a group
  Future<void> deleteGroup(int id) async {
    await CcGroupsTable().delete(matchingRows: (rows) => rows.eq('id', id));
  }

  /// Fetches members of a group
  Future<List<CcGroupMembersRow>> getGroupMembers(int groupId) async {
    final result = await CcGroupMembersTable().queryRows(queryFn: (q) => q.eq('group_id', groupId));
    return result;
  }

  /// Invites a user to a group (creates a group member record)
  Future<void> inviteUserToGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({
      'group_id': groupId,
      'user_id': userId,
      'created_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Adds a user to a group directly (e.g. Join)
  Future<void> addUserToGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({
      'group_id': groupId,
      'user_id': userId,
      'created_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Removes a user from a group
  Future<void> removeUserFromGroup(int groupId, String userId) async {
    await CcGroupMembersTable().delete(matchingRows: (rows) => rows.eq('group_id', groupId).eq('user_id', userId));
  }

  /// Fetches available users for selection (e.g. for managers)
  Future<List<CcMembersRow>> getAvailableUsers() async {
    final result = await CcMembersTable().queryRows(queryFn: (q) => q.order('display_name', ascending: true));
    return result;
  }

  /// Fetches potential facilitators (Admin or Group Manager role)
  Future<List<CcMembersRow>> getFacilitatorCandidates() async {
    final result = await CcMembersTable().queryRows(queryFn: (q) => q.order('display_name', ascending: true));

    // Filter in Dart to ensure specific roles are matched correctly
    return result.where((m) {
      return UserRole.isAdminOrGroupManager(m.userRole);
    }).toList();
  }

  /// Fetches users with GROUP_MANAGER role
  Future<List<CcMembersRow>> getGroupManagers() async {
    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q.containsOrNull('user_role', [UserRole.groupManager.value, 'Manager', 'group_manager']).order(
          'display_name',
          ascending: true),
    );
    return result;
  }

  /// Fetches users who are members of a group
  Future<List<CcMembersRow>> getGroupMembersAsUsers(int groupId) async {
    final members = await getGroupMembers(groupId);
    if (members.isEmpty) return [];

    final authUserIds = <String>[];
    final legacyIds = <int>[];

    for (final m in members) {
      if (m.userId == null) continue;
      // Basic UUID check (36 chars)
      if (m.userId!.length == 36) {
        authUserIds.add(m.userId!);
      } else {
        // Try parse as legacy ID
        final id = int.tryParse(m.userId!);
        if (id != null) legacyIds.add(id);
      }
    }

    final results = <CcMembersRow>[];

    // Fetch by Auth User ID (Standard)
    if (authUserIds.isNotEmpty) {
      final byAuth = await CcMembersTable().queryRows(
        queryFn: (q) => q.filter('auth_user_id', 'in', authUserIds),
      );
      results.addAll(byAuth);
    }

    // Fetch by Legacy ID (Migrated users)
    if (legacyIds.isNotEmpty) {
      final byId = await CcMembersTable().queryRows(
        queryFn: (q) => q.filter('id', 'in', legacyIds),
      );
      results.addAll(byId);
    }

    // Deduplicate (in case user found by both?? unlikely but safe)
    final seenIds = <String>{}; // Changed from <int>{} to <String>{}
    final uniqueResults = <CcMembersRow>[];
    for (final user in results) {
      if (seenIds.add(user.id)) {
        uniqueResults.add(user);
      }
    }

    return uniqueResults..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));
  }

  /// Adds a user to a group
  Future<void> joinGroup(int groupId, String userId) async {
    await CcGroupMembersTable().insert({'user_id': userId, 'group_id': groupId});
  }

  /// Checks if a user is a member of a group
  Future<bool> isUserMemberOfGroup(int groupId, String userId) async {
    final result = await CcGroupMembersTable().queryRows(
      queryFn: (q) => q.eq('group_id', groupId).eq('user_id', userId),
    );
    return result.isNotEmpty;
  }

  /// Fetches users who are NOT members of a specific group (for invitations)
  Future<List<CcMembersRow>> getUsersNotInGroup(int groupId) async {
    final groupMembers = await getGroupMembers(groupId);
    final memberUserIds = <String>{};

    for (final member in groupMembers) {
      if (member.userId != null && member.userId!.isNotEmpty) {
        memberUserIds.add(member.userId!);
      }
    }

    final allUsers = await CcMembersTable().queryRows(queryFn: (q) => q.order('display_name', ascending: true));

    return allUsers.where((user) {
      final userAuthId = user.authUserId;
      if (userAuthId == null || userAuthId.isEmpty) return false;
      return !memberUserIds.contains(userAuthId);
    }).toList();
  }

  /// Searches for available users by name or email (Server-side)
  Future<List<CcMembersRow>> searchAvailableUsers(String query, {int limit = 50}) async {
    if (query.trim().isEmpty) return [];

    final result = await CcMembersTable().queryRows(
      queryFn: (q) =>
          q.or('display_name.ilike.%$query%,email.ilike.%$query%').order('display_name', ascending: true).limit(limit),
    );
    return result;
  }

  /// Adds a user to a group with a specific role
  Future<void> addMemberWithRole(int groupId, String userId, String role) async {
    await CcGroupMembersTable().insert({
      'group_id': groupId,
      'user_id': userId,
      'user_role': role,
      'created_at': supaSerialize<DateTime>(DateTime.now()),
    });
  }

  /// Updates a member's role
  Future<void> updateMemberRole(int groupId, String userId, String role) async {
    await CcGroupMembersTable().update(
      data: {'user_role': role},
      matchingRows: (rows) => rows.eq('group_id', groupId).eq('user_id', userId),
    );
  }

  // ========== GROUP RESOURCES MANAGEMENT ==========

  /// Fetches resources associated with a group (public + exclusive for members)
  Future<List<Map<String, dynamic>>> getGroupResources(int groupId, String userId) async {
    final isMember = await isUserMemberOfGroup(groupId, userId);
    if (!isMember) return [];

    final result = await SupaFlow.client
        .from('cc_group_resources')
        .select('id, visibility, featured, portal_item_id, portal_item!inner(*)')
        .eq('group_id', groupId)
        .order('featured', ascending: false);

    return List<Map<String, dynamic>>.from(result as List);
  }

  /// Adds a resource to a group
  Future<void> addResourceToGroup({
    required int groupId,
    required int portalItemId,
    required String visibility, // 'public' or 'exclusive'
    required String addedBy,
    bool featured = false,
  }) async {
    await SupaFlow.client.from('cc_group_resources').insert({
      'group_id': groupId,
      'portal_item_id': portalItemId,
      'visibility': visibility,
      'featured': featured,
      'added_by': addedBy,
    });
  }

  /// Removes a resource from a group
  Future<void> removeResourceFromGroup(int groupId, int portalItemId) async {
    await SupaFlow.client
        .from('cc_group_resources')
        .delete()
        .eq('group_id', groupId)
        .eq('portal_item_id', portalItemId);
  }

  /// Updates resource visibility or featured status
  Future<void> updateGroupResource({
    required int groupId,
    required int portalItemId,
    String? visibility,
    bool? featured,
  }) async {
    final data = <String, dynamic>{};
    if (visibility != null) data['visibility'] = visibility;
    if (featured != null) data['featured'] = featured;

    if (data.isEmpty) return;

    await SupaFlow.client
        .from('cc_group_resources')
        .update(data)
        .eq('group_id', groupId)
        .eq('portal_item_id', portalItemId);
  }

  // ========== GROUP JOURNEYS MANAGEMENT ==========

  /// Fetches journeys associated with a group (public + exclusive for members)
  Future<List<Map<String, dynamic>>> getGroupJourneys(int groupId, String userId) async {
    final isMember = await isUserMemberOfGroup(groupId, userId);
    if (!isMember) return [];

    final result = await SupaFlow.client
        .from('cc_group_journeys')
        .select('id, visibility, featured, journey_id, cc_journeys!inner(*)')
        .eq('group_id', groupId)
        .order('featured', ascending: false);

    return List<Map<String, dynamic>>.from(result as List);
  }

  /// Adds a journey to a group
  Future<void> addJourneyToGroup({
    required int groupId,
    required int journeyId,
    required String visibility, // 'public' or 'exclusive'
    required String addedBy,
    bool featured = false,
  }) async {
    await SupaFlow.client.from('cc_group_journeys').insert({
      'group_id': groupId,
      'journey_id': journeyId,
      'visibility': visibility,
      'featured': featured,
      'added_by': addedBy,
    });
  }

  /// Removes a journey from a group
  Future<void> removeJourneyFromGroup(int groupId, int journeyId) async {
    await SupaFlow.client.from('cc_group_journeys').delete().eq('group_id', groupId).eq('journey_id', journeyId);
  }

  /// Updates journey visibility or featured status
  Future<void> updateGroupJourney({
    required int groupId,
    required int journeyId,
    String? visibility,
    bool? featured,
  }) async {
    final data = <String, dynamic>{};
    if (visibility != null) data['visibility'] = visibility;
    if (featured != null) data['featured'] = featured;

    if (data.isEmpty) return;

    await SupaFlow.client.from('cc_group_journeys').update(data).eq('group_id', groupId).eq('journey_id', journeyId);
  }
}

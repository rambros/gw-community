import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';

/// Membership rows per request. Stays under the API's 1000-row cap.
const int _groupMemberPageSize = 500;

/// Profiles per request. A single `in.(uuid, …)` for the whole group
/// builds a URL the API rejects (400) once the group passes ~1000 people.
const int _memberProfileChunkSize = 40;

const int _memberProfileConcurrency = 3;

class GroupRepository {
  /// Fetches all groups ordered by name
  Future<List<CcGroupsRow>> getGroups() async {
    final result = await CcGroupsTable()
        .queryRows(queryFn: (q) => q.order('name', ascending: true));
    return result;
  }

  /// Groups this auth user belongs to. [authUserId] is cc_group_members.user_id.
  Future<List<CcGroupsRow>> getMyGroups(String authUserId) async {
    final response = await SupaFlow.client.rpc(
      'get_my_groups',
      params: {'user_input': authUserId},
    );
    if (response is List) {
      return response
          .map((row) => CcGroupsRow(row as Map<String, dynamic>))
          .toList();
    }
    return [];
  }

  /// Fetches a single group by ID
  Future<CcGroupsRow?> getGroupById(int id) async {
    final result =
        await CcGroupsTable().queryRows(queryFn: (q) => q.eq('id', id));
    return result.isNotEmpty ? result.first : null;
  }

  /// Creates a new group
  Future<CcGroupsRow?> createGroup({
    required String name,
    required String description,
    required String moreInformation,
    required String imageUrl,
    String privacy = 'Public',
  }) async {
    return await CcGroupsTable().insert({
      'name': name,
      'description': description,
      'more_information': moreInformation,
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
    String? moreInformation,
    String? imageUrl,
    String? privacy,
  }) async {
    final data = <String, dynamic>{
      'updated_at': supaSerialize<DateTime>(DateTime.now())
    };
    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (moreInformation != null) data['more_information'] = moreInformation;
    if (imageUrl != null) data['group_image_url'] = imageUrl;
    if (privacy != null) data['group_privacy'] = privacy;

    await CcGroupsTable()
        .update(data: data, matchingRows: (rows) => rows.eq('id', id));
  }

  /// Deletes a group
  Future<void> deleteGroup(int id) async {
    await CcGroupsTable().delete(matchingRows: (rows) => rows.eq('id', id));
  }

  /// Fetches every membership link of a group, one page at a time.
  Future<List<CcGroupMembersRow>> getGroupMembers(int groupId) async {
    final all = <CcGroupMembersRow>[];
    var from = 0;
    int? previousPageFirstId;

    while (true) {
      final response = await SupaFlow.client
          .from('cc_group_members')
          .select()
          .eq('group_id', groupId)
          .order('id', ascending: true)
          .range(from, from + _groupMemberPageSize - 1);
      final page = _groupMemberRows(response);
      if (page.isEmpty) break;
      // Range ignored by the server would repeat the same page forever.
      if (previousPageFirstId != null && page.first.id == previousPageFirstId) {
        break;
      }

      all.addAll(page);
      previousPageFirstId = page.first.id;
      if (page.length < _groupMemberPageSize) break;
      from += page.length;
    }

    return all;
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
    await CcGroupMembersTable().delete(
        matchingRows: (rows) =>
            rows.eq('group_id', groupId).eq('user_id', userId));
  }

  /// Fetches available users for selection (e.g. for managers)
  Future<List<CcMembersRow>> getAvailableUsers() async {
    final result = await CcMembersTable()
        .queryRows(queryFn: (q) => q.order('display_name', ascending: true));
    return result;
  }

  /// Fetches potential facilitators (Admin or Group Manager role)
  Future<List<CcMembersRow>> getFacilitatorCandidates() async {
    final result = await CcMembersTable()
        .queryRows(queryFn: (q) => q.order('display_name', ascending: true));

    // Filter in Dart to ensure specific roles are matched correctly
    return result.where((m) {
      return UserRole.isAdminOrGroupManager(m.userRole);
    }).toList();
  }

  /// Fetches users with GROUP_MANAGER role
  Future<List<CcMembersRow>> getGroupManagers() async {
    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q.containsOrNull('user_role', [
        UserRole.groupManager.value,
        'Manager',
        'group_manager'
      ]).order('display_name', ascending: true),
    );
    return result;
  }

  /// Fetches users who are members of a group.
  ///
  /// [links] skips a second membership read when the caller already has it.
  /// [onProgress] receives the profiles loaded so far, after each page.
  /// [onlyActive] keeps facilitators and drops members who never opened the app.
  Future<List<CcMembersRow>> getGroupMembersAsUsers(
    int groupId, {
    List<CcGroupMembersRow>? links,
    void Function(List<CcMembersRow> loaded)? onProgress,
    bool onlyActive = false,
  }) async {
    final members = links ?? await getGroupMembers(groupId);
    if (members.isEmpty) return [];

    final managerAuthIds = <String>[];
    final memberAuthIds = <String>[];
    final legacyIds = <String>[];

    for (final member in members) {
      final userId = member.userId;
      if (userId == null || userId.isEmpty) continue;
      if (userId.length != 36) {
        legacyIds.add(userId);
        continue;
      }
      if (_isManagerRole(member.userRole)) {
        managerAuthIds.add(userId);
      } else {
        memberAuthIds.add(userId);
      }
    }

    final loaded = <CcMembersRow>[];

    Future<void> publish(List<CcMembersRow> page) async {
      if (page.isEmpty) return;
      loaded.addAll(page);
      onProgress?.call(_uniqueMembersById(loaded));
    }

    if (managerAuthIds.isNotEmpty) {
      await _forEachChunk(
        managerAuthIds,
        _memberProfileChunkSize,
        _memberProfileConcurrency,
        (chunk) => _membersWhere('auth_user_id', chunk),
        publish,
      );
    }

    if (memberAuthIds.isNotEmpty) {
      await _forEachChunk(
        memberAuthIds,
        _memberProfileChunkSize,
        _memberProfileConcurrency,
        (chunk) => _membersWhere(
          'auth_user_id',
          chunk,
          onlyActive: onlyActive,
        ),
        publish,
      );
    }

    if (legacyIds.isNotEmpty) {
      await _forEachChunk(
        legacyIds,
        _memberProfileChunkSize,
        _memberProfileConcurrency,
        (chunk) => _membersWhere('id', chunk),
        publish,
      );
    }

    return _uniqueMembersById(loaded);
  }

  /// Profiles for the given auth user ids, fetched in small pages.
  Future<List<CcMembersRow>> getMembersByAuthUserIds(
      List<String> authUserIds) async {
    if (authUserIds.isEmpty) return [];
    final loaded = <CcMembersRow>[];
    await _forEachChunk(
      authUserIds,
      _memberProfileChunkSize,
      _memberProfileConcurrency,
      (chunk) => _membersWhere('auth_user_id', chunk),
      loaded.addAll,
    );
    return _uniqueMembersById(loaded);
  }

  bool _isManagerRole(String? role) =>
      role == 'GROUP_MANAGER' || role == 'Manager' || role == 'group_manager';

  Future<void> _forEachChunk(
    List<String> items,
    int chunkSize,
    int concurrency,
    Future<List<CcMembersRow>> Function(List<String> chunk) fetch,
    void Function(List<CcMembersRow> page) onPage,
  ) async {
    final chunks = <List<String>>[];
    for (var start = 0; start < items.length; start += chunkSize) {
      final end =
          start + chunkSize < items.length ? start + chunkSize : items.length;
      chunks.add(items.sublist(start, end));
    }

    for (var start = 0; start < chunks.length; start += concurrency) {
      final end = start + concurrency < chunks.length
          ? start + concurrency
          : chunks.length;
      final pages = await Future.wait(chunks.sublist(start, end).map(fetch));
      for (final page in pages) {
        onPage(page);
      }
    }
  }

  Future<List<CcMembersRow>> _membersWhere(
    String column,
    List<String> ids, {
    bool onlyActive = false,
  }) async {
    var query =
        SupaFlow.client.from('cc_members').select().inFilter(column, ids);
    if (onlyActive) {
      query = query.not('last_access', 'is', null);
    }
    final response = await query;
    return _memberRows(response);
  }

  List<CcGroupMembersRow> _groupMemberRows(dynamic response) {
    if (response is! List) return [];
    return response
        .map((row) => CcGroupMembersRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  List<CcMembersRow> _memberRows(dynamic response) {
    if (response is! List) return [];
    return response
        .map((row) => CcMembersRow(Map<String, dynamic>.from(row as Map)))
        .toList();
  }

  List<CcMembersRow> _uniqueMembersById(List<CcMembersRow> members) {
    final byId = <String, CcMembersRow>{};
    for (final member in members) {
      byId[member.id] = member;
    }
    final unique = byId.values.toList()
      ..sort((a, b) => (a.displayName ?? '').compareTo(b.displayName ?? ''));
    return unique;
  }

  /// Adds a user to a group
  Future<void> joinGroup(int groupId, String userId) async {
    await CcGroupMembersTable()
        .insert({'user_id': userId, 'group_id': groupId});
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

    final allUsers = await CcMembersTable()
        .queryRows(queryFn: (q) => q.order('display_name', ascending: true));

    return allUsers.where((user) {
      final userAuthId = user.authUserId;
      if (userAuthId == null || userAuthId.isEmpty) return false;
      return !memberUserIds.contains(userAuthId);
    }).toList();
  }

  /// Searches for available users by name or email (Server-side)
  Future<List<CcMembersRow>> searchAvailableUsers(String query,
      {int limit = 50}) async {
    if (query.trim().isEmpty) return [];

    final result = await CcMembersTable().queryRows(
      queryFn: (q) => q
          .or('display_name.ilike.%$query%,email.ilike.%$query%')
          .order('display_name', ascending: true)
          .limit(limit),
    );
    return result;
  }

  /// Adds a user to a group with a specific role
  Future<void> addMemberWithRole(
      int groupId, String userId, String role) async {
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
      matchingRows: (rows) =>
          rows.eq('group_id', groupId).eq('user_id', userId),
    );
  }

  // ========== GROUP RESOURCES MANAGEMENT ==========

  /// Fetches resources associated with a group (public + exclusive for members)
  Future<List<Map<String, dynamic>>> getGroupResources(
      int groupId, String userId) async {
    final isMember = await isUserMemberOfGroup(groupId, userId);
    if (!isMember) return [];

    final result = await SupaFlow.client
        .from('cc_group_resources')
        .select(
            'id, visibility, featured, portal_item_id, display_order, category, tags, portal_item!inner(*)')
        .eq('group_id', groupId)
        .isFilter('deleted_at', null)
        .order('display_order')
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
    String? category,
    List<String>? tags,
  }) async {
    await SupaFlow.client.from('cc_group_resources').upsert({
      'group_id': groupId,
      'portal_item_id': portalItemId,
      'visibility': visibility,
      'featured': featured,
      'added_by': addedBy,
      'created_by': addedBy,
      'display_order': 0,
      'category': category,
      'tags': tags,
      'deleted_at': null,
    });
  }

  /// Removes a resource from a group
  Future<void> removeResourceFromGroup(int groupId, int portalItemId) async {
    await SupaFlow.client
        .from('cc_group_resources')
        .update({'deleted_at': DateTime.now().toIso8601String()})
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
  Future<List<Map<String, dynamic>>> getGroupJourneys(
      int groupId, String userId) async {
    final isMember = await isUserMemberOfGroup(groupId, userId);
    if (!isMember) return [];

    final result = await SupaFlow.client
        .from('cc_group_journeys')
        .select(
            'id, visibility, featured, journey_id, display_order, cc_journeys!inner(*)')
        .eq('group_id', groupId)
        .isFilter('deleted_at', null)
        .order('display_order')
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
    await SupaFlow.client.from('cc_group_journeys').upsert({
      'group_id': groupId,
      'journey_id': journeyId,
      'visibility': visibility,
      'featured': featured,
      'added_by': addedBy,
      'created_by': addedBy,
      'display_order': 0,
      'deleted_at': null,
    });
  }

  /// Removes a journey from a group
  Future<void> removeJourneyFromGroup(int groupId, int journeyId) async {
    await SupaFlow.client
        .from('cc_group_journeys')
        .update({'deleted_at': DateTime.now().toIso8601String()})
        .eq('group_id', groupId)
        .eq('journey_id', journeyId);
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

    await SupaFlow.client
        .from('cc_group_journeys')
        .update(data)
        .eq('group_id', groupId)
        .eq('journey_id', journeyId);
  }
}

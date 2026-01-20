import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/member_details_sheet.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/user_avatar.dart';

/// Page for managing group members
/// Only accessible to ADMIN and GROUP_MANAGER roles
class MemberManagementPage extends StatefulWidget {
  static const routeName = 'memberManagementPage';
  static const routePath = '/memberManagement';

  final int groupId;
  final String groupName;

  const MemberManagementPage({
    super.key,
    required this.groupId,
    required this.groupName,
  });

  @override
  State<MemberManagementPage> createState() => _MemberManagementPageState();
}

class _MemberManagementPageState extends State<MemberManagementPage> {
  final GroupRepository _groupRepository = GroupRepository();
  final TextEditingController _searchController = TextEditingController();

  List<CcMembersRow> _currentMembers = [];
  List<CcMembersRow> _filteredAvailableUsers = [];

  bool _isLoadingMembers = true;
  bool _isLoadingAvailable = false;
  final Set<String> _addingUserIds = {};
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_searchUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCurrentMembers(),
    ]);
  }

  List<CcMembersRow> _facilitators = [];
  List<CcMembersRow> _regularMembers = [];

  Future<void> _loadCurrentMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      // 1. Fetch the relationships (roles)
      final groupMembersLinks = await _groupRepository.getGroupMembers(widget.groupId);

      // 2. Fetch the user profiles
      final membersUsers = await _groupRepository.getGroupMembersAsUsers(widget.groupId);

      if (mounted) {
        // 3. Identify managers
        // We look for 'GROUP_MANAGER' (or legacy variants) in the group_members table
        final managerIds = groupMembersLinks
            .where((m) => m.userRole == 'GROUP_MANAGER' || m.userRole == 'Manager' || m.userRole == 'group_manager')
            .map((m) => m.userId)
            .toSet();

        setState(() {
          _currentMembers = membersUsers; // Keep full list if needed for count

          _facilitators = membersUsers.where((m) => managerIds.contains(m.authUserId)).toList();

          _regularMembers = membersUsers.where((m) => !managerIds.contains(m.authUserId)).toList();

          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading members: $e');
      if (mounted) {
        setState(() => _isLoadingMembers = false);
      }
    }
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _filteredAvailableUsers = [];
          _isLoadingAvailable = false;
        });
      }
      return;
    }

    setState(() => _isLoadingAvailable = true);

    try {
      // Server-side search
      final users = await _groupRepository.searchAvailableUsers(query);

      if (mounted) {
        setState(() {
          // Filter out users who are already members
          // Use either authUserId or id (legacy) for identification
          final memberIds = _currentMembers.map((m) => m.authUserId ?? m.id).toSet();

          _filteredAvailableUsers = users.where((u) {
            final userId = u.authUserId ?? u.id;
            return !memberIds.contains(userId);
          }).toList();

          _isLoadingAvailable = false;
        });
      }
    } catch (e) {
      debugPrint('Error searching users: $e');
      if (mounted) {
        setState(() => _isLoadingAvailable = false);
      }
    }
  }

  String _getDisplayName(CcMembersRow member) {
    if (member.hideLastName == true) {
      return member.firstName ?? member.displayName ?? 'Unknown';
    }
    final fullName = '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return fullName.isNotEmpty ? fullName : (member.displayName ?? 'Unknown');
  }

  Future<void> _addUser(CcMembersRow user) async {
    final userId = user.authUserId ?? user.id;

    setState(() {
      _addingUserIds.add(userId);
    });

    try {
      await _groupRepository.addUserToGroup(widget.groupId, userId);

      if (mounted) {
        setState(() {
          _addingUserIds.remove(userId);
          // Move user from available to current members
          _currentMembers.add(user);
          _regularMembers.add(user); // New members added here are regular members by default
          // Remove from search results as they are now members
          _filteredAvailableUsers.removeWhere((u) => (u.authUserId ?? u.id) == userId);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_getDisplayName(user)} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error adding user: $e');
      if (mounted) {
        setState(() {
          _addingUserIds.remove(userId);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${_getDisplayName(user)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(CcMembersRow member) async {
    final displayName = _getDisplayName(member);
    final userId = member.authUserId ?? member.id;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove "$displayName" from this group?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _groupRepository.removeUserFromGroup(widget.groupId, userId);

        if (mounted) {
          setState(() {
            // Move user from current members back to available
            _facilitators.removeWhere((m) => (m.authUserId ?? m.id) == userId);
            _regularMembers.removeWhere((m) => (m.authUserId ?? m.id) == userId);
            // We don't necessarily add back to filtered list unless it matches search
            // But checking search is cheap so let's just trigger a re-search
            _searchUsers();
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$displayName removed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error removing member: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to remove $displayName'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleMemberRole(CcMembersRow member, {required bool makeFacilitator}) async {
    final displayName = _getDisplayName(member);
    final userId = member.authUserId ?? member.id;
    final newRole = makeFacilitator ? 'GROUP_MANAGER' : 'MEMBER';
    final action = makeFacilitator ? 'promote to Facilitator' : 'demote to Member';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: Text(makeFacilitator ? 'Make Facilitator' : 'Remove as Facilitator'),
        content: Text('Are you sure you want to $action "$displayName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.of(context).primary,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _groupRepository.updateMemberRole(widget.groupId, userId, newRole);

        if (mounted) {
          setState(() {
            if (makeFacilitator) {
              _regularMembers.removeWhere((m) => (m.authUserId ?? m.id) == userId);
              _facilitators.add(member);
            } else {
              _facilitators.removeWhere((m) => (m.authUserId ?? m.id) == userId);
              _regularMembers.add(member);
            }
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$displayName role updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('Error updating role: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update role for $displayName'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showMemberDetails(CcMembersRow member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => MemberDetailsSheet(member: member),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAddMemberSection(context),
                const SizedBox(height: 24.0),
                _buildCurrentMembersSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.of(context).primary,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Member Management',
            style: GoogleFonts.lexendDeca(
              color: Colors.white,
              fontSize: 20.0,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            widget.groupName,
            style: GoogleFonts.lexendDeca(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 14.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddMemberSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ADD NEW MEMBER',
          style: AppTheme.of(context).labelMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12.0),
        // Search field
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search by name or email...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 12.0,
            ),
          ),
        ),
        const SizedBox(height: 12.0),
        // Available users list
        _isLoadingAvailable
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SpinKitRipple(
                    color: AppTheme.of(context).primary,
                    size: 40.0,
                  ),
                ),
              )
            : _filteredAvailableUsers.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        _searchController.text.isEmpty ? 'Search to find users' : 'No users found',
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                  )
                : Container(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredAvailableUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredAvailableUsers[index];
                        return _buildAvailableUserCard(context, user);
                      },
                    ),
                  ),
      ],
    );
  }

  Widget _buildAvailableUserCard(BuildContext context, CcMembersRow user) {
    final isAdding = _addingUserIds.contains(user.authUserId);
    final displayName = _getDisplayName(user);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    user.email?.isNotEmpty == true ? user.email! : 'No email registered',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).primary,
                          fontSize: 13.0,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12.0),
            isAdding
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppTheme.of(context).primary,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _addUser(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.of(context).primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: Text(
                      'Add',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: Colors.white,
                          ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentMembersSection(BuildContext context) {
    if (_isLoadingMembers) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SpinKitRipple(
            color: AppTheme.of(context).primary,
            size: 40.0,
          ),
        ),
      );
    }

    if (_currentMembers.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No members in this group',
            style: AppTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).secondaryText,
                ),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Facilitators Section
        if (_facilitators.isNotEmpty) ...[
          Text(
            'FACILITATORS (${_facilitators.length})',
            style: AppTheme.of(context).labelMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _facilitators.length,
            itemBuilder: (context, index) {
              final member = _facilitators[index];
              return _buildMemberCard(context, member, isFacilitator: true);
            },
          ),
          const SizedBox(height: 24.0),
        ],

        // Regular Members Section
        if (_regularMembers.isNotEmpty) ...[
          Text(
            'MEMBERS (${_regularMembers.length})',
            style: AppTheme.of(context).labelMedium.override(
                  font: GoogleFonts.lexendDeca(),
                  color: AppTheme.of(context).primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 12.0),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _regularMembers.length,
            itemBuilder: (context, index) {
              final member = _regularMembers[index];
              return _buildMemberCard(context, member);
            },
          ),
        ],
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, CcMembersRow member, {bool isFacilitator = false}) {
    final displayName = _getDisplayName(member);

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            UserAvatar(
              imageUrl: member.photoUrl,
              fullName: displayName,
              size: 40.0,
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    displayName,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    member.email?.isNotEmpty == true ? member.email! : 'No email registered',
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).primary,
                          fontSize: 13.0,
                        ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                color: AppTheme.of(context).primary,
              ),
              onSelected: (value) {
                if (value == 'view') {
                  _showMemberDetails(member);
                } else if (value == 'remove') {
                  _removeMember(member);
                } else if (value == 'role_toggle') {
                  _toggleMemberRole(member, makeFacilitator: !isFacilitator);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'role_toggle',
                  child: Row(
                    children: [
                      Icon(
                        isFacilitator ? Icons.arrow_downward : Icons.arrow_upward,
                        size: 20,
                        color: AppTheme.of(context).primary,
                      ),
                      const SizedBox(width: 12),
                      Text(isFacilitator ? 'Make Member' : 'Make Facilitator'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 20,
                        color: AppTheme.of(context).secondary,
                      ),
                      const SizedBox(width: 12),
                      const Text('View Details'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_remove_outlined,
                        size: 20,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Remove',
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

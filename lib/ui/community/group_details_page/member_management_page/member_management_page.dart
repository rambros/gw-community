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
  List<CcMembersRow> _availableUsers = [];
  List<CcMembersRow> _filteredAvailableUsers = [];

  bool _isLoadingMembers = true;
  bool _isLoadingAvailable = true;
  final Set<String> _addingUserIds = {};

  @override
  void initState() {
    super.initState();
    _loadData();
    _searchController.addListener(_filterAvailableUsers);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadCurrentMembers(),
      _loadAvailableUsers(),
    ]);
  }

  Future<void> _loadCurrentMembers() async {
    setState(() => _isLoadingMembers = true);
    try {
      final members = await _groupRepository.getGroupMembersAsUsers(widget.groupId);
      if (mounted) {
        setState(() {
          _currentMembers = members;
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

  Future<void> _loadAvailableUsers() async {
    setState(() => _isLoadingAvailable = true);
    try {
      final users = await _groupRepository.getUsersNotInGroup(widget.groupId);
      if (mounted) {
        setState(() {
          _availableUsers = users;
          _filteredAvailableUsers = users;
          _isLoadingAvailable = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading available users: $e');
      if (mounted) {
        setState(() => _isLoadingAvailable = false);
      }
    }
  }

  void _filterAvailableUsers() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredAvailableUsers = _availableUsers;
      } else {
        _filteredAvailableUsers = _availableUsers.where((user) {
          final displayName = _getDisplayName(user).toLowerCase();
          final email = user.email?.toLowerCase() ?? '';
          return displayName.contains(query) || email.contains(query);
        }).toList();
      }
    });
  }

  String _getDisplayName(CcMembersRow member) {
    if (member.hideLastName == true) {
      return member.firstName ?? member.displayName ?? 'Unknown';
    }
    final fullName = '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return fullName.isNotEmpty ? fullName : (member.displayName ?? 'Unknown');
  }

  Future<void> _addUser(CcMembersRow user) async {
    if (user.authUserId == null) return;

    setState(() {
      _addingUserIds.add(user.authUserId!);
    });

    try {
      await _groupRepository.addUserToGroup(widget.groupId, user.authUserId!);

      if (mounted) {
        setState(() {
          _addingUserIds.remove(user.authUserId!);
          // Move user from available to current members
          _availableUsers.removeWhere((u) => u.authUserId == user.authUserId);
          _currentMembers.add(user);
          _filterAvailableUsers();
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
          _addingUserIds.remove(user.authUserId!);
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
        await _groupRepository.removeUserFromGroup(widget.groupId, member.authUserId!);

        if (mounted) {
          setState(() {
            // Move user from current members back to available
            _currentMembers.removeWhere((m) => m.authUserId == member.authUserId);
            _availableUsers.add(member);
            _filterAvailableUsers();
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
                        _searchController.text.isEmpty ? 'No users available to add' : 'No users found',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CURRENT MEMBERS (${_currentMembers.length})',
          style: AppTheme.of(context).labelMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: AppTheme.of(context).primary,
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12.0),
        _isLoadingMembers
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: SpinKitRipple(
                    color: AppTheme.of(context).primary,
                    size: 40.0,
                  ),
                ),
              )
            : _currentMembers.isEmpty
                ? Center(
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
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _currentMembers.length,
                    itemBuilder: (context, index) {
                      final member = _currentMembers[index];
                      return _buildMemberCard(context, member);
                    },
                  ),
      ],
    );
  }

  Widget _buildMemberCard(BuildContext context, CcMembersRow member) {
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
                }
              },
              itemBuilder: (context) => [
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

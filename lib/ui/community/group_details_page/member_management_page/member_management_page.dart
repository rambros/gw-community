import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/repositories/user_profile_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/announcement_add_page/announcement_add_page.dart';
import 'package:gw_community/ui/community/group_details_page/widgets/member_details_sheet.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

enum _MemberSortBy { name, email }

enum _MemberAccessFilter { all, active, neverAccessed }

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
  final UserProfileRepository _userProfileRepository = UserProfileRepository();
  final TextEditingController _rosterSearchController = TextEditingController();

  List<CcMembersRow> _currentMembers = [];
  List<CcMembersRow> _facilitators = [];
  List<CcMembersRow> _regularMembers = [];

  bool _isLoadingMembers = true;
  bool _isLoadingMore = false;
  int _loadGeneration = 0;

  String _rosterQuery = '';
  _MemberSortBy _sortBy = _MemberSortBy.name;
  _MemberAccessFilter _accessFilter = _MemberAccessFilter.all;
  bool _facilitatorsExpanded = true;

  @override
  void initState() {
    super.initState();
    _loadData();
    _rosterSearchController.addListener(_onRosterQueryChanged);
  }

  @override
  void dispose() {
    _rosterSearchController.dispose();
    super.dispose();
  }

  void _onRosterQueryChanged() {
    setState(() {
      _rosterQuery = _rosterSearchController.text.trim();
    });
  }

  Future<void> _loadData() async {
    await Future.wait([
      context.read<FFAppState>().loadAppConfig(),
      _loadCurrentMembers(),
    ]);
  }

  Future<void> _loadCurrentMembers() async {
    final generation = ++_loadGeneration;
    final keepList = _currentMembers.isNotEmpty;
    setState(() {
      if (!keepList) _isLoadingMembers = true;
      _isLoadingMore = true;
    });
    try {
      final groupMembersLinks =
          await _groupRepository.getGroupMembers(widget.groupId);
      if (!mounted || generation != _loadGeneration) return;

      final membersUsers = await _groupRepository.getGroupMembersAsUsers(
        widget.groupId,
        links: groupMembersLinks,
        onProgress: (loaded) {
          if (!mounted || generation != _loadGeneration) return;
          setState(() {
            _applyRoster(loaded, groupMembersLinks);
            _isLoadingMembers = false;
          });
        },
      );
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _applyRoster(membersUsers, groupMembersLinks);
        _isLoadingMembers = false;
        _isLoadingMore = false;
      });
    } catch (e) {
      debugPrint('Error loading members: $e');
      if (mounted && generation == _loadGeneration) {
        setState(() {
          _isLoadingMembers = false;
          _isLoadingMore = false;
        });
      }
    }
  }

  void _applyRoster(
    List<CcMembersRow> membersUsers,
    List<CcGroupMembersRow> links,
  ) {
    final managerIds = links
        .where((m) =>
            m.userRole == 'GROUP_MANAGER' ||
            m.userRole == 'Manager' ||
            m.userRole == 'group_manager')
        .map((m) => m.userId)
        .toSet();

    _currentMembers = membersUsers;
    _facilitators =
        membersUsers.where((m) => managerIds.contains(m.authUserId)).toList();
    _regularMembers =
        membersUsers.where((m) => !managerIds.contains(m.authUserId)).toList();
  }

  String _getDisplayName(CcMembersRow member, BuildContext context) {
    if (member.hideLastName == true) {
      return member.firstName ?? member.displayName ?? context.l10n.unknown;
    }
    final fullName =
        '${member.firstName ?? ''} ${member.lastName ?? ''}'.trim();
    return fullName.isNotEmpty
        ? fullName
        : (member.displayName ?? context.l10n.unknown);
  }

  String _formatLastAccessDate(DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date.toLocal());
  }

  String _lastAccessLabel(CcMembersRow member) {
    final access = member.lastAccess;
    if (access == null) return context.l10n.neverAccessed;
    return context.l10n.lastAccessValue(_formatLastAccessDate(access));
  }

  bool _matchesRosterQuery(CcMembersRow member) {
    if (_rosterQuery.isEmpty) return true;
    final q = _rosterQuery.toLowerCase();
    final name = _getDisplayName(member, context).toLowerCase();
    final first = (member.firstName ?? '').toLowerCase();
    final last = (member.lastName ?? '').toLowerCase();
    final display = (member.displayName ?? '').toLowerCase();
    return name.contains(q) ||
        first.contains(q) ||
        last.contains(q) ||
        display.contains(q);
  }

  bool _matchesAccessFilter(CcMembersRow member) {
    switch (_accessFilter) {
      case _MemberAccessFilter.all:
        return true;
      case _MemberAccessFilter.active:
        return member.lastAccess != null;
      case _MemberAccessFilter.neverAccessed:
        return member.lastAccess == null;
    }
  }

  List<CcMembersRow> _visibleMembers(
    List<CcMembersRow> source, {
    bool applyAccessFilter = false,
  }) {
    final filtered = source.where((member) {
      if (!_matchesRosterQuery(member)) return false;
      if (applyAccessFilter && !_matchesAccessFilter(member)) return false;
      return true;
    }).toList();
    filtered.sort((a, b) {
      switch (_sortBy) {
        case _MemberSortBy.email:
          final ae = (a.email ?? '').toLowerCase();
          final be = (b.email ?? '').toLowerCase();
          final cmp = ae.compareTo(be);
          if (cmp != 0) return cmp;
          return _getDisplayName(a, context)
              .toLowerCase()
              .compareTo(_getDisplayName(b, context).toLowerCase());
        case _MemberSortBy.name:
          return _getDisplayName(a, context)
              .toLowerCase()
              .compareTo(_getDisplayName(b, context).toLowerCase());
      }
    });
    return filtered;
  }

  List<CcMembersRow> get _visibleFacilitators => _visibleMembers(_facilitators);

  List<CcMembersRow> get _visibleRegularMembers =>
      _visibleMembers(_regularMembers, applyAccessFilter: true);

  int get _totalMembersCount => _regularMembers.length;

  int get _activeMembersCount =>
      _regularMembers.where((m) => m.lastAccess != null).length;

  int get _neverAccessedMembersCount =>
      _regularMembers.where((m) => m.lastAccess == null).length;

  Set<String> get _existingMemberIds =>
      _currentMembers.map((m) => m.authUserId ?? m.id).toSet();

  Future<bool> _addUser(CcMembersRow user) async {
    final userId = user.authUserId ?? user.id;

    try {
      await _groupRepository.addUserToGroup(widget.groupId, userId);

      if (mounted) {
        setState(() {
          _currentMembers.add(user);
          _regularMembers.add(user);
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('${_getDisplayName(user, context)} added successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
      return true;
    } catch (e) {
      debugPrint('Error adding user: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add ${_getDisplayName(user, context)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return false;
    }
  }

  Future<void> _removeMember(CcMembersRow member) async {
    final displayName = _getDisplayName(member, context);
    final userId = member.authUserId ?? member.id;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: Text(context.l10n.confirmation),
        content: Text(context.l10n.confirmRemoveMemberNamed(displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: Text(context.l10n.cancel),
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
            _currentMembers
                .removeWhere((m) => (m.authUserId ?? m.id) == userId);
            _facilitators.removeWhere((m) => (m.authUserId ?? m.id) == userId);
            _regularMembers
                .removeWhere((m) => (m.authUserId ?? m.id) == userId);
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

  Future<void> _toggleMemberRole(
    CcMembersRow member, {
    required bool makeFacilitator,
  }) async {
    final displayName = _getDisplayName(member, context);
    final userId = member.authUserId ?? member.id;
    final newRole = makeFacilitator ? 'GROUP_MANAGER' : 'MEMBER';
    final action =
        makeFacilitator ? 'promote to Facilitator' : 'demote to Member';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (alertContext) => AlertDialog(
        title: Text(context.l10n.confirmation),
        content: Text(context.l10n.confirmMemberAction(action, displayName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(alertContext, false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(alertContext, true),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.of(context).primary,
            ),
            child: Text(context.l10n.confirm),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      try {
        await _groupRepository.updateMemberRole(
          widget.groupId,
          userId,
          newRole,
        );

        if (mounted) {
          setState(() {
            if (makeFacilitator) {
              _regularMembers
                  .removeWhere((m) => (m.authUserId ?? m.id) == userId);
              _facilitators.add(member);
            } else {
              _facilitators
                  .removeWhere((m) => (m.authUserId ?? m.id) == userId);
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

  Future<void> _showEditNameDialog(CcMembersRow member) async {
    final result = await showDialog<_EditedMemberName>(
      context: context,
      builder: (dialogContext) => _EditMemberNameDialog(
        initialFirstName: member.firstName ?? '',
        initialLastName: member.lastName ?? '',
      ),
    );

    if (result == null || !mounted) return;

    final hideLastName = member.hideLastName == true;
    final displayName = hideLastName
        ? '${result.firstName} '
        : '${result.firstName} ${result.lastName}'.trim();

    try {
      await _userProfileRepository.updateMemberById(member.id, {
        'first_name': result.firstName,
        'last_name': result.lastName,
        'display_name': displayName,
      });

      if (!mounted) return;

      setState(() {
        member.firstName = result.firstName;
        member.lastName = result.lastName;
        member.displayName = displayName;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.nameUpdated),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint('Error updating member name: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.nameUpdateFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _sendMessageToMember(CcMembersRow member) {
    final recipientId = member.authUserId;
    if (recipientId == null || recipientId.isEmpty) return;

    context.pushNamed(
      AnnouncementAddPage.routeName,
      queryParameters: {
        'groupId': serializeParam(widget.groupId, ParamType.int),
        'groupName': serializeParam(widget.groupName, ParamType.String),
        'initialRecipientAuthUserId':
            serializeParam(recipientId, ParamType.String),
      }.withoutNulls,
      extra: <String, dynamic>{
        'groupMembers': _currentMembers,
        'initialRecipient': member,
      },
    );
  }

  void _openAddMemberSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return _AddMemberBottomSheet(
          existingMemberIds: _existingMemberIds,
          onAdd: _addUser,
          getDisplayName: (user) => _getDisplayName(user, context),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final visibleFacilitators = _visibleFacilitators;
    final visibleMembers = _visibleRegularMembers;

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: _buildAppBar(context),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddMemberSheet,
        backgroundColor: AppTheme.of(context).primary,
        elevation: 8.0,
        icon: Icon(
          Icons.person_add_alt_1,
          color: AppTheme.of(context).primaryBackground,
        ),
        label: Text(
          context.l10n.addNewMember,
          style: AppTheme.of(context).labelLarge.override(
                font: GoogleFonts.poppins(),
                color: AppTheme.of(context).primaryBackground,
              ),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
                sliver: SliverToBoxAdapter(
                  child: _buildRosterControls(context),
                ),
              ),
              if (_isLoadingMembers)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SpinKitRipple(
                        color: AppTheme.of(context).primary,
                        size: 40.0,
                      ),
                    ),
                  ),
                )
              else if (_currentMembers.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Center(
                      child: Text(
                        context.l10n.noMembersInGroup,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                  ),
                )
              else ...[
                if (visibleFacilitators.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                    sliver: SliverToBoxAdapter(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _facilitatorsExpanded = !_facilitatorsExpanded;
                          });
                        },
                        borderRadius: BorderRadius.circular(8.0),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${context.l10n.facilitators} (${visibleFacilitators.length})',
                                  style:
                                      AppTheme.of(context).labelMedium.override(
                                            font: GoogleFonts.lexendDeca(),
                                            color: AppTheme.of(context).primary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                ),
                              ),
                              Icon(
                                _facilitatorsExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                color: AppTheme.of(context).primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_facilitatorsExpanded)
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => _buildMemberCard(
                            context,
                            visibleFacilitators[index],
                            isFacilitator: true,
                          ),
                          childCount: visibleFacilitators.length,
                        ),
                      ),
                    ),
                ],
                if (_regularMembers.isNotEmpty ||
                    visibleMembers.isNotEmpty) ...[
                  SliverPadding(
                    padding: EdgeInsets.fromLTRB(
                      16.0,
                      visibleFacilitators.isNotEmpty ? 12.0 : 8.0,
                      16.0,
                      4.0,
                    ),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        context.l10n.members,
                        style: AppTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 20.0,
                            ),
                      ),
                    ),
                  ),
                  if (_regularMembers.isNotEmpty)
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 8.0),
                      sliver: SliverToBoxAdapter(
                        child: _buildMemberCounters(context),
                      ),
                    ),
                ],
                if (visibleMembers.isNotEmpty) ...[
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 0, 16.0, 88.0),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildMemberCard(
                          context,
                          visibleMembers[index],
                        ),
                        childCount: visibleMembers.length,
                      ),
                    ),
                  ),
                ] else if (visibleFacilitators.isNotEmpty &&
                    _regularMembers.isNotEmpty &&
                    !_isLoadingMore)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                    sliver: SliverToBoxAdapter(
                      child: Text(
                        context.l10n.noMembersFound,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondaryText,
                            ),
                      ),
                    ),
                  ),
                if (visibleFacilitators.isEmpty &&
                    visibleMembers.isEmpty &&
                    !_isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          context.l10n.noUsersFound,
                          style: AppTheme.of(context).bodyMedium.override(
                                font: GoogleFonts.lexendDeca(),
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                      ),
                    ),
                  ),
                if (_isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 88.0),
                      child: Center(
                        child: SpinKitRipple(
                          color: AppTheme.of(context).primary,
                          size: 32.0,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
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

  bool get _hasActiveRosterFilter =>
      _rosterQuery.isNotEmpty ||
      _sortBy != _MemberSortBy.name ||
      _accessFilter != _MemberAccessFilter.all;

  void _clearRosterFilters() {
    _rosterSearchController.clear();
    setState(() {
      _rosterQuery = '';
      _sortBy = _MemberSortBy.name;
      _accessFilter = _MemberAccessFilter.all;
      _facilitatorsExpanded = true;
    });
  }

  InputDecoration _searchDecoration({
    required BuildContext context,
    required String hintText,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    final primary = AppTheme.of(context).primary;
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon, color: primary),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12.0),
        borderSide: BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 12.0,
      ),
    );
  }

  Widget _buildSortChip({
    required BuildContext context,
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final primary = AppTheme.of(context).primary;
    final secondary = AppTheme.of(context).secondary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primary : secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : secondary,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRosterControls(BuildContext context) {
    final primary = AppTheme.of(context).primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _rosterSearchController,
          decoration: _searchDecoration(
            context: context,
            hintText: context.l10n.searchMembersByName,
            icon: Icons.search,
            suffixIcon: _rosterQuery.isEmpty
                ? null
                : IconButton(
                    tooltip: context.l10n.clearFilter,
                    icon: Icon(Icons.close, color: primary),
                    onPressed: _clearRosterFilters,
                  ),
          ),
        ),
        const SizedBox(height: 12.0),
        Row(
          children: [
            _buildSortChip(
              context: context,
              label: context.l10n.sortByName,
              icon: Icons.sort_by_alpha,
              isSelected: _sortBy == _MemberSortBy.name,
              onTap: () => setState(() => _sortBy = _MemberSortBy.name),
            ),
            const SizedBox(width: 8),
            _buildSortChip(
              context: context,
              label: context.l10n.sortByEmail,
              icon: Icons.email_outlined,
              isSelected: _sortBy == _MemberSortBy.email,
              onTap: () => setState(() => _sortBy = _MemberSortBy.email),
            ),
            if (_hasActiveRosterFilter) ...[
              const Spacer(),
              TextButton(
                onPressed: _clearRosterFilters,
                style: TextButton.styleFrom(
                  foregroundColor: primary,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                child: Text(
                  context.l10n.clearFilter,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMemberCounters(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildSortChip(
          context: context,
          label: context.l10n.memberCountTotal(_totalMembersCount),
          isSelected: _accessFilter == _MemberAccessFilter.all,
          onTap: () => setState(() => _accessFilter = _MemberAccessFilter.all),
        ),
        _buildSortChip(
          context: context,
          label: context.l10n.memberCountActive(_activeMembersCount),
          isSelected: _accessFilter == _MemberAccessFilter.active,
          onTap: () =>
              setState(() => _accessFilter = _MemberAccessFilter.active),
        ),
        _buildSortChip(
          context: context,
          label:
              context.l10n.memberCountNeverAccessed(_neverAccessedMembersCount),
          isSelected: _accessFilter == _MemberAccessFilter.neverAccessed,
          onTap: () => setState(
            () => _accessFilter = _MemberAccessFilter.neverAccessed,
          ),
        ),
      ],
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    CcMembersRow member, {
    bool isFacilitator = false,
  }) {
    final displayName = _getDisplayName(member, context);
    final canEditName = context.watch<FFAppState>().appConfig.enableEditName;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
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
                    member.email?.isNotEmpty == true
                        ? member.email!
                        : context.l10n.noEmailRegistered,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).primary,
                          fontSize: 13.0,
                        ),
                  ),
                  const SizedBox(height: 2.0),
                  Text(
                    _lastAccessLabel(member),
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).secondaryText,
                          fontSize: 12.0,
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
                } else if (value == 'edit_name') {
                  _showEditNameDialog(member);
                } else if (value == 'message') {
                  _sendMessageToMember(member);
                } else if (value == 'remove') {
                  _removeMember(member);
                } else if (value == 'role_toggle') {
                  _toggleMemberRole(member, makeFacilitator: !isFacilitator);
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
                      Text(context.l10n.view),
                    ],
                  ),
                ),
                if (canEditName)
                  PopupMenuItem(
                    value: 'edit_name',
                    child: Row(
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          size: 20,
                          color: AppTheme.of(context).primary,
                        ),
                        const SizedBox(width: 12),
                        Text(context.l10n.editName),
                      ],
                    ),
                  ),
                PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline,
                        size: 20,
                        color: AppTheme.of(context).primary,
                      ),
                      const SizedBox(width: 12),
                      Text(context.l10n.sendAMessage),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'role_toggle',
                  child: Row(
                    children: [
                      Icon(
                        isFacilitator
                            ? Icons.arrow_downward
                            : Icons.arrow_upward,
                        size: 20,
                        color: AppTheme.of(context).primary,
                      ),
                      const SizedBox(width: 12),
                      Text(isFacilitator ? 'Make Member' : 'Make Facilitator'),
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

class _EditedMemberName {
  const _EditedMemberName({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;
}

class _EditMemberNameDialog extends StatefulWidget {
  const _EditMemberNameDialog({
    required this.initialFirstName,
    required this.initialLastName,
  });

  final String initialFirstName;
  final String initialLastName;

  @override
  State<_EditMemberNameDialog> createState() => _EditMemberNameDialogState();
}

class _EditMemberNameDialogState extends State<_EditMemberNameDialog> {
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController(text: widget.initialFirstName);
    _lastController = TextEditingController(text: widget.initialLastName);
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.pop(
      context,
      _EditedMemberName(
        firstName: _firstController.text.trim(),
        lastName: _lastController.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.l10n.editName),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _firstController,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.firstName,
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return context.l10n.firstNameRequired;
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _lastController,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: context.l10n.lastName,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.l10n.cancel),
        ),
        TextButton(
          onPressed: _submit,
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.of(context).primary,
          ),
          child: Text(context.l10n.saveChanges),
        ),
      ],
    );
  }
}

class _AddMemberBottomSheet extends StatefulWidget {
  const _AddMemberBottomSheet({
    required this.existingMemberIds,
    required this.onAdd,
    required this.getDisplayName,
  });

  final Set<String> existingMemberIds;
  final Future<bool> Function(CcMembersRow user) onAdd;
  final String Function(CcMembersRow user) getDisplayName;

  @override
  State<_AddMemberBottomSheet> createState() => _AddMemberBottomSheetState();
}

class _AddMemberBottomSheetState extends State<_AddMemberBottomSheet> {
  final GroupRepository _groupRepository = GroupRepository();
  final TextEditingController _searchController = TextEditingController();

  List<CcMembersRow> _results = [];
  bool _isLoading = false;
  final Set<String> _addingUserIds = {};
  late Set<String> _excludedIds;

  @override
  void initState() {
    super.initState();
    _excludedIds = {...widget.existingMemberIds};
    _searchController.addListener(_onQueryChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onQueryChanged() {
    unawaited(_searchUsers());
  }

  Future<void> _searchUsers() async {
    final query = _searchController.text.trim();
    if (query.length < 3) {
      if (mounted) {
        setState(() {
          _results = [];
          _isLoading = false;
        });
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final users = await _groupRepository.searchAvailableUsers(query);
      if (!mounted) return;
      setState(() {
        _results = users.where((u) {
          final userId = u.authUserId ?? u.id;
          return !_excludedIds.contains(userId);
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error searching users: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAdd(CcMembersRow user) async {
    final userId = user.authUserId ?? user.id;
    setState(() => _addingUserIds.add(userId));

    final success = await widget.onAdd(user);

    if (!mounted) return;

    setState(() {
      _addingUserIds.remove(userId);
      if (success) {
        _excludedIds.add(userId);
        _results.removeWhere((u) => (u.authUserId ?? u.id) == userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final primary = AppTheme.of(context).primary;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: Container(
        height: MediaQuery.sizeOf(context).height * 0.75,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      context.l10n.addNewMember,
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: primary,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: primary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.l10n.searchByNameOrEmail,
                  prefixIcon: Icon(Icons.search, color: primary),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: SpinKitRipple(
                        color: primary,
                        size: 40.0,
                      ),
                    )
                  : _results.isEmpty
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Text(
                              _searchController.text.trim().length < 3
                                  ? context.l10n.searchToFindUsers
                                  : context.l10n.noUsersFound,
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(),
                                    color: AppTheme.of(context).secondaryText,
                                  ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final user = _results[index];
                            return _buildResultCard(context, user);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(BuildContext context, CcMembersRow user) {
    final userId = user.authUserId ?? user.id;
    final isAdding = _addingUserIds.contains(userId);
    final displayName = widget.getDisplayName(user);
    final primary = AppTheme.of(context).primary;

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
                    user.email?.isNotEmpty == true
                        ? user.email!
                        : context.l10n.noEmailRegistered,
                    style: AppTheme.of(context).bodySmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: primary,
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
                      color: primary,
                    ),
                  )
                : ElevatedButton(
                    onPressed: () => _handleAdd(user),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primary,
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
}

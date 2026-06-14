import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/app_state.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/file_resource_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:provider/provider.dart';

/// Bottom sheet that lets an admin or group manager link a portal item to groups.
/// Admins see all groups; group managers see only the groups they manage.
class GroupLinkSheet extends StatefulWidget {
  const GroupLinkSheet({
    super.key,
    required this.contentRow,
    required this.userId,
  });

  final ViewContentRow contentRow;
  final String userId;

  @override
  State<GroupLinkSheet> createState() => _GroupLinkSheetState();
}

class _GroupLinkSheetState extends State<GroupLinkSheet> {
  final _repo = FileResourceRepository();

  bool _loading = true;
  bool _saving = false;

  List<CcGroupsRow> _availableGroups = [];
  List<int> _initialGroupIds = [];
  List<int> _selectedGroupIds = [];
  String _search = '';

  bool get _isAdmin => FFAppState().loginUser.roles.hasAdmin;

  List<int> get _toAdd =>
      _selectedGroupIds.where((id) => !_initialGroupIds.contains(id)).toList();
  List<int> get _toRemove =>
      _initialGroupIds.where((id) => !_selectedGroupIds.contains(id)).toList();
  bool get _hasChanges => _toAdd.isNotEmpty || _toRemove.isNotEmpty;

  String get _resourceType {
    final t = (widget.contentRow.midiaType ?? '').toLowerCase();
    if (t.contains('audio') || t.contains('áudio')) return 'audio';
    if (t.contains('video') || t.contains('vídeo')) return 'video';
    return (widget.contentRow.audioUrl?.isNotEmpty == true) ? 'audio' : 'pdf';
  }

  String get _resourceUrl {
    if (_resourceType == 'audio') return widget.contentRow.audioUrl ?? '';
    return widget.contentRow.midiaFileUrl ?? '';
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final contentId = widget.contentRow.contentId;
    final futures = await Future.wait([
      _isAdmin
          ? _repo.getAllGroups()
          : _repo.getManagedGroupIds(widget.userId).then(
                (ids) async {
                  if (ids.isEmpty) return <CcGroupsRow>[];
                  final all = await _repo.getAllGroups();
                  return all.where((g) => ids.contains(g.id)).toList();
                },
              ),
      if (contentId != null) _repo.getLinkedGroupIds(contentId),
    ]);

    final groups = futures[0] as List<CcGroupsRow>;
    final linked = (contentId != null ? futures[1] as List<int> : <int>[]);

    // Restrict pre-selection to groups this user can manage (or all if admin)
    final availableIds = groups.map((g) => g.id).toSet();
    final preSelected = linked.where(availableIds.contains).toList();

    if (mounted) {
      setState(() {
        _availableGroups = groups;
        _initialGroupIds = List.from(preSelected);
        _selectedGroupIds = List.from(preSelected);
        _loading = false;
      });
    }
  }

  Future<void> _save() async {
    if (!_hasChanges || _saving) return;
    setState(() => _saving = true);

    final contentId = widget.contentRow.contentId!;
    final ok = await _repo.linkPortalItemToGroups(
      portalItemId: contentId,
      title: widget.contentRow.title ?? '',
      description: widget.contentRow.description,
      url: _resourceUrl,
      type: _resourceType,
      isPublished: widget.contentRow.isPublished ?? false,
      datePublished: widget.contentRow.datePublished,
      toAddGroupIds: _toAdd,
      toRemoveGroupIds: _toRemove,
      userId: widget.userId,
    );

    if (!mounted) return;
    setState(() => _saving = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ok ? 'Group links updated.' : 'Failed to update links.'),
        backgroundColor: ok ? Colors.green.shade700 : Colors.red.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final filtered = _availableGroups
        .where((g) =>
            _search.isEmpty ||
            (g.name ?? '').toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Container(
      decoration: BoxDecoration(
        color: theme.primaryBackground,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(theme),
          const Divider(height: 1),
          _buildSearch(theme),
          Flexible(
            child: _loading
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  )
                : filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(40),
                          child: Text(
                            _search.isEmpty
                                ? 'No groups available.'
                                : 'No groups match "$_search".',
                            style: GoogleFonts.lexendDeca(
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: filtered.length,
                        itemBuilder: (_, i) => _buildGroupTile(filtered[i]),
                      ),
          ),
          const Divider(height: 1),
          _buildActions(theme),
        ],
      ),
    );
  }

  Widget _buildHandle() => Padding(
        padding: const EdgeInsets.only(top: 12, bottom: 4),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      );

  Widget _buildHeader(AppTheme theme) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Link to Groups',
              style: GoogleFonts.lexendDeca(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: theme.primaryText,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.contentRow.title ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.lexendDeca(
                fontSize: 13,
                color: theme.secondaryText,
              ),
            ),
          ],
        ),
      );

  Widget _buildSearch(AppTheme theme) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search groups…',
            prefixIcon: const Icon(Icons.search, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            isDense: true,
          ),
          onChanged: (v) => setState(() => _search = v),
        ),
      );

  Widget _buildGroupTile(CcGroupsRow group) {
    final selected = _selectedGroupIds.contains(group.id);
    final wasLinked = _initialGroupIds.contains(group.id);
    return CheckboxListTile(
      value: selected,
      onChanged: (_) {
        setState(() {
          if (selected) {
            _selectedGroupIds.remove(group.id);
          } else {
            _selectedGroupIds.add(group.id);
          }
        });
      },
      title: Text(
        group.name ?? '',
        style: GoogleFonts.lexendDeca(fontSize: 14),
      ),
      subtitle: wasLinked && !selected
          ? Text(
              'Will be unlinked',
              style: TextStyle(fontSize: 11, color: Colors.red.shade400),
            )
          : !wasLinked && selected
              ? Text(
                  'Will be linked',
                  style: TextStyle(fontSize: 11, color: Colors.green.shade600),
                )
              : null,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
    );
  }

  Widget _buildActions(AppTheme theme) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _saving ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: (_hasChanges && !_saving) ? _save : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Save'),
              ),
            ),
          ],
        ),
      );
}

/// Shows [GroupLinkSheet] only if the current user is an admin or group manager
/// and the content has a linkable URL. Returns false if not shown.
Future<bool> showGroupLinkSheet(
  BuildContext context,
  ViewContentRow contentRow,
) async {
  final appState = Provider.of<FFAppState>(context, listen: false);
  if (!appState.loginUser.roles.hasAdminOrGroupManager) return false;

  final url = (contentRow.midiaType ?? '').toLowerCase().contains('audio')
      ? (contentRow.audioUrl ?? '')
      : (contentRow.midiaFileUrl ?? '');
  if (url.isEmpty || contentRow.contentId == null) return false;

  final userId = SupaFlow.client.auth.currentUser?.id ?? '';
  if (userId.isEmpty) return false;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, controller) => GroupLinkSheet(
        contentRow: contentRow,
        userId: userId,
      ),
    ),
  );
  return true;
}

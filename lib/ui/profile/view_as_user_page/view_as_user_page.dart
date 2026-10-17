import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/view_as/view_as_actions.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:provider/provider.dart';

class ViewAsUserPage extends StatefulWidget {
  const ViewAsUserPage({super.key});

  static String routeName = 'viewAsUser';
  static String routePath = '/viewAsUser';

  @override
  State<ViewAsUserPage> createState() => _ViewAsUserPageState();
}

class _ViewAsUserPageState extends State<ViewAsUserPage> {
  final _queryController = TextEditingController();
  List<CcMembersRow> _results = [];
  bool _searching = false;
  bool _searched = false;

  int _request = 0;

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  Future<void> _search(String raw) async {
    final query = raw.trim();
    final request = ++_request;
    if (query.length < 3) {
      setState(() {
        _results = [];
        _searched = false;
        _searching = false;
      });
      return;
    }

    setState(() => _searching = true);
    final members = await context.read<GroupRepository>().searchAvailableUsers(query);
    if (!mounted || request != _request) return;
    final selfId = context.currentUserIdOrEmpty;
    setState(() {
      _results = members.where((member) {
        final authId = member.authUserId;
        return authId != null && authId.isNotEmpty && authId != selfId;
      }).toList();
      _searched = true;
      _searching = false;
    });
  }

  Future<void> _select(CcMembersRow member) async {
    final authId = member.authUserId;
    if (authId == null || authId.isEmpty) return;
    final name = member.displayName?.trim();
    await ViewAsActions.start(
      context,
      authUserId: authId,
      displayName: (name == null || name.isEmpty) ? (member.email ?? authId) : name,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = AppTheme.of(context);
    final query = _queryController.text.trim();

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
        foregroundColor: theme.primaryBackground,
        title: Text(l10n.viewAsUser),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              l10n.viewAsReadOnlyNote,
              style: theme.bodyMedium,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.viewAsSearchHint,
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _search,
              onSubmitted: _search,
            ),
          ),
          if (query.length < 3)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.viewAsSearchMin, style: theme.bodySmall),
            )
          else if (_searching)
            const Padding(
              padding: EdgeInsets.all(24),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_searched && _results.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.viewAsNoResults, style: theme.bodyMedium),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final member = _results[index];
                  final name = member.displayName?.trim();
                  return ListTile(
                    title: Text(
                      (name == null || name.isEmpty) ? (member.email ?? '') : name,
                    ),
                    subtitle: member.email == null ? null : Text(member.email!),
                    onTap: () => _select(member),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

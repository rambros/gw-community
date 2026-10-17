import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.groupRow,
    this.onUpdate,
    this.padding = const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
  });

  final CcGroupsRow groupRow;
  final VoidCallback? onUpdate;
  final EdgeInsetsGeometry padding;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> with RouteAware {
  final _announcementRepo = AnnouncementRepository();
  int _unreadCount = 0;
  DateTime? _lastPostDate;
  int _unreadRequest = 0;
  int _postDateRequest = 0;
  bool _subscribedRoute = false;
  bool _didInitialLoad = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
      _subscribedRoute = true;
    }
    if (!_didInitialLoad) {
      _didInitialLoad = true;
      _reload();
    }
  }

  @override
  void didUpdateWidget(GroupCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groupRow.id != widget.groupRow.id) {
      _unreadCount = 0;
      _lastPostDate = null;
      _reload();
    }
  }

  /// The groups list stays mounted under the group page. Reading a message
  /// updates the database, but this card would keep the previous count.
  @override
  void didPopNext() {
    _reload();
  }

  @override
  void dispose() {
    if (_subscribedRoute) routeObserver.unsubscribe(this);
    super.dispose();
  }

  void _reload() {
    _loadUnread();
    _loadLastPostDate();
  }

  String? _subjectUserId() {
    final effective = context.effectiveUserIdOrEmpty;
    if (effective.isNotEmpty) return effective;
    return SupaFlow.client.auth.currentUser?.id;
  }

  Future<void> _loadUnread() async {
    final userId = _subjectUserId();
    final groupId = widget.groupRow.id;
    if (userId == null || userId.isEmpty) return;
    final request = ++_unreadRequest;
    final count = await _announcementRepo.getUnreadAnnouncementCount(
      groupId,
      userId,
    );
    if (!mounted || request != _unreadRequest || widget.groupRow.id != groupId) {
      return;
    }
    setState(() => _unreadCount = count);
  }

  Future<void> _loadLastPostDate() async {
    final groupId = widget.groupRow.id;
    final request = ++_postDateRequest;
    final date = await _announcementRepo.getLatestPostDate(groupId);
    if (!mounted || request != _postDateRequest || widget.groupRow.id != groupId) {
      return;
    }
    setState(() => _lastPostDate = date);
  }

  String _relativeLastPost(BuildContext context) {
    final locale = Localizations.localeOf(context).languageCode;
    return relativeLastPostLabel(
      l10n: context.l10n,
      now: DateTime.now(),
      lastPost: _lastPostDate,
      formattedDate: dateTimeFormat('MMMd', _lastPostDate, locale: locale),
    );
  }

  String _groupMetaLine(BuildContext context) {
    final l10n = context.l10n;
    return l10n.groupMetaLine(
      localizedGroupPrivacy(l10n, widget.groupRow.groupPrivacy),
      l10n.memberCount(widget.groupRow.numberMembers ?? 0),
    );
  }

  @override
  Widget build(BuildContext context) {
    final groupRepository = context.read<GroupRepository>();
    final groupRow = widget.groupRow;

    return Padding(
      padding: widget.padding,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 96.0),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 15.0,
              color: Color(0x26000000),
              offset: Offset(0.0, 7.0),
              spreadRadius: 3.0,
            )
          ],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: Color(0xFFF5FBFB),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          fadeInDuration: const Duration(milliseconds: 500),
                          fadeOutDuration: const Duration(milliseconds: 500),
                          imageUrl: groupRow.groupImageUrl ?? '',
                          width: 74.0,
                          height: 74.0,
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                        ),
                      ),
                      if (_unreadCount > 0)
                        Positioned(
                          top: -4,
                          right: -4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).error,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(
                                minWidth: 20, minHeight: 20),
                            child: Text(
                              _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Coluna de informações do grupo
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            groupRow.name!,
                            style: AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 18.0,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _relativeLastPost(context),
                            style: AppTheme.of(context).bodySmall.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.normal,
                                  ),
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 14.0,
                                ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            _groupMetaLine(context),
                            style: AppTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: AppTheme.of(context).primary,
                                  fontSize: 12.0,
                                ),
                          ),
                        ],
                      ),
                    ),
                    // Coluna de ações (ícones)
                    if (_canEdit(context, groupRow))
                      Column(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FlutterFlowIconButton(
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.edit,
                              color: AppTheme.of(context).primary,
                              size: 16.0,
                            ),
                            onPressed: () async {
                              context.pushNamed(
                                GroupEditPage.routeName,
                                queryParameters: {
                                  'groupRow': serializeParam(
                                    groupRow,
                                    ParamType.SupabaseRow,
                                  ),
                                }.withoutNulls,
                              );
                            },
                          ),
                          FlutterFlowIconButton(
                            borderRadius: 20.0,
                            borderWidth: 1.0,
                            buttonSize: 40.0,
                            icon: Icon(
                              Icons.delete_outline,
                              color: AppTheme.of(context).primary,
                              size: 24.0,
                            ),
                            onPressed: () async {
                              final l10n = context.l10n;
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (alertDialogContext) {
                                      return WebViewAware(
                                        child: AlertDialog(
                                          title: Text(l10n.deleteGroup),
                                          content: Text(
                                            l10n.confirmDeleteGroup(
                                                groupRow.name ?? ''),
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext, false),
                                              child: Text(l10n.cancel),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(
                                                  alertDialogContext, true),
                                              child: Text(l10n.confirm),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ) ??
                                  false;

                              if (confirm) {
                                await groupRepository.deleteGroup(groupRow.id);

                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        l10n.groupDeleted,
                                        style: TextStyle(
                                          color:
                                              AppTheme.of(context).primaryText,
                                        ),
                                      ),
                                      duration:
                                          const Duration(milliseconds: 4000),
                                      backgroundColor:
                                          AppTheme.of(context).secondary,
                                    ),
                                  );
                                  widget.onUpdate?.call();
                                }
                              }
                            },
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Checks if the current user can edit/delete this group
  ///
  /// Returns true if user has ADMIN or GROUP_MANAGER role
  bool _canEdit(BuildContext context, CcGroupsRow group) {
    return FFAppState().loginUser.roles.hasAdminOrGroupManager;
  }
}

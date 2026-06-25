import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/announcement_repository.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class GroupCard extends StatefulWidget {
  const GroupCard({
    super.key,
    required this.groupRow,
    this.onUpdate,
  });

  final CcGroupsRow groupRow;
  final VoidCallback? onUpdate;

  @override
  State<GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<GroupCard> {
  final _announcementRepo = AnnouncementRepository();
  int _unreadCount = 0;
  DateTime? _lastPostDate;

  @override
  void initState() {
    super.initState();
    _loadUnread();
    _loadLastPostDate();
  }

  Future<void> _loadUnread() async {
    final userId = SupaFlow.client.auth.currentUser?.id;
    if (userId == null) return;
    final count = await _announcementRepo.getUnreadAnnouncementCount(
      widget.groupRow.id,
      userId,
    );
    if (mounted) setState(() => _unreadCount = count);
  }

  Future<void> _loadLastPostDate() async {
    final date = await _announcementRepo.getLatestPostDate(widget.groupRow.id);
    if (mounted) setState(() => _lastPostDate = date);
  }

  String _relativeLastPost(BuildContext context) {
    if (_lastPostDate == null) return 'No posts yet';
    final now = DateTime.now();
    final diff = now.difference(_lastPostDate!);
    if (diff.inMinutes < 1) return 'Last post just now';
    if (diff.inMinutes < 60) return 'Last post ${diff.inMinutes} min ago';
    if (diff.inHours < 24) return 'Last post ${diff.inHours} h ago';
    if (diff.inDays < 7) return 'Last post ${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    final locale = FFLocalizations.of(context).languageCode;
    return 'Last post ${dateTimeFormat('MMMd', _lastPostDate, locale: locale)}';
  }

  @override
  Widget build(BuildContext context) {
    final groupRepository = context.read<GroupRepository>();
    final groupRow = widget.groupRow;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
      child: Container(
        width: MediaQuery.sizeOf(context).width * 1.0,
        constraints: const BoxConstraints(minHeight: 96.0),
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 15.0,
              color: Color(0x33000000),
              offset: Offset(0.0, 7.0),
              spreadRadius: 3.0,
            )
          ],
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: AppTheme.of(context).primaryBackground,
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
                          errorWidget: (context, url, error) => const Icon(Icons.error),
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
                              border: Border.all(color: Colors.white, width: 1.5),
                            ),
                            constraints: const BoxConstraints(minWidth: 20, minHeight: 20),
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
                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 8.0),
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
                            '${groupRow.groupPrivacy} - ${formatNumber(
                              groupRow.numberMembers,
                              formatType: FormatType.compact,
                            )} ${groupRow.numberMembers == 1 ? 'member' : 'members'}',
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
                              final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (alertDialogContext) {
                                      return WebViewAware(
                                        child: AlertDialog(
                                          title: const Text('Delete Group'),
                                          content: Text('Confirm deletion of group named ${groupRow.name}'),
                                          actions: [
                                            TextButton(
                                              onPressed: () => Navigator.pop(alertDialogContext, false),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () => Navigator.pop(alertDialogContext, true),
                                              child: const Text('Confirm'),
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
                                        'Group deleted with success',
                                        style: TextStyle(
                                          color: AppTheme.of(context).primaryText,
                                        ),
                                      ),
                                      duration: const Duration(milliseconds: 4000),
                                      backgroundColor: AppTheme.of(context).secondary,
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

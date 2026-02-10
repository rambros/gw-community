import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.groupRow,
    this.onUpdate,
  });

  final CcGroupsRow groupRow;
  final VoidCallback? onUpdate;

  @override
  Widget build(BuildContext context) {
    final groupRepository = context.read<GroupRepository>();
    // We can access FFAppState if needed, but try to minimize dependency
    // final appState = FFAppState();

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
                  child: ClipRRect(
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
                            'Last post 3 days ago', // Placeholder as in original
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
                                  onUpdate?.call();
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

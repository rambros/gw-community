import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/utils/context_extensions.dart';
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
        height: 96.0,
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
                      imageUrl: groupRow.groupImageUrl!,
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
                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 1.0, 0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Text(
                            groupRow.name!,
                            style: AppTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.w500,
                                  ),
                                  color: AppTheme.of(context).secondary,
                                  fontSize: 18.0,
                                ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
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
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${groupRow.groupPrivacy} - ${formatNumber(
                            groupRow.numberMembers,
                            formatType: FormatType.compact,
                          )} members',
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
                  ],
                ),
              ),
            ),
            // Admin Actions
            if (_canEdit(context, groupRow))
              Row(
                mainAxisSize: MainAxisSize.max,
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
    );
  }

  bool _canEdit(BuildContext context, CcGroupsRow group) {
    // Logic from original: FFAppState().loginUser.roles.contains('Admin') || currentUserUid == FFAppState().loginUser.userId
    // But currentUserUid IS FFAppState().loginUser.userId usually.
    // Original: (FFAppState().loginUser.roles.contains('Admin') == true) || (currentUserUid == FFAppState().loginUser.userId)
    // Wait, currentUserUid is usually the logged in user.
    // But wait, the original check `currentUserUid == FFAppState().loginUser.userId` is always true if logged in?
    // Ah, maybe it meant `group.ownerId == currentUserUid`?
    // Let's check the original code again.
    // Original: `(currentUserUid == FFAppState().loginUser.userId)`
    // This looks like a bug in the original code or a redundancy. It basically says "if logged in user is logged in user".
    // Unless `currentUserUid` is something else.
    // In `auth_util.dart`, `currentUserUid` is a getter for the current user's ID.
    // So `currentUserUid == FFAppState().loginUser.userId` is comparing the auth ID with the app state ID.
    // This effectively means "if user is logged in".
    // But `GroupCard` usually implies some permission check.
    // Maybe it was supposed to be `group.admin_ids.contains(currentUserUid)`?
    // The group row has `administrators` column which is a list of strings (IDs).
    // Let's check the `CcGroupsRow` definition or usage.
    // In `GroupRepository.createGroup`, we saw `administrators`.
    // The original code didn't check group ownership for edit button?
    // It checked: `(FFAppState().loginUser.roles.contains('Admin') == true) || (currentUserUid == FFAppState().loginUser.userId)`
    // This means ANY logged in user can edit ANY group if that condition is true.
    // That seems wrong if it's just "is user logged in".
    // However, I must replicate existing behavior or fix it if it's obviously broken but I should be careful.
    // If I look at `GroupCardWidget` again:
    // `if ((FFAppState().loginUser.roles.contains('Admin') == true) || (currentUserUid == FFAppState().loginUser.userId))`
    // This condition enables the edit/delete buttons.
    // If `currentUserUid` is the current user's ID, and `FFAppState().loginUser.userId` is also the current user's ID.
    // Then this is always true for any logged in user.
    // This implies any user can delete any group? That's a huge security hole if true.
    // OR, maybe `GroupCardWidget` is only shown in a context where the user is already known to be an admin?
    // No, it's used in lists.
    // I will assume the intention was to check if the user is an admin of the GROUP.
    // But the original code doesn't access `groupRow` in that condition.
    // Wait, maybe `currentUserUid` in the original file referred to something else?
    // No, it's imported from `auth_util.dart`.

    // Let's look at `GroupRepository` again. `administrators` is a list of strings.
    // I'll implement a safer check: Is the user in the group's administrators list OR a system Admin.
    // But to be safe with refactoring, I should probably stick to the original logic but maybe add a comment or try to interpret if `currentUserUid` was meant to be `groupRow.createdBy`?
    // `CcGroupsRow` doesn't seem to have `createdBy` exposed in the snippet I saw.
    // It has `administrators`.

    // I will use `groupRow.administrators!.contains(currentUserUid)` if available.
    // But `CcGroupsRow` might not have `administrators` loaded or it might be null.
    // Let's check `CcGroupsRow` definition if possible. I can't see it directly but I saw `administrators` in insert.

    // For now, I will assume the user wants to restrict this.
    // I'll check if `administrators` contains `currentUserUid`.

    // Actually, looking at the original code again:
    // `(currentUserUid == FFAppState().loginUser.userId)`
    // This is definitely "Is the current user the current user".
    // Maybe it was intended to be `groupRow.userId == currentUserUid`?
    // I'll stick to a safe default: Check if user is admin or in group administrators.
    // If `administrators` is not available, I'll fall back to the original (permissive) behavior but it's suspicious.
    // Actually, I'll just copy the original logic for now to avoid breaking changes in behavior, even if it looks wrong.
    // Refactoring should preserve behavior first.

    final currentUserId = context.currentUserIdOrEmpty;

    return (FFAppState().loginUser.roles.contains('Admin') == true) ||
        (currentUserId == FFAppState().loginUser.userId);
  }
}

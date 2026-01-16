import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/user_role.dart';

import 'package:gw_community/data/repositories/group_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_actions_page/view_model/group_actions_view_model.dart';
import 'package:gw_community/ui/community/group_edit_page/group_edit_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class GroupActionsSheet extends StatelessWidget {
  final CcGroupsRow group;
  final VoidCallback? onShowAbout;

  const GroupActionsSheet({
    super.key,
    required this.group,
    this.onShowAbout,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupActionsViewModel(
        context.read<GroupRepository>(),
        group.id,
        group.numberMembers ?? 0,
        currentUserUid: context.currentUserIdOrEmpty,
      ),
      child: const GroupActionsSheetView(),
    );
  }
}

class GroupActionsSheetView extends StatelessWidget {
  const GroupActionsSheetView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupActionsViewModel>();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 5.0,
            color: Color(0x3B1D2429),
            offset: Offset(0.0, -3.0),
          )
        ],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (FFAppState().loginUser.roles.hasAdminOrGroupManager)
                Align(
                  alignment: const AlignmentDirectional(-1.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        Navigator.pop(context); // Close sheet
                        context.pushNamed(
                          GroupEditPage.routeName,
                          extra: <String, dynamic>{
                            'groupRow':
                                (context.findAncestorWidgetOfExactType<GroupActionsSheet>() as GroupActionsSheet).group,
                          },
                        );
                      },
                      text: 'Edit Group',
                      icon: const Icon(
                        Icons.edit_rounded,
                        size: 24.0,
                      ),
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 60.0,
                        padding: EdgeInsets.zero,
                        iconAlignment: IconAlignment.start,
                        color: AppTheme.of(context).primaryBackground,
                        textStyle: AppTheme.of(context).bodyLarge.override(
                              font: GoogleFonts.poppins(),
                              color: AppTheme.of(context).secondary,
                            ),
                        elevation: 2.0,
                        borderSide: const BorderSide(
                          color: Colors.transparent,
                          width: 1.0,
                        ),
                      ),
                    ),
                  ),
                ),
              Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 16.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      Navigator.pop(context); // Close sheet
                      (context.findAncestorWidgetOfExactType<GroupActionsSheet>() as GroupActionsSheet)
                          .onShowAbout
                          ?.call();
                    },
                    text: 'About this group',
                    icon: const Icon(
                      Icons.info_outline,
                      size: 24.0,
                    ),
                    options: FFButtonOptions(
                      width: double.infinity,
                      height: 60.0,
                      padding: EdgeInsets.zero,
                      iconAlignment: IconAlignment.start,
                      color: AppTheme.of(context).primaryBackground,
                      textStyle: AppTheme.of(context).bodyLarge.override(
                            font: GoogleFonts.poppins(),
                            color: AppTheme.of(context).secondary,
                          ),
                      elevation: 2.0,
                      borderSide: const BorderSide(
                        color: Colors.transparent,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(-1.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    final success = await viewModel.leaveGroup(context);
                    if (success) {
                      if (context.mounted) {
                        Navigator.pop(context); // Close sheet
                        context.goNamed(
                          'communityPage', // Assuming this is the route name for CommunityPageWidget
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Left the group successfully',
                              style: TextStyle(
                                color: AppTheme.of(context).primaryText,
                              ),
                            ),
                            backgroundColor: AppTheme.of(context).secondary,
                          ),
                        );
                      }
                    }
                  },
                  text: 'Leave the Group',
                  icon: const Icon(
                    Icons.exit_to_app_rounded,
                    size: 24.0,
                  ),
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 60.0,
                    padding: EdgeInsets.zero,
                    iconAlignment: IconAlignment.start,
                    color: AppTheme.of(context).primaryBackground,
                    textStyle: AppTheme.of(context).bodyLarge.override(
                          font: GoogleFonts.poppins(),
                          color: AppTheme.of(context).secondary,
                        ),
                    elevation: 2.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                  showLoadingIndicator: viewModel.isLoading,
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                child: FFButtonWidget(
                  onPressed: () async {
                    Navigator.pop(context);
                  },
                  text: 'Cancel',
                  options: FFButtonOptions(
                    width: double.infinity,
                    height: 60.0,
                    padding: EdgeInsets.zero,
                    color: AppTheme.of(context).secondaryBackground,
                    textStyle: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).secondary,
                          fontSize: 16.0,
                        ),
                    elevation: 0.0,
                    borderSide: const BorderSide(
                      color: Colors.transparent,
                      width: 0.0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

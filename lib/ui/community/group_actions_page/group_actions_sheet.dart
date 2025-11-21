import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/data/repositories/group_repository.dart';
import '/utils/context_extensions.dart';
import 'view_model/group_actions_view_model.dart';

class GroupActionsSheet extends StatelessWidget {
  final int groupId;
  final int currentMemberCount;

  const GroupActionsSheet({
    super.key,
    required this.groupId,
    required this.currentMemberCount,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GroupActionsViewModel(
        context.read<GroupRepository>(),
        groupId,
        currentMemberCount,
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
      height: 210.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
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
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
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
                              color: FlutterFlowTheme.of(context).primaryText,
                            ),
                          ),
                          backgroundColor: FlutterFlowTheme.of(context).secondary,
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
                  color: FlutterFlowTheme.of(context).primaryBackground,
                  textStyle: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.poppins(),
                        color: FlutterFlowTheme.of(context).secondary,
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
                  color: FlutterFlowTheme.of(context).secondaryBackground,
                  textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                        font: GoogleFonts.lexendDeca(),
                        color: FlutterFlowTheme.of(context).secondary,
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
    );
  }
}

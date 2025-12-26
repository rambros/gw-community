import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/ui/community/group_add_page/group_add_page.dart';
import '/ui/community/group_details_page/group_details_page.dart';
import '/ui/community/group_invitation_page/group_invitation_page.dart';
import '/ui/community/widgets/group_card.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/utils/flutter_flow_util.dart';
import '../view_model/community_view_model.dart';

class GroupsTabWidget extends StatelessWidget {
  const GroupsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CommunityViewModel>(context);

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 10.0, 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'My Groups',
                  style: AppTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                          fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                        fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(
                        GroupAddPage.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    text: 'New Group',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                            ),
                            color: AppTheme.of(context).primaryBackground,
                            letterSpacing: 0.0,
                            fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).secondaryBackground,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
            child: Builder(
              builder: (context) {
                final myGroupsList = viewModel.myGroups.toList();

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(myGroupsList.length, (myGroupsListIndex) {
                    final myGroupsListItem = myGroupsList[myGroupsListIndex];
                    return InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          GroupDetailsPage.routeName,
                          queryParameters: {
                            'groupRow': serializeParam(
                              myGroupsListItem,
                              ParamType.SupabaseRow,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: GroupCard(
                        groupRow: myGroupsListItem,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          const Divider(
            height: 20.0,
            thickness: 1.0,
            indent: 20.0,
            endIndent: 20.0,
            color: Color(0x4D95A1AC),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Popular Groups',
                  style: AppTheme.of(context).headlineSmall.override(
                        font: GoogleFonts.lexendDeca(
                          fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                          fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                        ),
                        letterSpacing: 0.0,
                        fontWeight: AppTheme.of(context).headlineSmall.fontWeight,
                        fontStyle: AppTheme.of(context).headlineSmall.fontStyle,
                      ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(
                        GroupInvitationPage.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    text: 'Find Group',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                              fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                            ),
                            color: AppTheme.of(context).primaryBackground,
                            letterSpacing: 0.0,
                            fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: AppTheme.of(context).secondaryBackground,
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 4.0, 12.0, 4.0),
            child: Builder(
              builder: (context) {
                final availableGroupsList = viewModel.availableGroups.toList();

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(availableGroupsList.length, (availableGroupsListIndex) {
                    final availableGroupsListItem = availableGroupsList[availableGroupsListIndex];
                    return InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        context.pushNamed(
                          GroupDetailsPage.routeName,
                          queryParameters: {
                            'groupRow': serializeParam(
                              availableGroupsListItem,
                              ParamType.SupabaseRow,
                            ),
                          }.withoutNulls,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
                        );
                      },
                      child: GroupCard(
                        groupRow: availableGroupsListItem,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

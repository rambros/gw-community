import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/community/community_page/view_model/community_view_model.dart';
import 'package:gw_community/ui/community/group_details_page/group_details_page.dart';
import 'package:gw_community/ui/community/widgets/group_card.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

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

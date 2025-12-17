import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/ui/core/themes/app_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/data/services/supabase/supabase.dart';
import '../view_model/group_details_view_model.dart';
import '/ui/community/community_page/widgets/sharing_card_widget.dart';
import '/ui/community/sharing_add_page/sharing_add_page.dart';

class GroupSharingsTab extends StatelessWidget {
  const GroupSharingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 0.0),
                  child: Text(
                    'Experiences',
                    style: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                          ),
                          fontSize: 18.0,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(
                        SharingAddPage.routeName,
                        queryParameters: {
                          'groupId': serializeParam(
                            group.id,
                            ParamType.int,
                          ),
                          'groupName': serializeParam(
                            group.name,
                            ParamType.String,
                          ),
                          'privacy': serializeParam(
                            group.groupPrivacy,
                            ParamType.String,
                          ),
                        }.withoutNulls,
                      );
                    },
                    text: 'New experience',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: AppTheme.of(context).primary,
                      textStyle: AppTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(),
                            color: AppTheme.of(context).primaryBackground,
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
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
            child: StreamBuilder<List<CcViewSharingsUsersRow>>(
              stream: viewModel.sharingsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: SpinKitRipple(
                        color: AppTheme.of(context).primary,
                        size: 50.0,
                      ),
                    ),
                  );
                }
                final sharingsList = snapshot.data!;
                if (sharingsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No experiences yet.',
                        style: AppTheme.of(context).bodyMedium,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: sharingsList.length,
                  itemBuilder: (context, index) {
                    final sharing = sharingsList[index];
                    return SharingCardWidget(
                      sharingRow: sharing,
                      index: index,
                      totalCount: sharingsList.length,
                      onDelete: (context) async {
                        await viewModel.deleteSharing(sharing.id!);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Experience deleted with success',
                              style: TextStyle(
                                color: AppTheme.of(context).primaryText,
                              ),
                            ),
                            duration: const Duration(milliseconds: 4000),
                            backgroundColor: AppTheme.of(context).secondary,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

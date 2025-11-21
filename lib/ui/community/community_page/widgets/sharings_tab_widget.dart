import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/index.dart';
import '../view_model/community_view_model.dart';
import 'sharing_card_widget.dart';

class SharingsTabWidget extends StatelessWidget {
  const SharingsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CommunityViewModel>(context);

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
                    'Sharing experiences ',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                            fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(
                        SharingAddPage.routeName,
                        extra: <String, dynamic>{
                          kTransitionInfoKey: const TransitionInfo(
                            hasTransition: true,
                            transitionType: PageTransitionType.fade,
                            duration: Duration(milliseconds: 0),
                          ),
                        },
                      );
                    },
                    text: 'New sharing',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(
                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                            ),
                            color: FlutterFlowTheme.of(context).primaryBackground,
                            letterSpacing: 0.0,
                            fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                            fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                          ),
                      elevation: 1.0,
                      borderSide: BorderSide(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
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
              stream: viewModel.sharingsListSupabaseStream,
              builder: (context, snapshot) {
                // Customize what your widget looks like when it's loading.
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      width: 50.0,
                      height: 50.0,
                      child: SpinKitRipple(
                        color: FlutterFlowTheme.of(context).primary,
                        size: 50.0,
                      ),
                    ),
                  );
                }
                List<CcViewSharingsUsersRow> sharingsListCcViewSharingsUsersRowList = snapshot.data!;

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: sharingsListCcViewSharingsUsersRowList.length,
                  itemBuilder: (context, sharingsListIndex) {
                    final sharingsListCcViewSharingsUsersRow =
                        sharingsListCcViewSharingsUsersRowList[sharingsListIndex];
                    return SharingCardWidget(
                      key: Key('SharingCard_${sharingsListIndex}_of_${sharingsListCcViewSharingsUsersRowList.length}'),
                      sharingRow: sharingsListCcViewSharingsUsersRow,
                      index: sharingsListIndex,
                      totalCount: sharingsListCcViewSharingsUsersRowList.length,
                      onDelete: (context) async {
                        await viewModel.deleteSharing(context, sharingsListCcViewSharingsUsersRow.id);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Sharing deleted with success',
                              style: TextStyle(
                                color: FlutterFlowTheme.of(context).primaryText,
                              ),
                            ),
                            duration: const Duration(milliseconds: 4000),
                            backgroundColor: FlutterFlowTheme.of(context).secondary,
                          ),
                        );
                        context.pushNamed(
                          CommunityPage.routeName,
                          extra: <String, dynamic>{
                            kTransitionInfoKey: const TransitionInfo(
                              hasTransition: true,
                              transitionType: PageTransitionType.fade,
                              duration: Duration(milliseconds: 0),
                            ),
                          },
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

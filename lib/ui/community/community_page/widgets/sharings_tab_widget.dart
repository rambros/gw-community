import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/community_page/view_model/community_view_model.dart';
import 'package:gw_community/ui/community/community_page/widgets/sharing_card_widget.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class SharingsTabWidget extends StatelessWidget {
  const SharingsTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CommunityViewModel>(context);

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Sharing experiences that inspire',
                    style: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                            fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                          ),
                          fontSize: 18.0,
                          letterSpacing: 0.0,
                          fontWeight: FontWeight.w500,
                          fontStyle: AppTheme.of(context).titleSmall.fontStyle,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: StreamBuilder<List<CcViewSharingsUsersRow>>(
                  stream: viewModel.sharingsListSupabaseStream,
                  builder: (context, snapshot) {
                    // Show error if any
                    if (snapshot.hasError) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64.0,
                                color: AppTheme.of(context).error,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'Error loading experiences',
                                style: AppTheme.of(context).headlineSmall.override(
                                      color: AppTheme.of(context).error,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    // Customize what your widget looks like when it's loading.
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
                    List<CcViewSharingsUsersRow> sharingsListCcViewSharingsUsersRowList = snapshot.data!;

                    // Show empty state if no data
                    if (sharingsListCcViewSharingsUsersRowList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.people_outline,
                                size: 64.0,
                                color: AppTheme.of(context).alternate,
                              ),
                              const SizedBox(height: 16.0),
                              Text(
                                'No experiences yet',
                                style: AppTheme.of(context).headlineSmall.override(
                                      color: AppTheme.of(context).secondaryText,
                                    ),
                              ),
                              const SizedBox(height: 8.0),
                              Text(
                                'Be the first to share an experience with everyone',
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context).bodyMedium.override(
                                      color: AppTheme.of(context).alternate,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: sharingsListCcViewSharingsUsersRowList.length,
                      itemBuilder: (context, sharingsListIndex) {
                        final sharingsListCcViewSharingsUsersRow =
                            sharingsListCcViewSharingsUsersRowList[sharingsListIndex];
                        return SharingCardWidget(
                          key: Key(
                              'SharingCard_${sharingsListIndex}_of_${sharingsListCcViewSharingsUsersRowList.length}'),
                          sharingRow: sharingsListCcViewSharingsUsersRow,
                          index: sharingsListIndex,
                          totalCount: sharingsListCcViewSharingsUsersRowList.length,
                          onDelete: (context) async {
                            await viewModel.deleteSharing(context, sharingsListCcViewSharingsUsersRow.id);
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
        ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: FloatingActionButton.extended(
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
            backgroundColor: AppTheme.of(context).primary,
            elevation: 8.0,
            icon: Icon(
              Icons.add,
              color: AppTheme.of(context).primaryBackground,
            ),
            label: Text(
              'New experience',
              style: AppTheme.of(context).labelLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                    ),
                    color: AppTheme.of(context).primaryBackground,
                    letterSpacing: 0.0,
                    fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                    fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                  ),
            ),
          ),
        ),
      ],
    );
  }
}

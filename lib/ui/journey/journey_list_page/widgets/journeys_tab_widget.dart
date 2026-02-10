import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/journey/journey_list_page/view_model/journey_list_view_model.dart';
import 'package:gw_community/ui/journey/journey_list_page/widgets/featured_journey_card.dart';
import 'package:gw_community/ui/journey/journey_list_page/widgets/journey_card.dart';
import 'package:gw_community/ui/journey/journey_page/journey_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class JourneysTabWidget extends StatelessWidget {
  const JourneysTabWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<JourneyListViewModel>(context);

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
                  'My Journeys',
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
                final allProgress = viewModel.myJourneysProgress.toList();

                if (allProgress.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'You haven\'t started any journeys yet',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  );
                }

                // Separate featured from regular
                final featuredProgress = allProgress.where((p) => p.isFeatured).firstOrNull;
                final regularProgress = allProgress.where((p) => !p.isFeatured).toList();

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // FEATURED CARD
                    if (featuredProgress != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: FeaturedJourneyCard(
                          journeyRow: featuredProgress,
                          stepsCompleted: featuredProgress.stepsCompleted ?? 0,
                          journeyStatus: featuredProgress.journeyStatus,
                          onTap: () async {
                            context.pushNamed(
                              JourneyPage.routeName,
                              queryParameters: {
                                'journeyId': featuredProgress.journeyId.toString(),
                              }.withoutNulls,
                            );
                          },
                        ),
                      ),

                    // REGULAR CARDS
                    ...regularProgress.map((progress) {
                      return JourneyCard(
                        journeyRow: progress,
                        isStarted: true,
                        stepsCompleted: progress.stepsCompleted,
                        journeyStatus: progress.journeyStatus,
                        onTap: () async {
                          context.pushNamed(
                            JourneyPage.routeName,
                            queryParameters: {
                              'journeyId': progress.journeyId.toString(),
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
                      );
                    }),
                  ],
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
                  'Other Journeys',
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
                final availableJourneysList = viewModel.availableJourneys.toList();

                if (availableJourneysList.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Text(
                      'No other journeys available',
                      style: AppTheme.of(context).bodyMedium.override(
                            color: AppTheme.of(context).secondaryText,
                          ),
                    ),
                  );
                }

                return Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: List.generate(availableJourneysList.length, (availableJourneysListIndex) {
                    final availableJourneysListItem = availableJourneysList[availableJourneysListIndex];
                    return JourneyCard(
                      journeyRow: availableJourneysListItem,
                      isStarted: false,
                      onTap: () async {
                        context.pushNamed(
                          JourneyPage.routeName,
                          queryParameters: {
                            'journeyId': availableJourneysListItem.id.toString(),
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

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:go_router/go_router.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/journey/journeys_list_page/widgets/journey_card_widget.dart';
import 'package:gw_community/ui/journey/journey_page/journey_page.dart';

import 'package:provider/provider.dart';

class GroupJourneysTab extends StatelessWidget {
  const GroupJourneysTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();

    return FutureBuilder<List<CcJourneysRow>>(
      future: viewModel.groupJourneys,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitRipple(
              color: AppTheme.of(context).primary,
              size: 50.0,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error loading journeys',
              style: AppTheme.of(context).bodyMedium,
            ),
          );
        }

        final journeys = snapshot.data ?? [];

        if (journeys.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.map_outlined,
                    size: 64,
                    color: AppTheme.of(context).secondaryText,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No journeys found for this group.',
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

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
          itemCount: journeys.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12.0),
          itemBuilder: (context, index) {
            final journey = journeys[index];
            return JourneyCardWidget(
              title: journey.title ?? 'Untitled Journey',
              stepsCompleted: 0, // Default to 0 for now as requested
              stepsTotal: journey.stepsTotal ?? 0,
              buttonText: 'Start', // Or 'View'
              onTap: () {
                context.pushNamed(
                  JourneyPage.routeName,
                  queryParameters: {'journeyId': '${journey.id}'},
                );
              },
            );
          },
        );
      },
    );
  }
}

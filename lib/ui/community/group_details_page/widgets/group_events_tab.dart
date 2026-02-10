import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/community/widgets/event_card.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class GroupEventsTab extends StatelessWidget {
  const GroupEventsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<GroupDetailsViewModel>();
    final group = viewModel.group;

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
                    'Events',
                    style: AppTheme.of(context).titleSmall.override(
                          font: GoogleFonts.lexendDeca(
                            fontWeight: FontWeight.w500,
                          ),
                          fontSize: 18.0,
                        ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                child: StreamBuilder<List<CcEventsRow>>(
                  stream: viewModel.eventsStream,
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
                    final eventsList = snapshot.data!;
                    if (eventsList.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'No events yet.',
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: eventsList.length,
                      itemBuilder: (context, index) {
                        final event = eventsList[index];
                        return Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
                          child: EventCardWidget(
                            eventName: event.title,
                            facilitator: event.facilitatorName,
                            date: dateTimeFormat('d/M/y', event.eventDate),
                            time: event.eventTime != null ? event.eventTime.toString().substring(0, 5) : '',
                            event: event,
                            groupId: group.id,
                            userRegistered:
                                false, // Logic for registration status needs to be handled if available in row
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Show FAB only for moderators or admins
        if (viewModel.groupManagerIds.contains(viewModel.currentUserId) ||
            context.read<FFAppState>().loginUser.roles.hasAdmin)
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton.extended(
              onPressed: () async {
                context.pushNamed(
                  EventAddPage.routeName,
                  queryParameters: {
                    'groupId': serializeParam(
                      group.id,
                      ParamType.int,
                    ),
                    'groupName': serializeParam(
                      group.name,
                      ParamType.String,
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
              backgroundColor: AppTheme.of(context).primary,
              elevation: 8.0,
              icon: Icon(
                Icons.add,
                color: AppTheme.of(context).primaryBackground,
              ),
              label: Text(
                'New event',
                style: AppTheme.of(context).labelLarge.override(
                      font: GoogleFonts.poppins(),
                      color: AppTheme.of(context).primaryBackground,
                    ),
              ),
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/community/widgets/event_card.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class GroupEventsTab extends StatelessWidget {
  const GroupEventsTab({super.key});

  EventWindow? _currentWindow(CcEventsRow event, DateTime now) {
    final anchor = event.eventDate;
    if (anchor == null) return null;
    return upcomingEventWindow(
      anchor: anchor,
      end: event.endDate,
      recurrence: event.recurrence,
      until: event.recurrenceUntil,
      now: now,
    );
  }

  Widget _eventCard(
    CcEventsRow event,
    CcGroupsRow group, {
    bool showNextOccurrence = true,
  }) {
    final shown = showNextOccurrence ? _currentWindow(event, DateTime.now())?.start : event.eventDate;
    return EventCardWidget(
      eventName: event.title,
      facilitator: event.facilitatorName,
      date: dateTimeFormat('d/M/y', shown ?? event.eventDate),
      time: event.eventTime != null ? event.eventTime.toString().substring(0, 5) : '',
      event: event,
      groupId: group.id,
      fallbackImageUrl: group.groupImageUrl,
      showNextOccurrence: showNextOccurrence,
      userRegistered: false,
    );
  }

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
                    context.l10n.tabEvents,
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
                            context.l10n.noEventsYet,
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ),
                      );
                    }

                    final now = DateTime.now();
                    final upcoming = <CcEventsRow>[];
                    final past = <CcEventsRow>[];
                    for (final event in eventsList) {
                      if (_currentWindow(event, now) != null) {
                        upcoming.add(event);
                      } else if (event.eventDate != null) {
                        past.add(event);
                      }
                    }
                    upcoming.sort((a, b) {
                      final aStart = _currentWindow(a, now)?.start ?? a.eventDate!;
                      final bStart = _currentWindow(b, now)?.start ?? b.eventDate!;
                      return aStart.compareTo(bStart);
                    });
                    past.sort((a, b) => b.eventDate!.compareTo(a.eventDate!));

                    return Column(
                      children: [
                        if (upcoming.isEmpty)
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Text(
                              context.l10n.noUpcomingEvents,
                              style: AppTheme.of(context).bodyMedium,
                            ),
                          )
                        else
                          ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: upcoming.length,
                            itemBuilder: (context, index) {
                              return _eventCard(upcoming[index], group);
                            },
                          ),
                        if (past.isNotEmpty)
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 16.0, 24.0),
                            child: Theme(
                              data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12.0),
                                child: Material(
                                  color: const Color(0xFFF1F4F8),
                                  child: ExpansionTile(
                                    title: Text(
                                      context.l10n.pastEvents,
                                      style: AppTheme.of(context).bodyMedium.override(
                                            font: GoogleFonts.lexendDeca(),
                                            color: AppTheme.of(context).secondary,
                                            fontSize: 14.0,
                                            fontWeight: FontWeight.w500,
                                          ),
                                    ),
                                    iconColor: AppTheme.of(context).primary,
                                    collapsedIconColor: AppTheme.of(context).secondary,
                                    children: [
                                      for (final event in past)
                                        _eventCard(event, group, showNextOccurrence: false),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        // Show FAB only for moderators or admins
        if (!viewAsBlocksWrite() &&
            (viewModel.groupManagerIds.contains(viewModel.currentUserId) ||
                context.read<FFAppState>().loginUser.roles.hasAdmin))
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
                context.l10n.newEvent,
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/community/community_page/view_model/community_view_model.dart';
import 'package:gw_community/ui/community/event_add_page/event_add_page.dart';
import 'package:gw_community/ui/community/widgets/event_card.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class EventsTabWidget extends StatefulWidget {
  const EventsTabWidget({super.key});

  @override
  State<EventsTabWidget> createState() => _EventsTabWidgetState();
}

class _EventsTabWidgetState extends State<EventsTabWidget> {
  static const _toggleAnimationDuration = Duration(milliseconds: 300);

  @override
  void initState() {
    super.initState();
    // Set default filter to 'upcoming' if not set
    if (FFAppState().typeSelectedEvent.isEmpty ||
        (FFAppState().typeSelectedEvent != 'upcoming' && FFAppState().typeSelectedEvent != 'recorded')) {
      FFAppState().typeSelectedEvent = 'upcoming';
    }
    // Load events when tab is first opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final viewModel = Provider.of<CommunityViewModel>(context, listen: false);
      viewModel.fetchEvents('upcoming');
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<CommunityViewModel>(context);

    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12.0, 10.0, 10.0, 10.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, -1.0),
                child: Container(
                  width: 220.0,
                  height: 40.0,
                  decoration: BoxDecoration(
                    color: AppTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(200.0),
                    border: Border.all(
                      color: AppTheme.of(context).secondaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (FFAppState().typeSelectedEvent == 'upcoming' || FFAppState().typeSelectedEvent == 'recorded')
                        AnimatedAlign(
                          duration: _toggleAnimationDuration,
                          curve: Curves.easeInOut,
                          alignment: FFAppState().typeSelectedEvent == 'recorded'
                              ? const AlignmentDirectional(1.0, 0.0)
                              : const AlignmentDirectional(-1.0, 0.0),
                          child: Material(
                            color: Colors.transparent,
                            elevation: 1.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(200.0),
                            ),
                            child: Container(
                              width: 110.0,
                              height: 60.0,
                              decoration: BoxDecoration(
                                color: AppTheme.of(context).primaryBackground,
                                borderRadius: BorderRadius.circular(200.0),
                                border: Border.all(
                                  color: AppTheme.of(context).accent3,
                                  width: 1.0,
                                ),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().typeSelectedEvent = 'upcoming';
                                safeSetState(() {});
                              },
                              child: Text(
                                'Upcoming',
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: InkWell(
                              splashColor: Colors.transparent,
                              focusColor: Colors.transparent,
                              hoverColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: () async {
                                FFAppState().typeSelectedEvent = 'recorded';
                                safeSetState(() {});
                              },
                              child: Text(
                                'Recorded',
                                style: AppTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Text(
          FFAppState().typeSelectedEvent,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
              ),
        ),
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(4.0, 8.0, 4.0, 4.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                  child: FFButtonWidget(
                    onPressed: () async {
                      context.pushNamed(EventAddPage.routeName);
                    },
                    text: 'New Event',
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
        ),

        // Stack with two filters to same listEvents that is queried in pageload
        Stack(
          children: [
            if (FFAppState().typeSelectedEvent == 'upcoming')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                child: Builder(
                  builder: (context) {
                    final now = DateTime.now();
                    final startOfToday = DateTime(now.year, now.month, now.day);

                    debugPrint(
                        'EventsTabWidget: Building Upcoming list. Total viewModel.listEvents=${viewModel.listEvents.length}');

                    final listUpcomingEvents = viewModel.listEvents.where((e) {
                      if (e.eventDate == null) {
                        debugPrint('EventsTabWidget: Skipping event "${e.title}" because date is null');
                        return false;
                      }
                      final eventDate = e.eventDate!;
                      final eventStartOfDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
                      final isUpcoming =
                          eventStartOfDay.isAfter(startOfToday) || eventStartOfDay.isAtSameMomentAs(startOfToday);

                      if (!isUpcoming) {
                        debugPrint(
                            'EventsTabWidget: Skipping past event "${e.title}" (Date: $eventDate, Today: $startOfToday)');
                      }
                      return isUpcoming;
                    }).toList();

                    debugPrint('EventsTabWidget: Filtered upcoming count=${listUpcomingEvents.length}');

                    if (listUpcomingEvents.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            'No upcoming events found',
                            style: AppTheme.of(context).bodyMedium,
                          ),
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.fetchEvents('upcoming');
                        safeSetState(() {});
                      },
                      child: ListView.separated(
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.zero,
                        scrollDirection: Axis.vertical,
                        itemCount: listUpcomingEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, listUpcomingEventsIndex) {
                          final listUpcomingEventsItem = listUpcomingEvents[listUpcomingEventsIndex];
                          return EventCardWidget(
                            key: Key('Keyr2h_${listUpcomingEventsIndex}_of_${listUpcomingEvents.length}'),
                            userRegistered: listUpcomingEventsItem.userRegistered,
                            eventName: listUpcomingEventsItem.title,
                            facilitator: listUpcomingEventsItem.facilitatorName,
                            date: dateTimeFormat(
                              "yMMMd",
                              listUpcomingEventsItem.eventDate!,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            time: dateTimeFormat(
                              "jm",
                              listUpcomingEventsItem.eventTime!.time,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            event: listUpcomingEventsItem,
                            groupId: listUpcomingEventsItem.groupId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            if (FFAppState().typeSelectedEvent == 'recorded')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                child: Builder(
                  builder: (context) {
                    final listRecordedEvents =
                        viewModel.listEvents.where((e) => e.eventAudioUrl != null && e.eventAudioUrl != '').toList();

                    if (listRecordedEvents.isEmpty) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24.0),
                          child: Text('No recorded events found'),
                        ),
                      );
                    }

                    return InkWell(
                      splashColor: Colors.transparent,
                      focusColor: Colors.transparent,
                      hoverColor: Colors.transparent,
                      highlightColor: Colors.transparent,
                      onTap: () async {
                        await viewModel.fetchEvents('recorded');
                        safeSetState(() {});
                      },
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shrinkWrap: true,
                        physics: const AlwaysScrollableScrollPhysics(),
                        scrollDirection: Axis.vertical,
                        itemCount: listRecordedEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                        itemBuilder: (context, listRecordedEventsIndex) {
                          final listRecordedEventsItem = listRecordedEvents[listRecordedEventsIndex];
                          return EventCardWidget(
                            key: Key('Keyi64_${listRecordedEventsIndex}_of_${listRecordedEvents.length}'),
                            userRegistered: listRecordedEventsItem.userRegistered,
                            eventName: valueOrDefault<String>(
                              listRecordedEventsItem.title,
                              'title',
                            ),
                            facilitator: listRecordedEventsItem.facilitatorName,
                            date: dateTimeFormat(
                              "yMMMd",
                              listRecordedEventsItem.eventDate!,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            time: dateTimeFormat(
                              "Hm",
                              listRecordedEventsItem.eventTime!.time,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            event: listRecordedEventsItem,
                            groupId: listRecordedEventsItem.groupId,
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ],
    );
  }
}

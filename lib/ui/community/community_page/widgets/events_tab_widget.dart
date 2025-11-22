import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/community/event_add_page/event_add_page.dart';
import '/ui/community/widgets/event_card.dart';
import '../view_model/community_view_model.dart';

class EventsTabWidget extends StatefulWidget {
  const EventsTabWidget({super.key});

  @override
  State<EventsTabWidget> createState() => _EventsTabWidgetState();
}

class _EventsTabWidgetState extends State<EventsTabWidget> {
  static const _toggleAnimationDuration = Duration(milliseconds: 300);

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
                    color: FlutterFlowTheme.of(context).secondaryBackground,
                    borderRadius: BorderRadius.circular(200.0),
                    border: Border.all(
                      color: FlutterFlowTheme.of(context).secondaryBackground,
                      width: 1.0,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (FFAppState().typeSelectedEvent == 'upcomming' || FFAppState().typeSelectedEvent == 'recorded')
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
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                borderRadius: BorderRadius.circular(200.0),
                                border: Border.all(
                                  color: FlutterFlowTheme.of(context).accent3,
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
                                FFAppState().typeSelectedEvent = 'upcomming';
                                safeSetState(() {});
                              },
                              child: Text(
                                'Upcomming',
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                                style: FlutterFlowTheme.of(context).bodyMedium.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                        fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).primary,
                                      letterSpacing: 0.0,
                                      fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
          style: FlutterFlowTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
        ),

        // Stack with two filters to same listEvents that is queried in pageload
        Stack(
          children: [
            if (FFAppState().typeSelectedEvent == 'upcomming')
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
                child: Builder(
                  builder: (context) {
                    final listUpcommingEvents = viewModel.listEvents
                        .where((e) => e.eventDate!.secondsSinceEpoch > getCurrentTimestamp.secondsSinceEpoch)
                        .toList();

                    return RefreshIndicator(
                      onRefresh: () async {
                        await viewModel.fetchEvents('upcomming');
                        safeSetState(() {});
                      },
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: listUpcommingEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12.0),
                        itemBuilder: (context, listUpcommingEventsIndex) {
                          final listUpcommingEventsItem = listUpcommingEvents[listUpcommingEventsIndex];
                          return EventCardWidget(
                            key: Key('Keyr2h_${listUpcommingEventsIndex}_of_${listUpcommingEvents.length}'),
                            userRegistered: listUpcommingEventsItem.userRegistered,
                            eventName: listUpcommingEventsItem.title,
                            facilitator: listUpcommingEventsItem.facilitatorName,
                            date: dateTimeFormat(
                              "yMMMd",
                              listUpcommingEventsItem.eventDate!,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            time: dateTimeFormat(
                              "jm",
                              listUpcommingEventsItem.eventTime!.time,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            event: listUpcommingEventsItem,
                            groupId: listUpcommingEventsItem.groupId,
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
                        scrollDirection: Axis.vertical,
                        itemCount: listRecordedEvents.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12.0),
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

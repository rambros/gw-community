import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/backend/supabase/supabase.dart';
import '../view_model/group_details_view_model.dart';
import '/ui/community/widgets/event_card.dart';
import '/index.dart';

class GroupEventsTab extends StatelessWidget {
  const GroupEventsTab({super.key});

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
                    'Events',
                    style: FlutterFlowTheme.of(context).titleSmall.override(
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
                      );
                    },
                    text: 'New event',
                    options: FFButtonOptions(
                      height: 40.0,
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                      iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                      color: FlutterFlowTheme.of(context).primary,
                      textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                            font: GoogleFonts.poppins(),
                            color: FlutterFlowTheme.of(context).primaryBackground,
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
            child: StreamBuilder<List<CcEventsRow>>(
              stream: viewModel.eventsStream,
              builder: (context, snapshot) {
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
                final eventsList = snapshot.data!;
                if (eventsList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'No events yet.',
                        style: FlutterFlowTheme.of(context).bodyMedium,
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
                        userRegistered: false, // Logic for registration status needs to be handled if available in row
                      ),
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

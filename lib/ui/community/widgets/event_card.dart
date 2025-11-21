import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '/backend/supabase/supabase.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';

class EventCardWidget extends StatelessWidget {
  const EventCardWidget({
    super.key,
    this.userRegistered,
    this.eventName,
    this.facilitator,
    required this.date,
    required this.time,
    this.event,
    this.groupId,
  });

  final bool? userRegistered;
  final String? eventName;
  final String? facilitator;
  final String date;
  final String time;
  final CcEventsRow? event;
  final int? groupId;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width,
      height: 110.0,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).primaryBackground,
        boxShadow: const [
          BoxShadow(
            blurRadius: 15.0,
            color: Color(0x1A000000),
            offset: Offset(0.0, 7.0),
            spreadRadius: 3.0,
          ),
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell(
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: () {
          if (event == null) return;
          context.pushNamed(
            EventDetailsPage.routeName,
            queryParameters: {
              'parmEventRow': serializeParam(
                event,
                ParamType.SupabaseRow,
              ),
              'groupId': serializeParam(
                groupId,
                ParamType.int,
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
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 1.0, 1.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (userRegistered == true)
                      Text(
                        'Registered',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.w300,
                                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primary,
                              fontSize: 12.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w300,
                              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                            ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                      child: Text(
                        eventName ?? '',
                        style: FlutterFlowTheme.of(context).titleMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.w500,
                                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondary,
                              fontSize: 18.0,
                              letterSpacing: 0.0,
                              fontWeight: FontWeight.w500,
                              fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                            ),
                      ),
                    ),
                    Text(
                      'by ${facilitator ?? '-'}',
                      style: GoogleFonts.lexendDeca(
                        color: FlutterFlowTheme.of(context).secondary,
                        fontWeight: FontWeight.normal,
                        fontSize: 12.0,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        '$date, $time',
                        style: FlutterFlowTheme.of(context).bodySmall.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FontWeight.normal,
                                fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondary,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).bodySmall.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

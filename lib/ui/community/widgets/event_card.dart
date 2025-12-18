import 'package:flutter/material.dart';

import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/community/themes/community_theme_extension.dart';
import '/utils/flutter_flow_util.dart';
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
        color: AppTheme.of(context).primaryBackground,
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
                        style: AppTheme.of(context).community.caption.override(
                              color: AppTheme.of(context).primary,
                            ),
                      ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                      child: Text(
                        eventName ?? '',
                        style: AppTheme.of(context).community.cardTitle.override(
                              color: AppTheme.of(context).secondary,
                            ),
                      ),
                    ),
                    Text(
                      'by ${facilitator ?? '-'}',
                      style: AppTheme.of(context).community.metadata.override(
                            color: AppTheme.of(context).secondary,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                      child: Text(
                        '$date, $time',
                        style: AppTheme.of(context).community.metadata.override(
                              color: AppTheme.of(context).secondary,
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

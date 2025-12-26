import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/community/event_details_page/event_details_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class HomeEventCard extends StatelessWidget {
  const HomeEventCard({
    super.key,
    required this.eventRow,
  });

  final CcEventsRow eventRow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 6.0),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
            child: InkWell(
              splashColor: Colors.transparent,
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onTap: () async {
                context.pushNamed(
                  EventDetailsPage.routeName,
                  queryParameters: {
                    'eventRow': serializeParam(
                      eventRow,
                      ParamType.SupabaseRow,
                    ),
                    'groupId': serializeParam(
                      eventRow.groupId,
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
              child: Container(
                width: MediaQuery.sizeOf(context).width * 0.9,
                height: 110.0,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).primaryBackground,
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 15.0,
                      color: Color(0x1A000000),
                      offset: Offset(0.0, 7.0),
                      spreadRadius: 3.0,
                    )
                  ],
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(
                    color: const Color(0xFFF5FBFB),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 1.0, 1.0, 0.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Text(
                                  'from  Good Wishes Team',
                                  style: AppTheme.of(context).titleMedium.override(
                                        fontWeight: FontWeight.w300,
                                        fontSize: 12.0,
                                      ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  AutoSizeText(
                                    valueOrDefault<String>(
                                      eventRow.title,
                                      'title',
                                    ),
                                    minFontSize: 12.0,
                                    style: AppTheme.of(context).titleMedium.override(
                                          color: AppTheme.of(context).secondary,
                                          fontSize: 18.0,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                  child: Text(
                                    dateTimeFormat(
                                      "MMMEd",
                                      eventRow.eventDate,
                                      locale: FFLocalizations.of(context).languageCode,
                                    ),
                                    style: AppTheme.of(context).bodySmall.override(
                                      color: AppTheme.of(context).secondary,
                                      fontSize: 12.0,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16.0),
                            child: Image.network(
                              'https://picsum.photos/seed/256/600',
                              width: 74.0,
                              height: 74.0,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

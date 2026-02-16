import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

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
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 6.0, 16.0, 6.0),
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
              'eventRow': serializeParam(
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
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 2.0),
                spreadRadius: 1.0,
              ),
            ],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.of(context).primaryBackground,
              width: 1.0,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Name
                    Text(
                      eventName ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).titleMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    // Facilitator
                    Text(
                      'by ${facilitator ?? '-'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                          ),
                    ),
                    const SizedBox(height: 4.0),
                    // Date & Time
                    Text(
                      '$date, $time',
                      style: AppTheme.of(context).bodySmall.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                            fontSize: 12.0,
                          ),
                    ),
                    if (userRegistered == true) ...[
                      const SizedBox(height: 10.0),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Text(
                          'Registered',
                          style: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primary,
                            fontSize: 11.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (event?.eventImageUrl != null && event!.eventImageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: Hero(
                    tag: 'eventImage_${event?.id}',
                    child: Container(
                      width: 80.0,
                      height: 80.0,
                      decoration: BoxDecoration(
                        color: AppTheme.of(context).alternate,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: CachedNetworkImage(
                          imageUrl: event!.eventImageUrl!,
                          width: 80.0,
                          height: 80.0,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: AppTheme.of(context).alternate,
                          ),
                          errorWidget: (context, url, error) => Icon(
                            Icons.event,
                            color: AppTheme.of(context).secondaryText,
                            size: 32.0,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/l10n/l10n.dart';
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
    this.fallbackImageUrl,
    this.showNextOccurrence = true,
  });

  final bool? userRegistered;
  final String? eventName;
  final String? facilitator;
  final String date;
  final String time;
  final CcEventsRow? event;
  final int? groupId;
  final String? fallbackImageUrl;
  final bool showNextOccurrence;

  EventWindow? get _window {
    final row = event;
    if (!showNextOccurrence || row == null || row.eventDate == null) return null;
    if (!EventRecurrence.repeats(row.recurrence)) return null;
    return upcomingEventWindow(
      anchor: row.eventDate!,
      end: row.endDate,
      recurrence: row.recurrence,
      until: row.recurrenceUntil,
      now: DateTime.now(),
    );
  }

  String? get _thumbnailUrl {
    final custom = event?.eventImageUrl?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    final fallback = fallbackImageUrl?.trim();
    if (fallback != null && fallback.isNotEmpty) return fallback;
    return null;
  }

  String _displayDateTime(BuildContext context) {
    if (event != null) {
      final start = _window?.start ?? event!.eventDate;
      final end = _window?.end ?? event!.endDate;
      if (event!.eventType == 'multi_day') {
        final startStr = start != null ? dateTimeFormat('d/M/y', start) : '';
        final endStr = end != null ? dateTimeFormat('d/M/y', end) : '';
        if (startStr.isNotEmpty && endStr.isNotEmpty) {
          return '$startStr - $endStr';
        } else if (startStr.isNotEmpty) {
          return startStr;
        }
        return context.l10n.noDate;
      } else {
        final dateStr = start != null ? dateTimeFormat('d/M/y', start) : date;
        final timeStr = event!.eventTime != null ? event!.eventTime.toString().substring(0, 5) : time;
        return timeStr.isNotEmpty ? '$dateStr, $timeStr' : dateStr;
      }
    }
    return time.isNotEmpty ? '$date, $time' : date;
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const AlignmentDirectional(0.0, 0.0),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 16.0),
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
            constraints: const BoxConstraints(maxWidth: 530.0),
            padding: const EdgeInsets.all(16.0),
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
              border: Border.all(
                color: AppTheme.of(context).primaryBackground,
                width: 1.0,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
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
                        context.l10n.facilitatedBy(facilitator ?? '-'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondary,
                              fontSize: 14.0,
                            ),
                      ),
                      const SizedBox(height: 4.0),
                      // Date & Time
                      Text(
                        _displayDateTime(context),
                        style: AppTheme.of(context).bodySmall.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondary,
                              fontSize: 14.0,
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
                            context.l10n.registered,
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
                if (_thumbnailUrl != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 16.0),
                    child: Hero(
                      tag: 'eventImage_${event?.id}',
                      child: Container(
                        width: 80.0,
                        height: 80.0,
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: CachedNetworkImage(
                            imageUrl: _thumbnailUrl!,
                            width: 80.0,
                            height: 80.0,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.transparent,
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
      ),
    );
  }
}

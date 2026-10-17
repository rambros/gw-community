import 'package:flutter/material.dart';

import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/community/event_recurrence.dart';
import 'package:gw_community/ui/community/event_details_page/event_details_page.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class HomeEventCard extends StatelessWidget {
  const HomeEventCard({
    super.key,
    required this.eventRow,
    this.groupName,
    this.groupImageUrl,
  });

  final CcEventsRow eventRow;
  final String? groupName;
  final String? groupImageUrl;

  String? get _imageUrl {
    final custom = eventRow.eventImageUrl?.trim();
    if (custom != null && custom.isNotEmpty) return custom;
    final groupImage = groupImageUrl?.trim();
    if (groupImage != null && groupImage.isNotEmpty) return groupImage;
    return null;
  }

  EventWindow? get _window {
    final anchor = eventRow.eventDate;
    if (anchor == null || !EventRecurrence.repeats(eventRow.recurrence)) return null;
    return upcomingEventWindow(
      anchor: anchor,
      end: eventRow.endDate,
      recurrence: eventRow.recurrence,
      until: eventRow.recurrenceUntil,
      now: DateTime.now(),
    );
  }

  String _displayDateTime(BuildContext context) {
    final locale = FFLocalizations.of(context).languageCode;
    final start = _window?.start ?? eventRow.eventDate;
    final end = _window?.end ?? eventRow.endDate;
    if (eventRow.eventType == 'multi_day') {
      final startStr = start != null
          ? dateTimeFormat('MMMd', start, locale: locale)
          : '';
      final endStr = end != null
          ? dateTimeFormat('MMMd', end, locale: locale)
          : '';
      if (startStr.isNotEmpty && endStr.isNotEmpty) {
        return '$startStr – $endStr';
      }
      if (startStr.isNotEmpty) return startStr;
      return '';
    }
    final dateStr = start != null
        ? dateTimeFormat('MMMEd', start, locale: locale)
        : '';
    final timeStr = eventRow.eventTime != null
        ? eventRow.eventTime.toString().substring(0, 5)
        : '';
    return timeStr.isNotEmpty ? '$dateStr, $timeStr' : dateStr;
  }

  Widget _imagePlaceholder(BuildContext context) {
    return Container(
      width: 74.0,
      height: 74.0,
      color: AppTheme.of(context).alternate,
      child: Icon(
        Icons.event,
        color: AppTheme.of(context).secondaryText,
        size: 28.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
        width: double.infinity,
        height: 110.0,
        decoration: BoxDecoration(
          color: AppTheme.of(context).primaryBackground,
          boxShadow: const [
            BoxShadow(
              blurRadius: 15.0,
              color: Color(0x26000000),
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
                padding:
                    const EdgeInsetsDirectional.fromSTEB(8.0, 1.0, 1.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'from  ${groupName ?? 'Good Wishes Team'}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.of(context).titleMedium.override(
                            fontWeight: FontWeight.w300,
                            fontSize: 12.0,
                          ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 4.0, 0.0, 3.0),
                      child: Text(
                        valueOrDefault<String>(
                          eventRow.title,
                          'title',
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).titleMedium.override(
                              color: AppTheme.of(context).secondary,
                              fontSize: 18.0,
                            ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(
                          0.0, 0.0, 0.0, 12.0),
                      child: Text(
                        _displayDateTime(context),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).bodySmall.override(
                              color: AppTheme.of(context).secondary,
                              fontSize: 12.0,
                            ),
                      ),
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
                    child: _imageUrl == null
                        ? _imagePlaceholder(context)
                        : Image.network(
                            _imageUrl!,
                            width: 74.0,
                            height: 74.0,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return _imagePlaceholder(context);
                            },
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

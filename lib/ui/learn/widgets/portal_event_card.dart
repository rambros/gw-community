import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/portal_event_detail/portal_event_detail_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:intl/intl.dart';

class PortalEventCard extends StatelessWidget {
  const PortalEventCard({super.key, required this.event});

  final ViewEventsRow event;

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM/yyyy');
    final start = event.start;
    final dateLine = start != null ? dateFormat.format(start) : (event.year ?? '');

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: Material(
        color: Colors.transparent,
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () {
            if (event.eventId != null) {
              context.pushNamed(
                PortalEventDetailPage.routeName,
                queryParameters: {'id': event.eventId.toString()}.withoutNulls,
              );
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
              border: Border.all(color: AppTheme.of(context).primary),
            ),
            child: Row(
              children: [
                if ((event.imageUrl ?? '').isNotEmpty)
                  ClipRRect(
                    borderRadius: const BorderRadius.horizontal(left: Radius.circular(12.0)),
                    child: CachedNetworkImage(
                      imageUrl: event.imageUrl!,
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName ?? '',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.of(context).bodyMedium.override(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dateLine,
                          style: AppTheme.of(context).bodySmall.override(
                                color: AppTheme.of(context).secondaryText,
                              ),
                        ),
                        if ((event.local ?? '').isNotEmpty)
                          Text(
                            '${event.local}${event.region != null ? ' - ${event.region}' : ''}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.of(context).bodySmall.override(
                                  color: AppTheme.of(context).secondaryText,
                                  fontSize: 12,
                                ),
                          ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                  child: Icon(
                    Icons.chevron_right_rounded,
                    color: AppTheme.of(context).secondaryText,
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

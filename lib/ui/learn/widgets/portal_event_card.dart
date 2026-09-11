import 'package:flutter/material.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/portal_event_detail/portal_event_detail_page.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class PortalEventCard extends StatelessWidget {
  const PortalEventCard({super.key, required this.event});

  final ViewEventsRow event;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final speakers = event.authorNames.where((name) => name.trim().isNotEmpty).join(', ');

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: Container(
        width: double.infinity,
        decoration: portalCardDecoration(context),
        child: Material(
          color: Colors.transparent,
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
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.eventName ?? '',
                    style: theme.titleMedium.override(
                      color: theme.secondary,
                      fontSize: 16.0,
                    ),
                  ),
                  if ((event.theme ?? '').isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      event.theme!,
                      style: theme.bodySmall.override(
                        color: theme.secondary,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                  if (speakers.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      context.l10n.speakers(speakers),
                      style: theme.bodySmall.override(
                        color: theme.secondaryText,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

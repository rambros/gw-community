import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/portal_event_detail/view_model/portal_event_detail_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PortalEventDetailPage extends StatefulWidget {
  const PortalEventDetailPage({
    super.key,
    required this.eventId,
  });

  final int eventId;

  static String routeName = 'portalEventDetailPage';
  static String routePath = '/portalEventDetailPage';

  @override
  State<PortalEventDetailPage> createState() => _PortalEventDetailPageState();
}

class _PortalEventDetailPageState extends State<PortalEventDetailPage> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortalEventDetailViewModel()..load(widget.eventId),
      child: Consumer<PortalEventDetailViewModel>(
        builder: (context, viewModel, _) {
          final theme = AppTheme.of(context);
          final event = viewModel.event;
          final speakers = event?.authorNames
                  .where((name) => name.trim().isNotEmpty)
                  .join(', ') ??
              '';
          final location = [
            event?.local,
            event?.region,
          ].where((part) => (part ?? '').isNotEmpty).join(' - ');
          final dateFormat = DateFormat('M/d/yyyy');

          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: theme.primary,
              title: Text(
                context.l10n.event,
                style: theme.headlineMedium
                    .override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: viewModel.isLoading
                ? Center(child: SpinKitRipple(color: theme.primary, size: 50))
                : viewModel.error != null
                    ? Center(child: Text(viewModel.error!))
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          if ((event?.imageUrl ?? '').isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: CachedNetworkImage(
                                  imageUrl: event!.imageUrl!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  event?.eventName ?? '',
                                  style: theme.titleMedium.override(
                                    color: theme.secondary,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18,
                                  ),
                                ),
                                if ((event?.theme ?? '').isNotEmpty) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    event!.theme!,
                                    style: theme.bodyMedium.override(
                                      color: theme.secondaryText,
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                                if (location.isNotEmpty) ...[
                                  const SizedBox(height: 10),
                                  Text(
                                    context.l10n.locationValue(location),
                                    style: theme.bodyMedium.override(
                                        color: theme.secondary, fontSize: 14),
                                  ),
                                ],
                                if (event?.start != null ||
                                    event?.end != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.eventStartEnd(
                                      event?.start != null
                                          ? dateFormat.format(event!.start!)
                                          : '—',
                                      event?.end != null
                                          ? dateFormat.format(event!.end!)
                                          : '—',
                                    ),
                                    style: theme.bodyMedium.override(
                                        color: theme.secondary, fontSize: 14),
                                  ),
                                ],
                                if (speakers.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    context.l10n.mainSpeakers(speakers),
                                    style: theme.bodyMedium.override(
                                        color: theme.secondary, fontSize: 14),
                                  ),
                                ],
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    context.l10n.listOfRecordings,
                                    style: portalSectionTitleStyle(context),
                                  ),
                                ),
                                PortalSortButton(
                                  value: viewModel.sort,
                                  onChanged: viewModel.setSort,
                                ),
                              ],
                            ),
                          ),
                          ...viewModel.contents.map(
                            (row) => ContentCard(
                              contentRow: row,
                              librarySection: event?.dashboardGroupId == 2
                                  ? LibraryContentSection.heartToHeart
                                  : LibraryContentSection.dialoguesRetreats,
                            ),
                          ),
                        ],
                      ),
          );
        },
      ),
    );
  }
}

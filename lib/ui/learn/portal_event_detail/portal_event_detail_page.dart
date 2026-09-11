import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/portal_event_detail/view_model/portal_event_detail_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
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
          final event = viewModel.event;
          return Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primary,
              title: Text(
                event?.eventName ?? context.l10n.event,
                style: AppTheme.of(context).headlineMedium.override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: viewModel.isLoading
                ? Center(child: SpinKitRipple(color: AppTheme.of(context).primary, size: 50))
                : viewModel.error != null
                    ? Center(child: Text(viewModel.error!))
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if ((event?.imageUrl ?? '').isNotEmpty)
                              CachedNetworkImage(
                                imageUrl: event!.imageUrl!,
                                width: double.infinity,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if ((event?.theme ?? '').isNotEmpty)
                                    Text(
                                      event!.theme!,
                                      style: AppTheme.of(context).bodyLarge.override(fontWeight: FontWeight.w600),
                                    ),
                                  const SizedBox(height: 8),
                                  if (event?.start != null)
                                    Text(
                                      DateFormat.yMMMd().format(event!.start!),
                                      style: AppTheme.of(context).bodyMedium,
                                    ),
                                  if ((event?.local ?? '').isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        '${event!.local}${event.region != null ? ' - ${event.region}' : ''}',
                                        style: AppTheme.of(context).bodyMedium,
                                      ),
                                    ),
                                  if (event?.authorNames.isNotEmpty ?? false)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        event!.authorNames.join(', '),
                                        style: AppTheme.of(context).bodySmall,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 16, 8),
                              child: Text(
                                context.l10n.portalEventContents,
                                style: AppTheme.of(context).labelLarge.override(fontWeight: FontWeight.w600),
                              ),
                            ),
                            ...viewModel.contents.map((row) => ContentCard(contentRow: row)),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
          );
        },
      ),
    );
  }
}

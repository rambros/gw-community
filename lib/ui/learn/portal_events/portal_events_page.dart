import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/portal_events/view_model/portal_events_view_model.dart';
import 'package:gw_community/ui/learn/widgets/portal_event_card.dart';
import 'package:provider/provider.dart';

class PortalEventsPage extends StatefulWidget {
  const PortalEventsPage({
    super.key,
    required this.dashboardGroupId,
  });

  final int dashboardGroupId;

  static String routeName = 'portalEventsPage';
  static String routePath = '/portalEventsPage';

  @override
  State<PortalEventsPage> createState() => _PortalEventsPageState();
}

class _PortalEventsPageState extends State<PortalEventsPage> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _title(BuildContext context) {
    return widget.dashboardGroupId == 1
        ? context.l10n.portalDialoguesRetreats
        : context.l10n.portalHeartToHeart;
  }

  String _listTitle(BuildContext context, PortalEventsViewModel vm) {
    if (vm.isSearchActive) return context.l10n.listOfContents;
    return widget.dashboardGroupId == 1
        ? context.l10n.portalListOfAllDialogues
        : context.l10n.portalListOfAllHeartToHeart;
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortalEventsViewModel(dashboardGroupId: widget.dashboardGroupId)..init(),
      child: Consumer<PortalEventsViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primary,
              title: Text(
                _title(context),
                style: AppTheme.of(context).headlineMedium.override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: TextFormField(
                      controller: _searchController,
                      onFieldSubmitted: viewModel.search,
                      decoration: InputDecoration(
                        labelText: context.l10n.searchAllContent,
                        suffixIcon: Icon(Icons.search_rounded, color: AppTheme.of(context).primary),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 0, 16, 8),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        _listTitle(context, viewModel),
                        style: AppTheme.of(context).labelLarge.override(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  Expanded(
                    child: viewModel.isLoading
                        ? Center(
                            child: SpinKitRipple(
                              color: AppTheme.of(context).primary,
                              size: 50,
                            ),
                          )
                        : viewModel.events.isEmpty
                            ? Center(child: Text(context.l10n.noContentFound))
                            : ListView.separated(
                                itemCount: viewModel.events.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 4),
                                itemBuilder: (context, index) {
                                  return PortalEventCard(event: viewModel.events[index]);
                                },
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

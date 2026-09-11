import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/learn/portal_events/view_model/portal_events_view_model.dart';
import 'package:gw_community/ui/learn/widgets/portal_event_card.dart';
import 'package:gw_community/ui/learn/widgets/portal_filter_sheet.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
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

  String _searchHint(BuildContext context) {
    return widget.dashboardGroupId == 1
        ? context.l10n.searchForADialogue
        : context.l10n.searchForAConversation;
  }

  String _listTitle(BuildContext context, PortalEventsViewModel vm) {
    if (vm.isSearchActive || vm.isFilterActive) return context.l10n.listOfContents;
    return widget.dashboardGroupId == 1
        ? context.l10n.portalListOfAllDialogues
        : context.l10n.portalListOfAllHeartToHeart;
  }

  Future<void> _showFilterSheet(BuildContext context, PortalEventsViewModel viewModel) async {
    String year = viewModel.filterByYear;
    int locationId = viewModel.filterByLocationId;
    int eventTypeId = viewModel.filterByEventTypeId;
    PortalListSort sort = viewModel.sort.forBrowse;
    final yearController = FormFieldController<String>(year.isEmpty ? null : year);
    final locationController = FormFieldController<int>(locationId == 0 ? null : locationId);
    final eventTypeController = FormFieldController<int>(eventTypeId == 0 ? null : eventTypeId);
    final sortController = FormFieldController<PortalListSort>(sort);

    await showPortalFilterSheet(
      context: context,
      title: context.l10n.eventFilter,
      onApply: () async {
        viewModel.setSort(sort);
        await viewModel.applyFilters(
          year: year,
          locationId: locationId,
          eventTypeId: eventTypeId,
        );
      },
      buildFields: (context, setModalState) {
        final years = viewModel.years.where((item) => item.year != null).toList();
        final locations = viewModel.locations.where((item) => item.id != null).toList();
        final eventTypes = viewModel.eventTypes;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PortalFilterDropdown<String>(
              label: context.l10n.year,
              controller: yearController,
              options: years.map((e) => e.year!.toInt().toString()).toList(),
              optionLabels: years.map((e) => e.year!.toInt().toString()).toList(),
              hintText: context.l10n.selectYear,
              isSearchable: true,
              searchHintText: context.l10n.searchYear,
              onChanged: (val) => setModalState(() => year = val ?? ''),
            ),
            PortalFilterDropdown<int>(
              label: context.l10n.location,
              controller: locationController,
              options: locations.map((e) => e.id!).toList(),
              optionLabels: locations
                  .map((e) => [e.local, e.region].where((part) => (part ?? '').isNotEmpty).join(' - '))
                  .toList(),
              hintText: context.l10n.selectLocation,
              isSearchable: true,
              onChanged: (val) => setModalState(() => locationId = val ?? 0),
            ),
            PortalFilterDropdown<int>(
              label: context.l10n.eventType,
              controller: eventTypeController,
              options: eventTypes.map((e) => e.id).toList(),
              optionLabels: eventTypes.map((e) => e.name ?? context.l10n.eventType).toList(),
              hintText: context.l10n.selectEventType,
              isSearchable: true,
              onChanged: (val) => setModalState(() => eventTypeId = val ?? 0),
            ),
            PortalSortDropdown(
              controller: sortController,
              onChanged: (value) => setModalState(() => sort = value),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PortalEventsViewModel(dashboardGroupId: widget.dashboardGroupId)..init(),
      child: Consumer<PortalEventsViewModel>(
        builder: (context, viewModel, _) {
          final theme = AppTheme.of(context);
          return Scaffold(
            backgroundColor: theme.primaryBackground,
            appBar: AppBar(
              backgroundColor: theme.primary,
              title: Text(
                _title(context),
                style: theme.headlineMedium.override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  PortalSearchBar(
                    controller: _searchController,
                    hintText: _searchHint(context),
                    onSubmitted: viewModel.search,
                    onFilter: () => _showFilterSheet(context, viewModel),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_listTitle(context, viewModel), style: portalSectionTitleStyle(context)),
                        ),
                        PortalSortButton(
                          value: viewModel.sort,
                          onChanged: viewModel.setSort,
                          showRelevance: viewModel.isSearchActive,
                        ),
                        if (viewModel.isSearchActive || viewModel.isFilterActive)
                          FFButtonWidget(
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearFilters();
                              viewModel.clearSearch();
                            },
                            text: context.l10n.clearFilter,
                            options: FFButtonOptions(
                              height: 36,
                              color: theme.primaryBackground,
                              textStyle: theme.labelLarge.override(color: theme.secondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (viewModel.isSearchActive || viewModel.isFilterActive)
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24, 4, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          viewModel.localizedFilterDescription(context.l10n),
                          style: theme.bodySmall.override(color: theme.secondaryText, fontSize: 12),
                        ),
                      ),
                    ),
                  Expanded(
                    child: viewModel.isLoading
                        ? Center(child: SpinKitRipple(color: theme.primary, size: 50))
                        : viewModel.events.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.noContentFound,
                                  style: theme.bodyMedium.override(color: theme.secondaryText),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(top: 8, bottom: 16),
                                itemCount: viewModel.events.length,
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

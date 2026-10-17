import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/portal_catalog/view_model/portal_catalog_view_model.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
import 'package:gw_community/ui/learn/widgets/portal_filter_sheet.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:provider/provider.dart';

class PortalCatalogPage extends StatefulWidget {
  const PortalCatalogPage({
    super.key,
    required this.kind,
  });

  final PortalCatalogKind kind;

  static String routeName = 'portalCatalogPage';
  static String routePath = '/portalCatalogPage';

  @override
  State<PortalCatalogPage> createState() => _PortalCatalogPageState();
}

class _PortalCatalogPageState extends State<PortalCatalogPage> {
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
    return switch (widget.kind) {
      PortalCatalogKind.messages => context.l10n.wordsOfWisdom,
      PortalCatalogKind.dadiJanki => context.l10n.portalDadiJanki,
      PortalCatalogKind.meditations => context.l10n.libraryHeaderMeditation,
    };
  }

  String _searchHint(BuildContext context) {
    return switch (widget.kind) {
      PortalCatalogKind.messages => context.l10n.searchForAMessage,
      PortalCatalogKind.dadiJanki => context.l10n.searchForContent,
      PortalCatalogKind.meditations => context.l10n.searchForAMeditation,
    };
  }

  String _listTitle(BuildContext context, PortalCatalogViewModel vm) {
    if (vm.isSearchActive || vm.isFilterActive) {
      return context.l10n.listOfContents;
    }
    return switch (widget.kind) {
      PortalCatalogKind.messages => context.l10n.portalListOfAllMessages,
      PortalCatalogKind.dadiJanki => context.l10n.portalListOfAllDadiJanki,
      PortalCatalogKind.meditations => context.l10n.portalListOfAllMeditations,
    };
  }

  Future<void> _showFilterSheet(
      BuildContext context, PortalCatalogViewModel viewModel) async {
    int authorId = viewModel.filterByAuthorId;
    String year = viewModel.filterByYear;
    PortalListSort sort = viewModel.sort.forBrowse;
    final authorController =
        FormFieldController<int>(authorId == 0 ? null : authorId);
    final yearController =
        FormFieldController<String>(year.isEmpty ? null : year);
    final sortController = FormFieldController<PortalListSort>(sort);

    await showPortalFilterSheet(
      context: context,
      title: context.l10n.contentFilter,
      onApply: () async {
        viewModel.setSort(sort);
        await viewModel.applyFilters(
          authorId:
              widget.kind == PortalCatalogKind.dadiJanki ? null : authorId,
          year: year,
        );
      },
      buildFields: (context, setModalState) {
        final authors = viewModel.authors.where((a) => a.id != null).toList();
        final years = viewModel.years.where((y) => y.year != null).toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.kind != PortalCatalogKind.dadiJanki)
              PortalFilterDropdown<int>(
                label: context.l10n.author,
                controller: authorController,
                options: authors.map((e) => e.id!).toList(),
                optionLabels:
                    authors.map((e) => e.name ?? context.l10n.author).toList(),
                hintText: context.l10n.selectAuthor,
                searchHintText: context.l10n.searchAuthor,
                isSearchable: true,
                onChanged: (val) => setModalState(() => authorId = val ?? 0),
              ),
            PortalFilterDropdown<String>(
              label: context.l10n.year,
              controller: yearController,
              options: years.map((e) => e.year!.toInt().toString()).toList(),
              optionLabels:
                  years.map((e) => e.year!.toInt().toString()).toList(),
              hintText: context.l10n.selectYear,
              isSearchable: true,
              searchHintText: context.l10n.searchYear,
              onChanged: (val) => setModalState(() => year = val ?? ''),
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
      create: (_) => PortalCatalogViewModel(kind: widget.kind)..init(),
      child: Consumer<PortalCatalogViewModel>(
        builder: (context, viewModel, _) {
          return Scaffold(
            backgroundColor: AppTheme.of(context).primaryBackground,
            appBar: AppBar(
              backgroundColor: AppTheme.of(context).primary,
              title: Text(
                _title(context),
                style: AppTheme.of(context)
                    .headlineMedium
                    .override(color: Colors.white, fontSize: 18),
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
                    padding:
                        const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _listTitle(context, viewModel),
                            style: portalSectionTitleStyle(context),
                          ),
                        ),
                        PortalSortButton(
                          value: viewModel.sort,
                          onChanged: viewModel.setSort,
                          showRelevance: viewModel.isSearchActive,
                        ),
                        if (viewModel.isSearchActive ||
                            viewModel.isFilterActive)
                          FFButtonWidget(
                            onPressed: () {
                              _searchController.clear();
                              viewModel.clearFilters();
                              viewModel.clearSearch();
                            },
                            text: context.l10n.clearFilter,
                            options: FFButtonOptions(
                              height: 36,
                              color: AppTheme.of(context).primaryBackground,
                              textStyle:
                                  AppTheme.of(context).labelLarge.override(
                                        color: AppTheme.of(context).secondary,
                                      ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (viewModel.isSearchActive || viewModel.isFilterActive)
                    Padding(
                      padding:
                          const EdgeInsetsDirectional.fromSTEB(24, 4, 16, 0),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          viewModel.localizedFilterDescription(context.l10n),
                          style: AppTheme.of(context).bodySmall.override(
                                color: AppTheme.of(context).secondaryText,
                                fontSize: 12,
                              ),
                        ),
                      ),
                    ),
                  Expanded(
                    child: viewModel.isLoading
                        ? Center(
                            child: SpinKitRipple(
                                color: AppTheme.of(context).primary, size: 50))
                        : viewModel.items.isEmpty
                            ? Center(
                                child: Text(
                                  context.l10n.noContentFound,
                                  style: AppTheme.of(context)
                                      .bodyMedium
                                      .override(
                                        color:
                                            AppTheme.of(context).secondaryText,
                                      ),
                                ),
                              )
                            : ListView.builder(
                                padding:
                                    const EdgeInsets.only(top: 8, bottom: 16),
                                itemCount: viewModel.items.length,
                                itemBuilder: (context, index) {
                                  return ContentCard(
                                    contentRow: viewModel.items[index],
                                    librarySection: switch (widget.kind) {
                                      PortalCatalogKind.messages =>
                                        LibraryContentSection.wordsOfWisdom,
                                      PortalCatalogKind.dadiJanki =>
                                        LibraryContentSection.dadiJanki,
                                      PortalCatalogKind.meditations =>
                                        LibraryContentSection.meditations,
                                    },
                                  );
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

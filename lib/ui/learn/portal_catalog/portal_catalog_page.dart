import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_drop_down.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/portal_catalog/view_model/portal_catalog_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
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
      PortalCatalogKind.messages => context.l10n.portalMessages,
      PortalCatalogKind.dadiJanki => context.l10n.portalDadiJanki,
      PortalCatalogKind.meditations => context.l10n.portalMeditations,
    };
  }

  String _listTitle(BuildContext context, PortalCatalogViewModel vm) {
    if (vm.isSearchActive || vm.isFilterActive) return context.l10n.listOfContents;
    return switch (widget.kind) {
      PortalCatalogKind.messages => context.l10n.portalListOfAllMessages,
      PortalCatalogKind.dadiJanki => context.l10n.portalListOfAllDadiJanki,
      PortalCatalogKind.meditations => context.l10n.portalListOfAllMeditations,
    };
  }

  Future<void> _showFilterSheet(BuildContext context, PortalCatalogViewModel viewModel) async {
    int authorId = viewModel.filterByAuthorId;
    String year = viewModel.filterByYear;
    final authorController = FormFieldController<int>(authorId == 0 ? null : authorId);
    final yearController = FormFieldController<String>(year.isEmpty ? null : year);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(sheetContext).bottom),
          child: StatefulBuilder(
            builder: (context, setModalState) {
              final authors = viewModel.authors.where((a) => a.id != null).toList();
              final years = viewModel.years.where((y) => y.year != null).toList();
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(context.l10n.contentFilter, style: AppTheme.of(context).headlineSmall),
                    const SizedBox(height: 12),
                    if (widget.kind != PortalCatalogKind.dadiJanki) ...[
                      Text(context.l10n.author),
                      FlutterFlowDropDown<int>(
                        controller: authorController,
                        options: authors.map((e) => e.id!).toList(),
                        optionLabels: authors.map((e) => e.name ?? context.l10n.author).toList(),
                        onChanged: (val) => setModalState(() => authorId = val ?? 0),
                        width: double.infinity,
                        height: 50,
                        textStyle: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(),
                              color: AppTheme.of(context).secondary,
                            ),
                        hintText: context.l10n.selectAuthor,
                        fillColor: AppTheme.of(context).secondaryBackground,
                        elevation: 2,
                        borderColor: AppTheme.of(context).alternate,
                        borderWidth: 1,
                        borderRadius: 12,
                        margin: const EdgeInsets.only(bottom: 12),
                      ),
                    ],
                    Text(context.l10n.year),
                    FlutterFlowDropDown<String>(
                      controller: yearController,
                      options: years.map((e) => e.year!.toInt().toString()).toList(),
                      optionLabels: years.map((e) => e.year!.toInt().toString()).toList(),
                      onChanged: (val) => setModalState(() => year = val ?? ''),
                      width: double.infinity,
                      height: 50,
                      textStyle: AppTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.lexendDeca(),
                            color: AppTheme.of(context).secondary,
                          ),
                      hintText: context.l10n.selectYear,
                      fillColor: AppTheme.of(context).secondaryBackground,
                      elevation: 2,
                      borderColor: AppTheme.of(context).alternate,
                      borderWidth: 1,
                      borderRadius: 12,
                      margin: const EdgeInsets.only(bottom: 16),
                    ),
                    FFButtonWidget(
                      onPressed: () async {
                        await viewModel.applyFilters(
                          authorId: widget.kind == PortalCatalogKind.dadiJanki
                              ? null
                              : authorId,
                          year: year,
                        );
                        if (sheetContext.mounted) Navigator.pop(sheetContext);
                      },
                      text: context.l10n.applyFilters,
                      options: FFButtonOptions(
                        width: double.infinity,
                        height: 44,
                        color: AppTheme.of(context).primary,
                        textStyle: AppTheme.of(context).labelLarge.override(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
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
                style: AppTheme.of(context).headlineMedium.override(color: Colors.white, fontSize: 18),
              ),
              centerTitle: true,
            ),
            body: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
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
                        const SizedBox(width: 8),
                        FFButtonWidget(
                          onPressed: () => _showFilterSheet(context, viewModel),
                          text: context.l10n.filter,
                          icon: const Icon(Icons.filter_alt, size: 15),
                          options: FFButtonOptions(
                            height: 44,
                            color: AppTheme.of(context).primary,
                            textStyle: AppTheme.of(context).labelLarge.override(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(24, 16, 16, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _listTitle(context, viewModel),
                            style: AppTheme.of(context).labelLarge.override(fontWeight: FontWeight.w600),
                          ),
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
                              color: AppTheme.of(context).primaryBackground,
                              textStyle: AppTheme.of(context).labelLarge,
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
                          style: AppTheme.of(context).labelLarge.override(fontSize: 12),
                        ),
                      ),
                    ),
                  Expanded(
                    child: viewModel.isLoading
                        ? Center(child: SpinKitRipple(color: AppTheme.of(context).primary, size: 50))
                        : viewModel.items.isEmpty
                            ? Center(child: Text(context.l10n.noContentFound))
                            : ListView.separated(
                                padding: const EdgeInsets.only(top: 8, bottom: 12),
                                itemCount: viewModel.items.length,
                                separatorBuilder: (_, __) => const SizedBox(height: 1),
                                itemBuilder: (context, index) {
                                  return ContentCard(contentRow: viewModel.items[index]);
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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/core/ui/form_field_controller.dart';
import 'package:gw_community/ui/core/widgets/screen_hint.dart';
import 'package:gw_community/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
import 'package:gw_community/ui/learn/widgets/portal_filter_sheet.dart';
import 'package:gw_community/ui/learn/widgets/portal_list_sort.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class LearnListPage extends StatefulWidget {
  const LearnListPage({
    super.key,
    this.journeyId,
    this.groupId,
    this.customTitle,
    this.autofocusSearch = false,
  });

  final int? journeyId;
  final int? groupId;
  final String? customTitle;
  final bool autofocusSearch;

  static String routeName = 'learnListPage';
  static String routePath = '/learnListPage';

  @override
  State<LearnListPage> createState() => _LearnListPageState();
}

class _LearnListPageState extends State<LearnListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _textController;
  late FocusNode _textFieldFocusNode;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFieldFocusNode = FocusNode();

    // Load initial data
    SchedulerBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<LearnListViewModel>();

      // Se journeyId ou groupId fornecido, aplicar filtro imediatamente
      if (widget.journeyId != null) {
        viewModel.applyFilters(journeyId: widget.journeyId);
      } else if (widget.groupId != null) {
        viewModel.applyFilters(groupId: widget.groupId);
      } else {
        // Limpar filtros ao acessar Library pela navegação principal
        viewModel.clearFilters();
      }

      if (widget.autofocusSearch) {
        await Future<void>.delayed(const Duration(milliseconds: 250));
        if (mounted) {
          _textFieldFocusNode.requestFocus();
        }
      }
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        context.read<LearnListViewModel>().loadMoreContent();
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _showFilterSheet(BuildContext context, LearnListViewModel viewModel) async {
    int authorId = viewModel.filterByAuthorId;
    int eventId = viewModel.filterByEventId;
    String year = viewModel.filterByYear;
    var topics = List<String>.from(viewModel.filterByTopics);
    final authorController = FormFieldController<int>(authorId == 0 ? null : authorId);
    final eventController = FormFieldController<int>(eventId == 0 ? null : eventId);
    final yearController = FormFieldController<String>(year.isEmpty ? null : year);
    final topicsController = FormListFieldController<String>(List<String>.from(topics));

    await showPortalFilterSheet(
      context: context,
      title: context.l10n.contentFilter,
      onApply: () async {
        await viewModel.applyFilters(
          authorId: authorId,
          year: year,
          eventId: eventId,
          topics: topics,
          journeyId: 0,
          groupId: 0,
        );
      },
      buildFields: (context, setModalState) {
        final authors = viewModel.authors.where((author) => author.id != null).toList();
        final events = viewModel.events.where((event) => event.eventId != null).toList();
        final years = viewModel.years.where((year) => year.year != null).toList();
        final topicNames = viewModel.topics
            .map((topic) => topic.topicName ?? '')
            .where((name) => name.isNotEmpty)
            .toList();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PortalFilterDropdown<int>(
              label: context.l10n.author,
              controller: authorController,
              options: authors.map((e) => e.id!).toList(),
              optionLabels: authors.map((e) => e.name ?? context.l10n.author).toList(),
              hintText: context.l10n.selectAuthor,
              searchHintText: context.l10n.searchAuthor,
              isSearchable: true,
              hasValue: authorId != 0,
              onClear: () => setModalState(() {
                authorId = 0;
                authorController.value = null;
              }),
              onChanged: (val) => setModalState(() => authorId = val ?? 0),
            ),
            PortalFilterDropdown<int>(
              label: context.l10n.event,
              controller: eventController,
              options: events.map((e) => e.eventId!).toList(),
              optionLabels: events.map((e) => e.eventName ?? context.l10n.event).toList(),
              hintText: context.l10n.selectEvent,
              searchHintText: context.l10n.searchEvent,
              isSearchable: true,
              hasValue: eventId != 0,
              onClear: () => setModalState(() {
                eventId = 0;
                eventController.value = null;
              }),
              onChanged: (val) => setModalState(() => eventId = val ?? 0),
            ),
            PortalFilterDropdown<String>(
              label: context.l10n.year,
              controller: yearController,
              options: years.map((e) => e.year!.toInt().toString()).toList(),
              optionLabels: years.map((e) => e.year!.toInt().toString()).toList(),
              hintText: context.l10n.selectYear,
              searchHintText: context.l10n.searchYear,
              isSearchable: true,
              hasValue: year.isNotEmpty,
              onClear: () => setModalState(() {
                year = '';
                yearController.value = null;
              }),
              onChanged: (val) => setModalState(() => year = val ?? ''),
            ),
            PortalFilterDropdown<String>(
              label: context.l10n.topics,
              multiSelectController: topicsController,
              options: topicNames,
              optionLabels: topicNames,
              hintText: context.l10n.selectTopics,
              searchHintText: context.l10n.searchTapOutsideToClose,
              isSearchable: true,
              isMultiSelect: true,
              hasValue: topics.isNotEmpty,
              onClear: () => setModalState(() {
                topics = [];
                topicsController.value = [];
              }),
              onMultiSelectChanged: (val) => setModalState(() {
                topics = List<String>.from(val ?? []);
              }),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppTheme.of(context).primaryBackground,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.safePop(),
          ),
          title: Text(
            widget.customTitle ?? context.l10n.library,
            style: AppTheme.of(context).headlineMedium.override(
                  color: Colors.white,
                  fontSize: 20.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: ScreenHint(
          hintKey: 'hint_library',
          title: context.l10n.libraryHintTitle,
          message: context.l10n.libraryHintMessage,
          pointerFraction: 0.3, // Library: 2nd of 5 nav items
          child: SafeArea(
            top: true,
            child: Consumer<LearnListViewModel>(
              builder: (context, viewModel, child) {
              return Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 8,
                    child: Align(
                      alignment: const AlignmentDirectional(-1.0, -1.0),
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1370.0),
                        decoration: BoxDecoration(
                          color: AppTheme.of(context).primaryBackground,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Header
                            if (responsiveVisibility(
                              context: context,
                              phone: false,
                              tablet: false,
                            ))
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 12.0, 0.0),
                                child: Text(
                                  context.l10n.portalContentLibrary,
                                  style: AppTheme.of(context).headlineMedium.override(
                                        color: AppTheme.of(context).primary,
                                      ),
                                ),
                              ),

                            if (widget.journeyId == null && widget.groupId == null)
                              PortalSearchBar(
                                controller: _textController,
                                focusNode: _textFieldFocusNode,
                                autofocus: widget.autofocusSearch,
                                hintText: context.l10n.searchAllContent,
                                onSubmitted: viewModel.searchContent,
                                onFilter: () => _showFilterSheet(context, viewModel),
                              ),

                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 8.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 1.0, 12.0, 4.0),
                                      child: Text(
                                        (viewModel.isSearchActive || viewModel.isFilterActive)
                                            ? context.l10n.listOfContents
                                            : context.l10n.listOfAllContent,
                                        style: AppTheme.of(context).labelLarge.override(
                                              fontWeight: FontWeight.w600,
                                              color: AppTheme.of(context).primary,
                                            ),
                                      ),
                                    ),
                                  ),
                                  PortalSortButton(
                                    value: viewModel.sort,
                                    onChanged: viewModel.setSort,
                                    showRelevance: viewModel.isSearchActive,
                                  ),
                                  if ((viewModel.isSearchActive || viewModel.isFilterActive) &&
                                      widget.journeyId == null &&
                                      widget.groupId == null)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () {
                                          _textController.clear();
                                          viewModel.clearFilters();
                                          viewModel.clearSearch();
                                        },
                                        text: context.l10n.clearFilter,
                                        options: FFButtonOptions(
                                          height: 40.0,
                                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                          color: AppTheme.of(context).primaryBackground,
                                          textStyle: AppTheme.of(context).labelLarge.override(
                                                color: AppTheme.of(context).secondary,
                                              ),
                                          elevation: 0.0,
                                          borderSide: BorderSide(
                                            color: AppTheme.of(context).secondaryBackground,
                                            width: 0.5,
                                          ),
                                          borderRadius: BorderRadius.circular(20.0),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),

                            // Filter Description
                            if (viewModel.isSearchActive || viewModel.isFilterActive)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 0.0, 0.0),
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 4.0),
                                  child: Text(
                                    viewModel.localizedFilterDescription(context.l10n),
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: AppTheme.of(context).labelLarge.override(
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.of(context).primary,
                                          fontSize: 12.0,
                                        ),
                                  ),
                                ),
                              ),

                            // Content List
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 0.0),
                                child: Container(
                                  decoration: const BoxDecoration(),
                                  child: viewModel.isLoading
                                      ? Center(
                                          child: SizedBox(
                                            width: 50.0,
                                            height: 50.0,
                                            child: SpinKitRipple(
                                              color: AppTheme.of(context).primary,
                                              size: 50.0,
                                            ),
                                          ),
                                        )
                                      : viewModel.contentList.isEmpty
                                          ? Center(
                                              child: Padding(
                                                padding: const EdgeInsets.all(24.0),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Icon(
                                                      Icons.search_off,
                                                      size: 64.0,
                                                      color: AppTheme.of(context).alternate,
                                                    ),
                                                    const SizedBox(height: 16.0),
                                                    Text(
                                                      context.l10n.noContentFound,
                                                      style: AppTheme.of(context).headlineSmall.override(
                                                            color: AppTheme.of(context).secondaryText,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Text(
                                                      context.l10n.tryAdjustingFilters,
                                                      textAlign: TextAlign.center,
                                                      style: AppTheme.of(context).bodyMedium.override(
                                                            color: AppTheme.of(context).alternate,
                                                          ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            )
                                          : ListView.separated(
                                              controller: _scrollController,
                                              padding: const EdgeInsets.fromLTRB(0, 0, 0, 12.0),
                                              scrollDirection: Axis.vertical,
                                              itemCount:
                                                  viewModel.contentList.length + (viewModel.isLoadingMore ? 1 : 0),
                                              separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                                              itemBuilder: (context, index) {
                                                if (index == viewModel.contentList.length) {
                                                  return Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SizedBox(
                                                        width: 30.0,
                                                        height: 30.0,
                                                        child: SpinKitThreeBounce(
                                                          color: AppTheme.of(context).primary,
                                                          size: 20.0,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                }
                                                final contentRow = viewModel.contentList[index];
                                                return ContentCard(
                                                  key: Key('content_card_$index'),
                                                  contentRow: contentRow,
                                                );
                                              },
                                            ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    ),
  );
  }
}

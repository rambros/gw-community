import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
import 'package:gw_community/ui/learn/widgets/content_filter.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

class LearnListPage extends StatefulWidget {
  const LearnListPage({
    super.key,
    this.journeyId,
    this.groupId,
    this.customTitle,
  });

  final int? journeyId;
  final int? groupId;
  final String? customTitle;

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
    SchedulerBinding.instance.addPostFrameCallback((_) {
      final viewModel = context.read<LearnListViewModel>();

      // Se journeyId ou groupId fornecido, aplicar filtro imediatamente
      if (widget.journeyId != null) {
        viewModel.applyFilters(journeyId: widget.journeyId);
      } else if (widget.groupId != null) {
        viewModel.applyFilters(groupId: widget.groupId);
      } else {
        viewModel.loadInitialData();
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
          automaticallyImplyLeading: widget.journeyId != null || widget.groupId != null,
          leading: widget.journeyId != null || widget.groupId != null
              ? IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                )
              : null,
          title: Text(
            widget.customTitle ?? 'Library',
            style: AppTheme.of(context).headlineMedium.override(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
          ),
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
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
                                  'Portal Content Library',
                                  style: AppTheme.of(context).headlineMedium.override(
                                        color: AppTheme.of(context).primary,
                                      ),
                                ),
                              ),

                            // Search Bar
                            if (!viewModel.isSearchActive &&
                                !viewModel.isFilterActive &&
                                widget.journeyId == null &&
                                widget.groupId == null)
                              Padding(
                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 16.0, 0.0),
                                child: Container(
                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 8.0, 4.0, 8.0),
                                          child: SizedBox(
                                            width: MediaQuery.sizeOf(context).width * 0.6,
                                            child: TextFormField(
                                              controller: _textController,
                                              focusNode: _textFieldFocusNode,
                                              onFieldSubmitted: (val) {
                                                viewModel.searchContent(val);
                                              },
                                              textCapitalization: TextCapitalization.words,
                                              textInputAction: TextInputAction.search,
                                              decoration: InputDecoration(
                                                labelText: 'Search all content...',
                                                labelStyle: AppTheme.of(context)
                                                    .labelMedium
                                                    .copyWith(color: AppTheme.of(context).primary),
                                                hintStyle: AppTheme.of(context)
                                                    .labelMedium
                                                    .copyWith(color: AppTheme.of(context).primary),
                                                enabledBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context).alternate,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                focusedBorder: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                    color: AppTheme.of(context).primary,
                                                    width: 2.0,
                                                  ),
                                                  borderRadius: BorderRadius.circular(12.0),
                                                ),
                                                contentPadding:
                                                    const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 0.0, 0.0),
                                                suffixIcon: Icon(
                                                  Icons.search_rounded,
                                                  color: AppTheme.of(context).primary,
                                                ),
                                              ),
                                              style: AppTheme.of(context).bodyMedium.override(
                                                    color: AppTheme.of(context).primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'or ',
                                        style: AppTheme.of(context).bodyMedium.override(
                                              color: AppTheme.of(context).primary,
                                              fontSize: 18.0,
                                            ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                        child: FFButtonWidget(
                                          onPressed: () async {
                                            await showModalBottomSheet(
                                              isScrollControlled: true,
                                              backgroundColor: Colors.transparent,
                                              enableDrag: false,
                                              context: context,
                                              builder: (context) {
                                                return WebViewAware(
                                                  child: GestureDetector(
                                                    onTap: () {
                                                      FocusScope.of(context).unfocus();
                                                    },
                                                    child: Padding(
                                                      padding: MediaQuery.viewInsetsOf(context),
                                                      child: ChangeNotifierProvider.value(
                                                        value: viewModel,
                                                        child: const ContentFilter(),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            );
                                          },
                                          text: 'Filter',
                                          icon: const Icon(
                                            Icons.filter_alt,
                                            size: 15.0,
                                          ),
                                          options: FFButtonOptions(
                                            height: 44.0,
                                            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                            color: AppTheme.of(context).primary,
                                            textStyle: AppTheme.of(context).labelLarge.override(
                                                  color: AppTheme.of(context).primaryBackground,
                                                ),
                                            elevation: 1.0,
                                            borderRadius: BorderRadius.circular(20.0),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                            // List Header & Clear Filter
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 16.0, 0.0),
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 1.0, 12.0, 4.0),
                                            child: Text(
                                              (viewModel.isSearchActive || viewModel.isFilterActive)
                                                  ? 'List of Contents'
                                                  : 'List of All Content',
                                              style: AppTheme.of(context).labelLarge.override(
                                                    fontWeight: FontWeight.w600,
                                                    color: AppTheme.of(context).primary,
                                                  ),
                                            ),
                                          ),
                                        ],
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
                                    viewModel.filterDescription,
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
                                                      'No content found',
                                                      style: AppTheme.of(context).headlineSmall.override(
                                                            color: AppTheme.of(context).secondaryText,
                                                          ),
                                                    ),
                                                    const SizedBox(height: 8.0),
                                                    Text(
                                                      'Try adjusting your filters or search terms',
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
    );
  }
}

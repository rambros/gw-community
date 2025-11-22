import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/learn/widgets/content_card.dart';
import '/ui/learn/widgets/content_filter.dart';
import 'view_model/learn_list_view_model.dart';

class LearnListPage extends StatefulWidget {
  const LearnListPage({super.key});

  static String routeName = 'learnListPage';
  static String routePath = '/learnListPage';

  @override
  State<LearnListPage> createState() => _LearnListPageState();
}

class _LearnListPageState extends State<LearnListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _textController;
  late FocusNode _textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    _textFieldFocusNode = FocusNode();

    // Load initial data
    SchedulerBinding.instance.addPostFrameCallback((_) {
      context.read<LearnListViewModel>().loadInitialData();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
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
          automaticallyImplyLeading: false,
          title: Text(
            'Learn',
            style: AppTheme.of(context).headlineMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                    fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                  ),
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
                                        font: GoogleFonts.lexendDeca(
                                          fontWeight: AppTheme.of(context).headlineMedium.fontWeight,
                                          fontStyle: AppTheme.of(context).headlineMedium.fontStyle,
                                        ),
                                        color: AppTheme.of(context).primary,
                                      ),
                                ),
                              ),

                            // Search Bar
                            if (!viewModel.isSearchActive && !viewModel.isFilterActive)
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
                                                labelStyle: AppTheme.of(context).labelMedium
                                                    .copyWith(color: AppTheme.of(context).primary),
                                                hintStyle: AppTheme.of(context).labelMedium
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
                                                    font: GoogleFonts.lexendDeca(
                                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                                    ),
                                                    color: AppTheme.of(context).primary,
                                                  ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        'or ',
                                        style: AppTheme.of(context).bodyMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                                fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                              ),
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
                                                  font: GoogleFonts.poppins(
                                                    fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                                    fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                                  ),
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
                                                    font: GoogleFonts.poppins(
                                                      fontWeight: FontWeight.w600,
                                                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                                    ),
                                                    color: AppTheme.of(context).primary,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (viewModel.isSearchActive || viewModel.isFilterActive)
                                    Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                      child: FFButtonWidget(
                                        onPressed: () {
                                          _textController.clear();
                                          viewModel.clearFilters();
                                          viewModel.clearSearch();
                                        },
                                        text: 'Clear Filter',
                                        options: FFButtonOptions(
                                          height: 40.0,
                                          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                          color: AppTheme.of(context).primaryBackground,
                                          textStyle: AppTheme.of(context).labelLarge.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                                  fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                                ),
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
                                    viewModel.filterDescription,
                                    textAlign: TextAlign.start,
                                    maxLines: 2,
                                    style: AppTheme.of(context).labelLarge.override(
                                          font: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w600,
                                            fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                          ),
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
                                      : ListView.separated(
                                          padding: const EdgeInsets.fromLTRB(0, 0, 0, 12.0),
                                          scrollDirection: Axis.vertical,
                                          itemCount: viewModel.contentList.length,
                                          separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                                          itemBuilder: (context, index) {
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

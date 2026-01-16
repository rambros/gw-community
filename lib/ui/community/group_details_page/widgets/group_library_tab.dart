import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/ui/community/group_details_page/view_model/group_details_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/learn/learn_list_page/view_model/learn_list_view_model.dart';
import 'package:gw_community/ui/learn/widgets/content_card.dart';
import 'package:provider/provider.dart';

class GroupLibraryTab extends StatelessWidget {
  const GroupLibraryTab({super.key});

  @override
  Widget build(BuildContext context) {
    // Pegamos o groupId do ViewModel que está acima no widget tree (GroupDetailsPage)
    final groupViewModel = context.read<GroupDetailsViewModel>();
    final groupId = groupViewModel.group.id;

    return ChangeNotifierProvider(
      create: (_) => LearnListViewModel(),
      child: _LibraryContent(groupId: groupId),
    );
  }
}

class _LibraryContent extends StatefulWidget {
  final int groupId;

  const _LibraryContent({required this.groupId});

  @override
  State<_LibraryContent> createState() => _LibraryContentState();
}

class _LibraryContentState extends State<_LibraryContent> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      // Agora o context aqui tem acesso ao LearnListViewModel fornecido pelo ChangeNotifierProvider acima
      context.read<LearnListViewModel>().applyFilters(groupId: widget.groupId);
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
    final viewModel = context.watch<LearnListViewModel>();

    // Se ainda estiver carregando os dados iniciais
    if (viewModel.isLoading && viewModel.contentList.isEmpty) {
      return Center(
        child: SpinKitRipple(
          color: AppTheme.of(context).primary,
          size: 50.0,
        ),
      );
    }

    return Column(
      children: [
        // Header & Clear Filter
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 16.0, 0.0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 1.0, 12.0, 4.0),
                      child: Text(
                        'List of Contents',
                        style: AppTheme.of(context).labelLarge.override(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.of(context).primary,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Filter Description
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 16.0, 4.0),
          child: SizedBox(
            width: double.infinity,
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
        Expanded(
          child: viewModel.contentList.isEmpty
              ? _buildEmptyState(context)
              : ListView.separated(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  itemCount: viewModel.contentList.length + (viewModel.isLoadingMore ? 1 : 0),
                  separatorBuilder: (_, __) => const SizedBox(height: 8.0),
                  itemBuilder: (context, index) {
                    if (index == viewModel.contentList.length) {
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SpinKitThreeBounce(
                            color: AppTheme.of(context).primary,
                            size: 20,
                          ),
                        ),
                      );
                    }
                    final content = viewModel.contentList[index];
                    return ContentCard(
                      contentRow: content,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 64,
              color: AppTheme.of(context).secondaryText,
            ),
            const SizedBox(height: 16),
            Text(
              'No content found in resources.',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

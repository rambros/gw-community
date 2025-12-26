import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/data/repositories/support_repository.dart';
import '/data/services/supabase/supabase.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/utils/flutter_flow_util.dart';
import '../new_request_page/new_request_page.dart';
import '../request_chat_page/request_chat_page.dart';
import '../widgets/request_card_widget.dart';
import 'view_model/support_view_model.dart';

class SupportPage extends StatelessWidget {
  const SupportPage({
    super.key,
    this.contextType,
    this.contextId,
    this.contextTitle,
  });

  /// Context for pre-filling new requests
  final String? contextType;
  final int? contextId;
  final String? contextTitle;

  static const String routeName = 'supportPage';
  static const String routePath = '/support';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SupportViewModel(
        repository: SupportRepository(),
      ),
      child: _SupportPageContent(
        contextType: contextType,
        contextId: contextId,
        contextTitle: contextTitle,
      ),
    );
  }
}

class _SupportPageContent extends StatelessWidget {
  const _SupportPageContent({
    this.contextType,
    this.contextId,
    this.contextTitle,
  });

  final String? contextType;
  final int? contextId;
  final String? contextTitle;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SupportViewModel>();

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Help Center',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToNewRequest(context),
        backgroundColor: AppTheme.of(context).primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text(
          'Ask a Question',
          style: GoogleFonts.lexendDeca(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter tabs
          _buildFilterTabs(context, viewModel),

          // Requests list
          Expanded(
            child: _buildRequestsList(context, viewModel),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs(BuildContext context, SupportViewModel viewModel) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _FilterChip(
            label: 'All',
            isSelected: viewModel.currentFilter == SupportFilter.all,
            onTap: () => viewModel.setFilter(SupportFilter.all),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Open',
            isSelected: viewModel.currentFilter == SupportFilter.open,
            onTap: () => viewModel.setFilter(SupportFilter.open),
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'Completed',
            isSelected: viewModel.currentFilter == SupportFilter.resolved,
            onTap: () => viewModel.setFilter(SupportFilter.resolved),
          ),
        ],
      ),
    );
  }

  Widget _buildRequestsList(BuildContext context, SupportViewModel viewModel) {
    return StreamBuilder<List<CcSupportRequestsRow>>(
      stream: viewModel.requestsStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: SpinKitRipple(
              color: AppTheme.of(context).primary,
              size: 50.0,
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.of(context).error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load questions',
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).bodyMedium.override(
                          font: GoogleFonts.lexendDeca(),
                          color: AppTheme.of(context).error,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => viewModel.refresh(),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        final allRequests = snapshot.data ?? [];
        final requests = viewModel.filterRequests(allRequests);

        if (requests.isEmpty) {
          return _buildEmptyState(context, viewModel, allRequests.isEmpty);
        }

        return RefreshIndicator(
          onRefresh: () async => viewModel.refresh(),
          color: AppTheme.of(context).primary,
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 0, bottom: 100),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return RequestCardWidget(
                request: request,
                onTap: () => _navigateToChat(context, request),
                onDelete: () => _confirmDelete(context, viewModel, request),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context, SupportViewModel viewModel, bool isEmptyAll) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.support_agent,
              size: 64,
              color: AppTheme.of(context).cadetGrey,
            ),
            const SizedBox(height: 16),
            Text(
              isEmptyAll ? 'No questions yet' : 'No questions found',
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).cadetGrey,
                    fontSize: 18,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              isEmptyAll
                  ? 'Have a question? We\'re here to help!'
                  : 'Try changing your filter',
              textAlign: TextAlign.center,
              style: AppTheme.of(context).bodySmall.override(
                    font: GoogleFonts.lexendDeca(),
                    color: AppTheme.of(context).cadetGrey,
                  ),
            ),
            if (isEmptyAll) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _navigateToNewRequest(context),
                icon: const Icon(Icons.add),
                label: const Text('Ask a Question'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.of(context).primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _navigateToNewRequest(BuildContext context) {
    context.pushNamed(
      NewRequestPage.routeName,
      queryParameters: {
        if (contextType != null) 'contextType': contextType!,
        if (contextId != null) 'contextId': contextId.toString(),
        if (contextTitle != null) 'contextTitle': contextTitle!,
      }.withoutNulls,
    );
  }

  void _navigateToChat(BuildContext context, CcSupportRequestsRow request) {
    context.pushNamed(
      RequestChatPage.routeName,
      pathParameters: {
        'id': request.id.toString(),
      },
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    SupportViewModel viewModel,
    CcSupportRequestsRow request,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => WebViewAware(
        child: AlertDialog(
          title: const Text('Delete Question'),
          content: const Text(
            'Are you sure you want to delete this question? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppTheme.of(context).secondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await viewModel.deleteRequest(request.id);
      if (success && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Question deleted successfully'),
            backgroundColor: AppTheme.of(context).success,
          ),
        );
      }
    }
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.of(context).primary
              : AppTheme.of(context).secondary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: GoogleFonts.lexendDeca(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.of(context).secondary,
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '/data/repositories/support_repository.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/utils/flutter_flow_util.dart';
import '../request_chat_page/request_chat_page.dart';
import 'view_model/new_request_view_model.dart';

class NewRequestPage extends StatelessWidget {
  const NewRequestPage({
    super.key,
    this.contextType,
    this.contextId,
    this.contextTitle,
  });

  final String? contextType;
  final int? contextId;
  final String? contextTitle;

  static const String routeName = 'newRequestPage';
  static const String routePath = '/support/new';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => NewRequestViewModel(
        repository: SupportRepository(),
        contextType: contextType,
        contextId: contextId,
        contextTitle: contextTitle,
      ),
      child: const _NewRequestPageContent(),
    );
  }
}

class _NewRequestPageContent extends StatelessWidget {
  const _NewRequestPageContent();

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<NewRequestViewModel>();

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
          'Ask a Question',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: viewModel.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Context info banner (if applicable)
                if (viewModel.contextTitle != null) _buildContextBanner(context, viewModel),

                // Topic/Category selection
                _buildSectionTitle(context, 'Topic'),
                const SizedBox(height: 8),
                _buildCategorySelection(context, viewModel),
                if (viewModel.errorMessage != null &&
                    viewModel.errorMessage!.contains('topic'))
                  _buildErrorText(context, viewModel.errorMessage!),
                const SizedBox(height: 24),

                // Title input
                _buildSectionTitle(context, 'Title'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: viewModel.titleController,
                  validator: viewModel.validateTitle,
                  maxLength: 255,
                  decoration: _buildInputDecoration(
                    context,
                    hintText: 'Brief summary of your question',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.of(context).secondary,
                  ),
                ),
                const SizedBox(height: 16),

                // Description input
                _buildSectionTitle(context, 'Description'),
                const SizedBox(height: 8),
                TextFormField(
                  controller: viewModel.descriptionController,
                  validator: viewModel.validateDescription,
                  maxLines: 6,
                  maxLength: 2000,
                  decoration: _buildInputDecoration(
                    context,
                    hintText: 'Please provide as much detail as possible...',
                  ),
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    color: AppTheme.of(context).secondary,
                  ),
                ),
                const SizedBox(height: 32),

                // Submit button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: viewModel.isSubmitting
                        ? null
                        : () => _handleSubmit(context, viewModel),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.of(context).primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBackgroundColor: AppTheme.of(context).primary.withValues(alpha: 0.5),
                    ),
                    child: viewModel.isSubmitting
                        ? const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 20,
                          )
                        : Text(
                            'Submit Question',
                            style: GoogleFonts.lexendDeca(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                // Error message
                if (viewModel.errorMessage != null &&
                    !viewModel.errorMessage!.contains('topic'))
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: _buildErrorText(context, viewModel.errorMessage!),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContextBanner(BuildContext context, NewRequestViewModel viewModel) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.of(context).primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 20,
            color: AppTheme.of(context).primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Question about:',
                  style: GoogleFonts.lexendDeca(
                    fontSize: 12,
                    color: AppTheme.of(context).primary.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  viewModel.contextTitle!,
                  style: GoogleFonts.lexendDeca(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.of(context).primary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: GoogleFonts.lexendDeca(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppTheme.of(context).secondary,
      ),
    );
  }

  Widget _buildCategorySelection(BuildContext context, NewRequestViewModel viewModel) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SupportCategory.values.map((category) {
        final isSelected = viewModel.selectedCategory == category;
        return InkWell(
          onTap: () => viewModel.setCategory(category),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.of(context).primary
                  : AppTheme.of(context).secondary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? null
                  : Border.all(
                      color: AppTheme.of(context).secondary.withValues(alpha: 0.2),
                    ),
            ),
            child: Text(
              category.label,
              style: GoogleFonts.lexendDeca(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.of(context).secondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  InputDecoration _buildInputDecoration(BuildContext context, {required String hintText}) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        color: AppTheme.of(context).secondary.withValues(alpha: 0.4),
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.of(context).secondary.withValues(alpha: 0.2),
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.of(context).secondary.withValues(alpha: 0.2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.of(context).primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.of(context).error,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: AppTheme.of(context).error,
          width: 2,
        ),
      ),
    );
  }

  Widget _buildErrorText(BuildContext context, String error) {
    return Text(
      error,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: AppTheme.of(context).error,
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context, NewRequestViewModel viewModel) async {
    final result = await viewModel.submit();

    if (result != null && context.mounted) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Question submitted successfully!'),
          backgroundColor: AppTheme.of(context).success,
        ),
      );

      // Navigate to the chat page
      context.goNamed(
        RequestChatPage.routeName,
        pathParameters: {
          'id': result.id.toString(),
        },
      );
    }
  }
}

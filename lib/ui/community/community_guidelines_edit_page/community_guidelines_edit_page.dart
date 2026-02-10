import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/ui/community/community_guidelines_edit_page/view_model/community_guidelines_edit_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CommunityGuidelinesEditPage extends StatelessWidget {
  static const String routeName = 'communityGuidelinesEdit';
  static const String routePath = '/communityGuidelinesEdit';

  const CommunityGuidelinesEditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommunityGuidelinesEditViewModel(
        context.read<CommunityRepository>(),
      )..init(),
      child: const CommunityGuidelinesEditPageView(),
    );
  }
}

class CommunityGuidelinesEditPageView extends StatelessWidget {
  const CommunityGuidelinesEditPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityGuidelinesEditViewModel>();

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
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Edit Guidelines',
          style: AppTheme.of(context).titleLarge.override(
                font: GoogleFonts.poppins(),
                color: Colors.white,
                fontSize: 22.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: InkWell(
                onTap: viewModel.isLoading
                    ? null
                    : () async {
                        final success = await viewModel.saveGuidelines(context);
                        if (success && context.mounted) {
                          context.pop();
                        }
                      },
                child: Text(
                  'Save',
                  style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.readexPro(),
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: true,
        child: viewModel.isLoading
            ? Center(
                child: CircularProgressIndicator(
                  color: AppTheme.of(context).primary,
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: viewModel.contentController,
                        maxLines: null,
                        expands: true,
                        textAlignVertical: TextAlignVertical.top,
                        decoration: InputDecoration(
                          hintText: 'Enter community guidelines here...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          fillColor: AppTheme.of(context).secondaryBackground,
                        ),
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.readexPro(),
                              color: AppTheme.of(context).primaryText,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

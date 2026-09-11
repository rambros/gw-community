import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/community_guidelines_edit_page/view_model/community_guidelines_edit_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:provider/provider.dart';

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
    final theme = AppTheme.of(context);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      appBar: AppBar(
        backgroundColor: theme.primary,
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
          context.l10n.editGuidelines,
          style: theme.titleLarge.override(
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
                  context.l10n.save,
                  style: theme.bodyMedium.override(
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
                  color: theme.primary,
                ),
              )
            : DefaultTabController(
                length: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12.0),
                        margin: const EdgeInsets.only(bottom: 12.0),
                        decoration: BoxDecoration(
                          color: theme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8.0),
                          border: Border.all(
                            color: theme.primary.withValues(alpha: 0.3),
                            width: 1.0,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: theme.primary,
                              size: 20.0,
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                '${context.l10n.guidelinesVersionsHint}\n${context.l10n.markdownSupported}',
                                style: theme.bodySmall.override(
                                  font: GoogleFonts.readexPro(),
                                  color: theme.primary,
                                  fontSize: 12.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      TabBar(
                        labelColor: theme.primary,
                        unselectedLabelColor: theme.secondaryText,
                        indicatorColor: theme.primary,
                        tabs: [
                          Tab(text: context.l10n.languageEnglish),
                          Tab(text: context.l10n.languagePortuguese),
                        ],
                      ),
                      const SizedBox(height: 12.0),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _GuidelinesEditor(
                              controller: viewModel.englishController,
                              hintText: context.l10n.enterEnglishGuidelinesHint,
                            ),
                            _GuidelinesEditor(
                              controller: viewModel.portugueseController,
                              hintText:
                                  context.l10n.enterPortugueseGuidelinesHint,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _GuidelinesEditor extends StatelessWidget {
  const _GuidelinesEditor({
    required this.controller,
    required this.hintText,
  });

  final TextEditingController controller;
  final String hintText;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);

    return TextField(
      controller: controller,
      maxLines: null,
      expands: true,
      textCapitalization: TextCapitalization.sentences,
      textAlignVertical: TextAlignVertical.top,
      cursorColor: theme.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.bodyMedium.override(
          font: GoogleFonts.readexPro(),
          color: theme.secondaryText,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.alternate,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide(
            color: theme.primary,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: theme.primaryBackground,
      ),
      style: theme.bodyMedium.override(
        font: GoogleFonts.readexPro(),
        color: theme.textColor,
      ),
    );
  }
}

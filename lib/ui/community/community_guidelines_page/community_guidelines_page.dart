import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/community_repository.dart';
import 'package:gw_community/ui/community/community_guidelines_page/view_model/community_guidelines_view_model.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class CommunityGuidelinesPage extends StatelessWidget {
  static const String routeName = 'communityGuidelines';
  static const String routePath = '/communityGuidelines';

  const CommunityGuidelinesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CommunityGuidelinesViewModel(context.read<CommunityRepository>())..init(),
      child: const CommunityGuidelinesPageView(),
    );
  }
}

class CommunityGuidelinesPageView extends StatelessWidget {
  const CommunityGuidelinesPageView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<CommunityGuidelinesViewModel>();

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
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 30.0),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Community Guidelines',
          style: AppTheme.of(
            context,
          ).titleLarge.override(font: GoogleFonts.poppins(), color: Colors.white, fontSize: 22.0),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: SafeArea(
        top: true,
        child: viewModel.isLoading
            ? Center(child: CircularProgressIndicator(color: AppTheme.of(context).primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewModel.guidelines ?? 'No guidelines available yet.',
                      style: AppTheme.of(context).bodyMedium.override(
                        font: GoogleFonts.readexPro(),
                        color: AppTheme.of(context).secondaryText,
                        fontSize: 16.0,
                        lineHeight: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

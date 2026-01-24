import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/journey/journey_page/view_model/journey_view_model.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_about_dialog.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_intro_widget.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_step_item_widget.dart';
import 'package:gw_community/ui/journey/step_details_page/step_details_page.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/learn/learn_list_page/learn_list_page.dart';
import 'package:gw_community/ui/onboarding/splash_page/splash_page.dart';
import 'package:gw_community/ui/profile/widgets/confirm_profile_action_dialog.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({
    super.key,
    this.journeyId,
  });

  final int? journeyId;

  static String routeName = 'journeyPage';
  static String routePath = '/journeyPage';

  @override
  State<JourneyPage> createState() => _JourneyPageState();
}

class _JourneyPageState extends State<JourneyPage> {
  JourneyViewModel? _viewModel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final appState = context.read<FFAppState>();

      // Use provided journeyId or default to 1 (Good Wishes Journey)
      final effectiveJourneyId = widget.journeyId ?? 1;

      _viewModel = JourneyViewModel(
        repository: context.read<JourneysRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        journeyId: effectiveJourneyId,
        startedJourneys: appState.listStartedJourneys,
      );
      setState(() {});
    });
  }

  @override
  void dispose() {
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        appBar: AppBar(
          backgroundColor: AppTheme.of(context).primary,
          automaticallyImplyLeading: false,
          actions: [
            Consumer<JourneyViewModel>(
              builder: (context, viewModel, _) {
                if (!viewModel.isJourneyStarted) {
                  return const SizedBox.shrink();
                }
                return PopupMenuButton<String>(
                  icon: const Icon(
                    Icons.more_vert,
                    color: Colors.white,
                  ),
                  onSelected: (value) async {
                    if (value == 'support_documents') {
                      await _handleSupportDocuments(context, viewModel);
                    } else if (value == 'restart_journey') {
                      await _handleRestartJourney(context, viewModel);
                    } else if (value == 'about') {
                      await _handleAbout(context, viewModel);
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'support_documents',
                      child: Row(
                        children: [
                          Icon(
                            Icons.library_books_outlined,
                            size: 20,
                            color: AppTheme.of(context).secondary,
                          ),
                          const SizedBox(width: 12),
                          const Text('Journey Resources'),
                        ],
                      ),
                    ),
                    if (viewModel.isJourneyStarted) ...[
                      const PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'restart_journey',
                        child: Row(
                          children: [
                            Icon(
                              Icons.restart_alt,
                              size: 20,
                              color: AppTheme.of(context).secondary,
                            ),
                            const SizedBox(width: 12),
                            const Text('Restart Journey'),
                          ],
                        ),
                      ),
                    ],
                    const PopupMenuDivider(),
                    PopupMenuItem(
                      value: 'about',
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: AppTheme.of(context).secondary,
                          ),
                          const SizedBox(width: 12),
                          const Text('About this journey'),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: SizedBox(
                height: 60.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Back button (only shown when navigation stack allows pop)
                    if (Navigator.canPop(context))
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FlutterFlowIconButton(
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
                            context.safePop();
                          },
                        ),
                      ),
                    // Title
                    Text(
                      'Journey',
                      style: AppTheme.of(context).journey.pageTitle.override(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          centerTitle: true,
          elevation: 4.0,
        ),
        body: SafeArea(
          top: true,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return Consumer<JourneyViewModel>(
      builder: (context, viewModel, _) {
        if (viewModel.isLoading) {
          return Center(
            child: SizedBox(
              width: 50.0,
              height: 50.0,
              child: SpinKitRipple(
                color: AppTheme.of(context).primary,
                size: 50.0,
              ),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Text(
              viewModel.errorMessage!,
              style: AppTheme.of(context).bodyMedium,
            ),
          );
        }

        if (!viewModel.isJourneyStarted) {
          return _buildJourneyIntro(context, viewModel);
        } else {
          return _buildJourneyProgress(context, viewModel);
        }
      },
    );
  }

  Widget _buildJourneyIntro(BuildContext context, JourneyViewModel viewModel) {
    if (viewModel.journey == null) {
      return Center(
        child: Text(
          'Journey not found',
          style: AppTheme.of(context).bodyMedium,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondary,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: JourneyIntroWidget(
          journey: viewModel.journey!,
          onStart: () => _handleStartJourney(context, viewModel),
        ),
      ),
    );
  }

  Widget _buildJourneyProgress(BuildContext context, JourneyViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: AppTheme.of(context).secondary,
      ),
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: ListView(
          padding: EdgeInsets.zero,
          scrollDirection: Axis.vertical,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 32.0, 0.0, 0.0),
                      child: Text(
                        'Welcome back, ${context.read<FFAppState>().loginUser.firstName}',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).journey.bodyText.override(
                              color: AppTheme.of(context).tertiary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 0.0),
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 32.0, 4.0, 0.0),
                child: Builder(
                  builder: (context) {
                    // Encontra o índice do primeiro step 'open' (step atual)
                    final currentStepIndex = viewModel.userSteps.indexWhere(
                      (s) => s.stepStatus == 'open',
                    );

                    return ListView.builder(
                      padding: EdgeInsets.zero,
                      primary: false,
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      itemCount: viewModel.userSteps.length,
                      itemBuilder: (context, index) {
                        final step = viewModel.userSteps[index];
                        final isLastStep = index == viewModel.userSteps.length - 1;
                        final isCurrentStep = index == currentStepIndex;

                        return JourneyStepItemWidget(
                          stepRow: step,
                          isLastStep: isLastStep,
                          isCurrentStep: isCurrentStep,
                          onTap: () => _handleStepTap(context, viewModel, step),
                          enableDateControl: viewModel.userJourney?.enableDateControl ?? true,
                          daysToWait: viewModel.userJourney?.daysToWaitBetweenSteps ?? 1,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleStartJourney(BuildContext context, JourneyViewModel viewModel) async {
    final appState = context.read<FFAppState>();

    await viewModel.startJourneyCommand(
      context,
      (updatedList) {
        appState.listStartedJourneys = updatedList;
      },
    );
  }

  Future<void> _handleStepTap(BuildContext context, JourneyViewModel viewModel, CcViewUserStepsRow step) async {
    if (viewModel.canNavigateToStep(step, viewModel.userSteps.indexOf(step))) {
      await context.pushNamed(
        StepDetailsPage.routeName,
        queryParameters: {
          'userStepRow': serializeParam(
            step,
            ParamType.SupabaseRow,
          ),
        }.withoutNulls,
        extra: <String, dynamic>{
          kTransitionInfoKey: const TransitionInfo(
            hasTransition: true,
            transitionType: PageTransitionType.fade,
            duration: Duration(milliseconds: 0),
          ),
        },
      );

      // Recarrega os dados ao voltar da página de detalhes
      if (mounted) {
        await viewModel.loadJourneyData();
      }
    }
  }

  Future<void> _handleSupportDocuments(BuildContext context, JourneyViewModel viewModel) async {
    if (!context.mounted) return;

    await context.pushNamed(
      LearnListPage.routeName,
      queryParameters: {
        'journeyId': viewModel.journeyId.toString(),
        'customTitle': 'Journey Resources',
      }.withoutNulls,
      extra: <String, dynamic>{
        kTransitionInfoKey: const TransitionInfo(
          hasTransition: true,
          transitionType: PageTransitionType.fade,
          duration: Duration(milliseconds: 0),
        ),
      },
    );
  }

  Future<void> _handleRestartJourney(BuildContext context, JourneyViewModel viewModel) async {
    if (!context.mounted) return;

    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return const WebViewAware(
              child: ConfirmProfileActionDialog(
                title: 'Reset your Good Wishes Journey',
                description: 'Resetting your journey will delete all progress made so far. '
                    'This action cannot be undone.',
                confirmLabel: 'Reset Journey',
                icon: Icons.restart_alt,
              ),
            );
          },
        ) ??
        false;

    if (!confirmDialogResponse) return;

    if (!context.mounted) return;

    try {
      final appState = context.read<FFAppState>();

      await viewModel.resetJourneyCommand(
        context,
        (updatedList) {
          appState.listStartedJourneys = updatedList;
        },
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Journey reset successfully',
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: AppTheme.of(context).secondary,
          ),
        );

        context.goNamed(SplashPage.routeName);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error resetting journey: $e',
              style: const TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAbout(BuildContext context, JourneyViewModel viewModel) async {
    if (!context.mounted) return;

    final title = viewModel.journey?.title ?? viewModel.userJourney?.title ?? 'Journey';
    final description =
        viewModel.journey?.description ?? viewModel.userJourney?.description ?? 'No description available';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return WebViewAware(
          child: JourneyAboutDialog(
            title: title,
            description: description,
          ),
        );
      },
    );
  }
}

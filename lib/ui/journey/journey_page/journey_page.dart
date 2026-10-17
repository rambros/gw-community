import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/domain/models/journey_step_group.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/view_as/view_as_session.dart';
import 'package:gw_community/ui/journey/journey_page/view_model/journey_view_model.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_about_dialog.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_intro_widget.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_step_item_widget.dart';
import 'package:gw_community/ui/journey/step_details_page/step_details_page.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/ui/onboarding/splash_page/splash_page.dart';
import 'package:gw_community/ui/profile/widgets/confirm_profile_action_dialog.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

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
  final GlobalKey _expandedSectionKey = GlobalKey();
  int? _lastViewedSectionId;
  bool _scrollToExpandedSection = false;

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
        currentUserUid: context.effectiveUserIdOrEmpty,
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
      child: Consumer<JourneyViewModel>(
        builder: (context, viewModel, _) {
          return JourneyLocaleScope(
            fixedLanguage: viewModel.fixedLanguage,
            builder: (context) => Scaffold(
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
                    if (value == 'about') {
                      await _handleAbout(context, viewModel);
                    } else if (value == 'restart_journey') {
                      await _handleRestartJourney(context, viewModel);
                    }
                  },
                  itemBuilder: (context) => [
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
                          Text(context.l10n.aboutThisJourney),
                        ],
                      ),
                    ),
                    if (viewModel.isJourneyStarted && !viewAsBlocksWrite()) ...[
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
                            Text(context.l10n.restartJourney),
                          ],
                        ),
                      ),
                    ],
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
                    Consumer<JourneyViewModel>(
                      builder: (context, viewModel, _) {
                        return Text(
                          viewModel.journey?.title ?? viewModel.userJourney?.title ?? 'Journey',
                          style: AppTheme.of(context).journey.pageTitle.override(
                                color: Colors.white,
                              ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        );
                      },
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
        },
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
      color: AppTheme.of(context).secondary,
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
        child: JourneyIntroWidget(
          journey: viewModel.journey!,
          groupedSteps: viewModel.groupedJourneySteps,
          onStart: () => _handleStartJourney(context, viewModel),
          isJourneyStarted: viewModel.isJourneyStarted,
          showStartButton: !viewAsBlocksWrite(),
        ),
      ),
    );
  }

  Widget _buildJourneyProgress(BuildContext context, JourneyViewModel viewModel) {
    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.9,
      color: AppTheme.of(context).secondary,
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
                        context.l10n.welcomeBack(
                          context.read<FFAppState>().loginUser.firstName,
                        ),
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

                    return _buildProgressSteps(context, viewModel, currentStepIndex);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSteps(
    BuildContext context,
    JourneyViewModel viewModel,
    int currentStepIndex,
  ) {
    Widget stepItem(
      CcViewUserStepsRow step, {
      required bool isLastStep,
      required int displayNumber,
    }) {
      return JourneyStepItemWidget(
        stepRow: step,
        isLastStep: isLastStep,
        isCurrentStep: viewModel.userSteps.indexOf(step) == currentStepIndex,
        onTap: () => _handleStepTap(context, viewModel, step),
        enableDateControl: viewModel.userJourney?.enableDateControl ?? true,
        daysToWait: viewModel.userJourney?.daysToWaitBetweenSteps ?? 1,
        displayNumber: displayNumber,
      );
    }

    if (!viewModel.hasSectionHeaders) {
      return ListView.builder(
        padding: EdgeInsets.zero,
        primary: false,
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        itemCount: viewModel.userSteps.length,
        itemBuilder: (context, index) {
          final step = viewModel.userSteps[index];
          return stepItem(
            step,
            isLastStep: index == viewModel.userSteps.length - 1,
            displayNumber: index + 1,
          );
        },
      );
    }

    final groups = viewModel.groupedUserSteps;
    final currentStep = currentStepIndex >= 0 ? viewModel.userSteps[currentStepIndex] : null;
    final expandedSectionId = expandedJourneySectionId(
      groups: groups,
      preferredSectionId: _lastViewedSectionId,
      currentStepSectionId: currentStep?.sectionId,
    );
    return ListView.builder(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      itemCount: groups.length,
      itemBuilder: (context, groupIndex) {
        final group = groups[groupIndex];
        final firstNumber = firstNumberOfGroup(groups, groupIndex);
        if (!group.hasHeader) {
          return Column(
            children: [
              for (var i = 0; i < group.steps.length; i++)
                stepItem(
                  group.steps[i],
                  isLastStep: i == group.steps.length - 1,
                  displayNumber: firstNumber + i,
                ),
            ],
          );
        }

        final expanded = group.sectionId == expandedSectionId;
        if (expanded && _scrollToExpandedSection) {
          _scrollToExpandedSection = false;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final target = _expandedSectionKey.currentContext;
            if (target == null || !target.mounted) return;
            Scrollable.ensureVisible(
              target,
              alignment: 0.05,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
            );
          });
        }
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: Material(
            color: Colors.transparent,
            child: ExpansionTile(
              key: expanded ? _expandedSectionKey : ValueKey('section-${group.sectionId}'),
              initiallyExpanded: expanded,
              tilePadding: const EdgeInsets.symmetric(horizontal: 8.0),
              title: Text(
                group.title!,
                style: AppTheme.of(context).journey.bodyText.override(
                      color: AppTheme.of(context).tertiary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16.0,
                    ),
              ),
              iconColor: AppTheme.of(context).primary,
              collapsedIconColor: AppTheme.of(context).tertiary,
              children: [
                for (var i = 0; i < group.steps.length; i++)
                  stepItem(
                    group.steps[i],
                    isLastStep: i == group.steps.length - 1,
                    displayNumber: firstNumber + i,
                  ),
              ],
            ),
          ),
        );
      },
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
      _lastViewedSectionId = step.sectionId;
      _scrollToExpandedSection = true;
      await context.pushNamed(
        StepDetailsPage.routeName,
        queryParameters: {
          'userStepRow': serializeParam(
            step,
            ParamType.SupabaseRow,
          ),
          if (viewModel.fixedLanguage != null)
            'fixedLanguage': serializeParam(viewModel.fixedLanguage, ParamType.String),
        }.withoutNulls,
        extra: <String, dynamic>{
          if (viewModel.fixedLanguage != null)
            'fixedLanguage': viewModel.fixedLanguage,
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

  Future<void> _handleRestartJourney(BuildContext context, JourneyViewModel viewModel) async {
    if (!context.mounted) return;

    final confirmDialogResponse = await showDialog<bool>(
          context: context,
          builder: (alertDialogContext) {
            return WebViewAware(
              child: JourneyLocaleScope(
                fixedLanguage: viewModel.fixedLanguage,
                builder: (context) => ConfirmProfileActionDialog(
                  title: context.l10n.resetJourneyTitle,
                  description: context.l10n.resetJourneyDescription,
                  confirmLabel: context.l10n.resetJourneyConfirm,
                  icon: Icons.restart_alt,
                ),
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
              context.l10n.journeyResetSuccess,
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
              context.l10n.errorResettingJourney('$e'),
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
          child: JourneyLocaleScope(
            fixedLanguage: viewModel.fixedLanguage,
            builder: (context) => JourneyAboutDialog(
              title: title,
              description: description,
            ),
          ),
        );
      },
    );
  }
}

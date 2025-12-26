import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/journey/journey_page/view_model/journey_view_model.dart';
import 'package:gw_community/ui/journey/journey_page/widgets/journey_step_item_widget.dart';
import 'package:gw_community/ui/journey/step_details_page/step_details_page.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/custom_functions.dart' as functions;
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class JourneyStepDetailsPage extends StatefulWidget {
  const JourneyStepDetailsPage({
    super.key,
    required this.journeyId,
  });

  final int? journeyId;

  static String routeName = 'journeyStepDetailsPage';
  static String routePath = '/journeyStepDetailsPage';

  @override
  State<JourneyStepDetailsPage> createState() => _JourneyStepDetailsPageState();
}

class _JourneyStepDetailsPageState extends State<JourneyStepDetailsPage> {
  JourneyViewModel? _viewModel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.journeyId == null) {
        setState(() {});
        return;
      }

      final appState = FFAppState();
      _viewModel = JourneyViewModel(
        repository: context.read<JourneysRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        journeyId: widget.journeyId!,
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
          title: Text(
            FFLocalizations.of(context).getText('3k4dstim' /* Journey */),
            style: AppTheme.of(context).journey.pageTitle.override(
                  color: Colors.white,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 4.0,
        ),
        body: SafeArea(
          top: true,
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
            child: _buildBody(context),
          ),
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

        return Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
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
                                'Welcome back, ${FFAppState().loginUser.firstName}',
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context).journey.stepTitle.override(
                                      color: AppTheme.of(context).tertiary400,
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
                        child: _buildStepsList(context, viewModel),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStepsList(BuildContext context, JourneyViewModel viewModel) {
    // Encontra o índice do primeiro step 'open' (step atual)
    final currentStepIndex = viewModel.userSteps.indexWhere(
      (s) => s.stepStatus == 'open',
    );

    return ListView.separated(
      padding: EdgeInsets.zero,
      primary: false,
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: viewModel.userSteps.length,
      separatorBuilder: (_, __) => const SizedBox(height: 16.0),
      itemBuilder: (context, index) {
        final step = viewModel.userSteps[index];
        final isLastStep = functions.isLastStep(index, viewModel.userJourney?.stepsTotal) == false;
        final isCurrentStep = index == currentStepIndex;

        return JourneyStepItemWidget(
          stepRow: step,
          isLastStep: isLastStep,
          isCurrentStep: isCurrentStep,
          onTap: () => _handleStepTap(context, viewModel, step),
        );
      },
    );
  }

  void _handleStepTap(BuildContext context, JourneyViewModel viewModel, CcViewUserStepsRow step) {
    if (viewModel.canNavigateToStep(step, viewModel.userSteps.indexOf(step))) {
      context.pushNamed(
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
    }
  }
}

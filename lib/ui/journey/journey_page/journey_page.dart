import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/backend/supabase/supabase.dart';
import '/data/repositories/journeys_repository.dart';
import '/custom_code/actions/index.dart' as actions;
import '/utils/context_extensions.dart';
import 'view_model/journey_view_model.dart';
import 'widgets/journey_intro_widget.dart';
import 'widgets/journey_step_item_widget.dart';
import '/ui/journey/step_details_page/step_details_page.dart';

class JourneyPage extends StatefulWidget {
  const JourneyPage({
    super.key,
    int? journeyId,
  }) : journeyId = journeyId ?? 1;

  final int journeyId;

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
      _viewModel = JourneyViewModel(
        repository: context.read<JourneysRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        journeyId: widget.journeyId,
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
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return ChangeNotifierProvider.value(
      value: _viewModel!,
      child: Scaffold(
        backgroundColor: FlutterFlowTheme.of(context).secondary,
        appBar: AppBar(
          backgroundColor: FlutterFlowTheme.of(context).primary,
          automaticallyImplyLeading: false,
          title: Text(
            'Journey',
            style: FlutterFlowTheme.of(context).bodyMedium.override(
                  font: GoogleFonts.lexendDeca(
                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                  ),
                  color: Colors.white,
                  fontSize: 20.0,
                  letterSpacing: 0.0,
                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                ),
          ),
          actions: const [],
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
                color: FlutterFlowTheme.of(context).primary,
                size: 50.0,
              ),
            ),
          );
        }

        if (viewModel.errorMessage != null) {
          return Center(
            child: Text(
              viewModel.errorMessage!,
              style: FlutterFlowTheme.of(context).bodyMedium,
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
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return Container(
      width: double.infinity,
      height: MediaQuery.sizeOf(context).height * 0.9,
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondary,
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
        color: FlutterFlowTheme.of(context).secondary,
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
                        style: FlutterFlowTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.lexendDeca(
                                fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).tertiary,
                              fontSize: 16.0,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
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
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  primary: false,
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: viewModel.userSteps.length,
                  itemBuilder: (context, index) {
                    final step = viewModel.userSteps[index];
                    final isLastStep = index == viewModel.userSteps.length - 1;

                    return JourneyStepItemWidget(
                      stepRow: step,
                      isLastStep: isLastStep,
                      onTap: () => _handleStepTap(context, viewModel, step),
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
      (userId, journeyId) => actions.startJourney(userId, journeyId),
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

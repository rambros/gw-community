import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/step_activities_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/journey/step_audio_player_page/step_audio_player_page.dart';
import 'package:gw_community/ui/journey/step_details_page/view_model/step_details_view_model.dart';
import 'package:gw_community/ui/journey/step_details_page/widgets/activity_item_widget.dart';
import 'package:gw_community/ui/journey/step_journal_page/step_journal_page.dart';
import 'package:gw_community/ui/journey/step_text_view_page/step_text_view_page.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class StepDetailsPage extends StatefulWidget {
  const StepDetailsPage({
    super.key,
    required this.userStepRow,
  });

  final CcViewUserStepsRow? userStepRow;

  static String routeName = 'stepDetailsPage';
  static String routePath = '/stepDetailsPage';

  @override
  State<StepDetailsPage> createState() => _StepDetailsPageState();
}

class _StepDetailsPageState extends State<StepDetailsPage> {
  StepDetailsViewModel? _viewModel;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (widget.userStepRow == null) {
        setState(() {});
        return;
      }

      _viewModel = StepDetailsViewModel(
        repository: context.read<StepActivitiesRepository>(),
        currentUserUid: context.currentUserIdOrEmpty,
        userStepRow: widget.userStepRow!,
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
            'Step ${widget.userStepRow?.stepNumber?.toString()}',
            style: AppTheme.of(context).journey.pageTitle.override(
                  color: Colors.white,
                ),
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: _buildBody(context),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(2.0, 16.0, 2.0, 0.0),
                      child: Text(
                        widget.userStepRow?.title ?? 'step',
                        textAlign: TextAlign.center,
                        style: AppTheme.of(context).journey.stepTitle.override(
                              color: AppTheme.of(context).tertiary,
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 0.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(4.0, 16.0, 4.0, 0.0),
                      child: MarkdownBody(
                        data: widget.userStepRow?.description ?? 'description',
                        shrinkWrap: true,
                        styleSheet: MarkdownStyleSheet(
                          p: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.normal,
                          ),
                          strong: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                          ),
                          em: GoogleFonts.lexendDeca(
                            color: AppTheme.of(context).primaryText,
                            fontSize: 14.0,
                            fontStyle: FontStyle.italic,
                          ),
                          textAlign: WrapAlignment.center,
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
                child: _buildActivitiesList(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivitiesList(BuildContext context) {
    return Consumer<StepDetailsViewModel>(
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

        return ListView.separated(
          padding: EdgeInsets.zero,
          primary: false,
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: viewModel.activities.length,
          separatorBuilder: (_, __) => const SizedBox(height: 16.0),
          itemBuilder: (context, index) {
            final activity = viewModel.activities[index];
            return ActivityItemWidget(
              activity: activity,
              onTap: () => _handleActivityTap(context, viewModel, activity),
            );
          },
        );
      },
    );
  }

  Future<void> _handleActivityTap(
    BuildContext context,
    StepDetailsViewModel viewModel,
    CcViewUserActivitiesRow activity,
  ) async {
    // Captura o GoRouter antes da operação assíncrona para evitar
    // usar um context desativado após o await
    final router = GoRouter.of(context);

    await viewModel.handleActivityTap(
      context,
      activity,
      (routeName, params) {
        if (!mounted) return;

        if (routeName == 'stepAudioPlayerPage') {
          router.pushNamed(
            StepAudioPlayerPage.routeName,
            queryParameters: {
              'stepAudioUrl': serializeParam(params['stepAudioUrl'], ParamType.String),
              'audioTitle': serializeParam(params['audioTitle'], ParamType.String),
              'typeAnimation': serializeParam(params['typeAnimation'], ParamType.String),
              'audioArt': serializeParam(params['audioArt'], ParamType.String),
              'typeStep': serializeParam(params['typeStep'], ParamType.String),
              'activityId': serializeParam(params['activityId'], ParamType.int),
            }.withoutNulls,
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        } else if (routeName == 'stepTextViewPage') {
          router.pushNamed(
            StepTextViewPage.routeName,
            queryParameters: {
              'stepTextTitle': serializeParam(params['stepTextTitle'], ParamType.String),
              'stepTextContent': serializeParam(params['stepTextContent'], ParamType.String),
              'activityId': serializeParam(params['activityId'], ParamType.int),
            }.withoutNulls,
            extra: <String, dynamic>{
              kTransitionInfoKey: const TransitionInfo(
                hasTransition: true,
                transitionType: PageTransitionType.fade,
                duration: Duration(milliseconds: 0),
              ),
            },
          );
        } else {
          router.pushNamed(
            StepJournalPage.routeName,
            queryParameters: {
              'activityRow': serializeParam(params['activityRow'], ParamType.SupabaseRow),
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
      },
    );
  }
}

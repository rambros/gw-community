import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/journal_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_widgets.dart';
import 'package:gw_community/ui/journey/step_journal_page/view_model/step_journal_view_model.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class StepJournalPage extends StatefulWidget {
  const StepJournalPage({
    super.key,
    required this.activityRow,
    this.fixedLanguage,
  });

  final CcViewUserActivitiesRow? activityRow;
  final String? fixedLanguage;

  static String routeName = 'stepJournalPage';
  static String routePath = '/stepJournalPage';

  @override
  State<StepJournalPage> createState() => _StepJournalPageState();
}

class _StepJournalPageState extends State<StepJournalPage> {
  StepJournalViewModel? _viewModel;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();

    if (widget.activityRow == null || widget.activityRow!.id == null) {
      _textController = TextEditingController();
      _focusNode = FocusNode();
      return;
    }

    final template = (widget.activityRow?.journal ?? '').trim();
    final prompt = (widget.activityRow?.activityPrompt ?? '').trim();
    var savedContent = (widget.activityRow?.journalSaved ?? '').trim();
    if (template.isNotEmpty && savedContent == template) {
      savedContent = '';
    }
    if (prompt.isNotEmpty && savedContent == prompt) {
      savedContent = '';
    }

    _viewModel = StepJournalViewModel(
      repository: context.read<JournalRepository>(),
      activityId: widget.activityRow!.id!,
      initialContent: savedContent,
    );

    _textController = TextEditingController(text: _viewModel!.journalContent);
    _focusNode = FocusNode();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    _viewModel?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel == null) {
      return Scaffold(
        backgroundColor: AppTheme.of(context).secondary,
        body: const Center(child: Text('Invalid activity data')),
      );
    }

    return JourneyLocaleScope(
      fixedLanguage: widget.fixedLanguage,
      builder: (context) => ChangeNotifierProvider.value(
        value: _viewModel!,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
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
              title: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    context.l10n.mediaJournal,
                    style: AppTheme.of(context).journey.pageTitle,
                  ),
                  Text(
                    context.l10n.journalEntriesPrivate,
                    style: AppTheme.of(context).bodySmall.override(
                          color: Colors.white.withValues(alpha: 0.9),
                          fontSize: 14.0,
                          letterSpacing: 0.0,
                        ),
                  ),
                ],
              ),
              actions: const [],
              centerTitle: true,
              toolbarHeight: 68.0,
              elevation: 2.0,
            ),
            body: SafeArea(
              top: true,
              child: Container(
                width: MediaQuery.sizeOf(context).width * 1.0,
                height: MediaQuery.sizeOf(context).height * 0.9,
                decoration: BoxDecoration(
                  color: AppTheme.of(context).secondary,
                ),
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(
                      16.0, 16.0, 16.0, 8.0),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Padding(
                              padding: const EdgeInsetsDirectional.fromSTEB(
                                  12.0, 8.0, 12.0, 16.0),
                              child: Text(
                                widget.activityRow?.activityPrompt ?? 'prompt',
                                textAlign: TextAlign.center,
                                style: AppTheme.of(context)
                                    .journey
                                    .stepTitle
                                    .override(
                                      color: AppTheme.of(context).tertiary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 8.0, 0.0, 8.0),
                          child: Container(
                            width: MediaQuery.sizeOf(context).width * 0.9,
                            height: MediaQuery.sizeOf(context).height * 0.6,
                            decoration: BoxDecoration(
                              color: AppTheme.of(context).secondaryBackground,
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: TextFormField(
                                controller: _textController,
                                focusNode: _focusNode,
                                textAlignVertical: TextAlignVertical.top,
                                obscureText: false,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                decoration: InputDecoration(
                                  labelStyle:
                                      AppTheme.of(context).journey.bodyText,
                                  hintStyle:
                                      AppTheme.of(context).journey.bodyText,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                ),
                                style: AppTheme.of(context)
                                    .journey
                                    .bodyText
                                    .override(
                                      color: AppTheme.of(context).secondary,
                                    ),
                                maxLines: null,
                                expands: true,
                                onChanged: (value) =>
                                    _viewModel?.updateJournalContent(value),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0.0, 16.0, 8.0, 0.0),
                          child: Consumer<StepJournalViewModel>(
                            builder: (context, viewModel, _) {
                              return FFButtonWidget(
                                onPressed: viewModel.isSaving
                                    ? null
                                    : () => _handleSave(context, viewModel),
                                text: context.l10n.save,
                                options: FFButtonOptions(
                                  height: 40.0,
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      24.0, 0.0, 24.0, 0.0),
                                  iconPadding:
                                      const EdgeInsetsDirectional.fromSTEB(
                                          0.0, 0.0, 0.0, 0.0),
                                  color: AppTheme.of(context).primary,
                                  textStyle: AppTheme.of(context)
                                      .journey
                                      .buttonText
                                      .override(
                                        color: AppTheme.of(context)
                                            .primaryBackground,
                                      ),
                                  elevation: 1.0,
                                  borderSide: BorderSide(
                                    color: AppTheme.of(context)
                                        .secondaryBackground,
                                    width: 0.5,
                                  ),
                                  borderRadius: BorderRadius.circular(20.0),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleSave(
      BuildContext context, StepJournalViewModel viewModel) async {
    await viewModel.saveJournalCommand(
      context,
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              context.l10n.journalSaved,
              style: TextStyle(
                color: AppTheme.of(context).primaryText,
              ),
            ),
            duration: const Duration(milliseconds: 4000),
            backgroundColor: AppTheme.of(context).secondary,
          ),
        );
        Navigator.of(context).pop();
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/data/services/supabase/supabase.dart';
import '/data/repositories/journal_repository.dart';
import 'view_model/step_journal_view_model.dart';

class StepJournalPage extends StatefulWidget {
  const StepJournalPage({
    super.key,
    required this.activityRow,
  });

  final CcViewUserActivitiesRow? activityRow;

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

    _viewModel = StepJournalViewModel(
      repository: context.read<JournalRepository>(),
      activityId: widget.activityRow!.id!,
      initialContent: widget.activityRow?.journalSaved ?? '',
    );

    _textController = TextEditingController(text: _viewModel!.journalContent);
    _focusNode = FocusNode();
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

    return ChangeNotifierProvider.value(
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
                Navigator.of(context).pop();
              },
            ),
            title: Text(
              'My Journal',
              style: AppTheme.of(context).titleLarge.override(
                    font: GoogleFonts.poppins(
                      fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                      fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                    ),
                    fontSize: 20.0,
                    letterSpacing: 0.0,
                    fontWeight: AppTheme.of(context).titleLarge.fontWeight,
                    fontStyle: AppTheme.of(context).titleLarge.fontStyle,
                  ),
            ),
            actions: const [],
            centerTitle: true,
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
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 16.0, 16.0, 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 8.0, 12.0, 16.0),
                            child: Text(
                              widget.activityRow?.activityPrompt ?? 'prompt',
                              textAlign: TextAlign.center,
                              style: AppTheme.of(context).titleMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).tertiary,
                                    fontSize: 16.0,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context).titleMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 8.0, 0.0, 8.0),
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
                              autofocus: true,
                              obscureText: false,
                              decoration: InputDecoration(
                                labelStyle: AppTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                                    ),
                                hintStyle: AppTheme.of(context).labelMedium.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                                        fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                                      ),
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).labelMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).labelMedium.fontStyle,
                                    ),
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                              style: AppTheme.of(context).bodyMedium.override(
                                    font: GoogleFonts.lexendDeca(
                                      fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                      fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                    ),
                                    color: AppTheme.of(context).secondary,
                                    letterSpacing: 0.0,
                                    fontWeight: AppTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: AppTheme.of(context).bodyMedium.fontStyle,
                                  ),
                              maxLines: 50,
                              onChanged: (value) => _viewModel?.updateJournalContent(value),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 8.0, 0.0),
                        child: Consumer<StepJournalViewModel>(
                          builder: (context, viewModel, _) {
                            return FFButtonWidget(
                              onPressed: viewModel.isSaving ? null : () => _handleSave(context, viewModel),
                              text: 'Save',
                              options: FFButtonOptions(
                                height: 40.0,
                                padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                color: AppTheme.of(context).primary,
                                textStyle: AppTheme.of(context).labelLarge.override(
                                      font: GoogleFonts.poppins(
                                        fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                        fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                      ),
                                      color: AppTheme.of(context).primaryBackground,
                                      letterSpacing: 0.0,
                                      fontWeight: AppTheme.of(context).labelLarge.fontWeight,
                                      fontStyle: AppTheme.of(context).labelLarge.fontStyle,
                                    ),
                                elevation: 1.0,
                                borderSide: BorderSide(
                                  color: AppTheme.of(context).secondaryBackground,
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
    );
  }

  Future<void> _handleSave(BuildContext context, StepJournalViewModel viewModel) async {
    await viewModel.saveJournalCommand(
      context,
      () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Journal saved',
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

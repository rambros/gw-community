import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:easy_debounce/easy_debounce.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/backend/supabase/supabase.dart';
import 'view_model/user_journal_edit_view_model.dart';

class UserJournalEditPage extends StatefulWidget {
  const UserJournalEditPage({
    super.key,
    required this.userJournalEntryRow,
  });

  final CcViewUserJournalRow? userJournalEntryRow;

  static String routeName = 'userJournalEdit';
  static String routePath = '/userJournalEdit';

  @override
  State<UserJournalEditPage> createState() => _UserJournalEditPageState();
}

class _UserJournalEditPageState extends State<UserJournalEditPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  late TextEditingController _textController;
  late FocusNode _textFieldFocusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.userJournalEntryRow?.journalSaved);
    _textFieldFocusNode = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userJournalEntryRow != null) {
        context.read<UserJournalEditViewModel>().setJournalEntry(widget.userJournalEntryRow!);
      }
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _textFieldFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserJournalEditViewModel>();

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: FlutterFlowTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          buttonSize: 46.0,
          icon: Icon(
            Icons.arrow_back_rounded,
            color: FlutterFlowTheme.of(context).primaryBackground,
            size: 25.0,
          ),
          onPressed: () async {
            context.pop();
          },
        ),
        title: Text(
          'Your Journal Entry',
          style: FlutterFlowTheme.of(context).headlineMedium.override(
                font: GoogleFonts.lexendDeca(
                  fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                ),
                color: FlutterFlowTheme.of(context).primaryBackground,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
              ),
        ),
        actions: const [],
        centerTitle: false,
        elevation: 0.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 3.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          AutoSizeText(
                            dateTimeFormat(
                              "yMMMd",
                              widget.userJournalEntryRow?.dateCompleted,
                              locale: FFLocalizations.of(context).languageCode,
                            ),
                            minFontSize: 14.0,
                            style: FlutterFlowTheme.of(context).titleMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FontWeight.w500,
                                    fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  fontSize: 14.0,
                                  letterSpacing: 0.0,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          valueOrDefault<String>(
                            widget.userJournalEntryRow?.journeyTitle,
                            'Journey',
                          ),
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                ),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w300,
                                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                              ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Text(
                          '${widget.userJournalEntryRow?.stepNumber?.toString()} - ${widget.userJournalEntryRow?.stepTitle}',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                ),
                                fontSize: 14.0,
                                letterSpacing: 0.0,
                                fontWeight: FontWeight.w300,
                                fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                              ),
                        ),
                      ],
                    ),
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 8.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: TextFormField(
                            controller: _textController,
                            focusNode: _textFieldFocusNode,
                            onChanged: (_) => EasyDebounce.debounce(
                              '_textController',
                              const Duration(milliseconds: 2000),
                              () => safeSetState(() {}),
                            ),
                            autofocus: true,
                            enabled: !viewModel.isLoading,
                            obscureText: false,
                            decoration: InputDecoration(
                              isDense: true,
                              labelStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                    ),
                                    color: FlutterFlowTheme.of(context).primaryBackground,
                                    fontSize: 14.0,
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                  ),
                              hintText: 'TextField',
                              hintStyle: FlutterFlowTheme.of(context).labelMedium.override(
                                    font: GoogleFonts.poppins(
                                      fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                      fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                    ),
                                    letterSpacing: 0.0,
                                    fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                  ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).primary,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0x00000000),
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              errorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              focusedErrorBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: FlutterFlowTheme.of(context).error,
                                  width: 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              filled: true,
                              fillColor: FlutterFlowTheme.of(context).primaryBackground,
                              suffixIcon: _textController.text.isNotEmpty
                                  ? InkWell(
                                      onTap: () async {
                                        _textController.clear();
                                        safeSetState(() {});
                                      },
                                      child: Icon(
                                        Icons.clear,
                                        color: FlutterFlowTheme.of(context).secondary,
                                        size: 32.0,
                                      ),
                                    )
                                  : null,
                            ),
                            style: FlutterFlowTheme.of(context).bodyMedium.override(
                                  font: GoogleFonts.lexendDeca(
                                    fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                    fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                  ),
                                  color: FlutterFlowTheme.of(context).secondary,
                                  letterSpacing: 0.0,
                                  fontWeight: FlutterFlowTheme.of(context).bodyMedium.fontWeight,
                                  fontStyle: FlutterFlowTheme.of(context).bodyMedium.fontStyle,
                                ),
                            maxLines: 50,
                            cursorColor: FlutterFlowTheme.of(context).primary,
                            enableInteractiveSelection: true,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (viewModel.errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  viewModel.errorMessage!,
                  style: TextStyle(color: FlutterFlowTheme.of(context).error),
                ),
              ),
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 32.0),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () async {
                        context.pop();
                      },
                      text: 'Cancel',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                        iconPadding: const EdgeInsets.all(0.0),
                        color: FlutterFlowTheme.of(context).primaryBackground,
                        textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).secondary,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                            ),
                        elevation: 0.0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              await viewModel.saveJournalEntry(_textController.text);
                              if (!context.mounted) return;
                              if (viewModel.errorMessage == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Journal saved',
                                      style: TextStyle(
                                        color: FlutterFlowTheme.of(context).primaryText,
                                      ),
                                    ),
                                    duration: const Duration(milliseconds: 4000),
                                    backgroundColor: FlutterFlowTheme.of(context).secondary,
                                  ),
                                );
                                context.safePop();
                              }
                            },
                      text: viewModel.isLoading ? 'Saving...' : 'Save Changes',
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        color: FlutterFlowTheme.of(context).primary,
                        textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                              font: GoogleFonts.poppins(
                                fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                              ),
                              color: FlutterFlowTheme.of(context).primaryBackground,
                              letterSpacing: 0.0,
                              fontWeight: FlutterFlowTheme.of(context).labelLarge.fontWeight,
                              fontStyle: FlutterFlowTheme.of(context).labelLarge.fontStyle,
                            ),
                        elevation: 1.0,
                        borderSide: BorderSide(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

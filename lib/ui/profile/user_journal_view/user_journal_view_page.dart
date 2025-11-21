import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/ui/profile/user_journal_options/user_journal_options_sheet.dart';

import 'view_model/user_journal_view_model.dart';

class UserJournalViewPage extends StatefulWidget {
  const UserJournalViewPage({
    super.key,
    required this.userActivitiesId,
  });

  final int? userActivitiesId;

  static String routeName = 'userJournalView';
  static String routePath = '/userJournalView';

  @override
  State<UserJournalViewPage> createState() => _UserJournalViewPageState();
}

class _UserJournalViewPageState extends State<UserJournalViewPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.userActivitiesId != null) {
        context.read<UserJournalViewModel>().loadJournalEntry(widget.userActivitiesId!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserJournalViewModel>();

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
        child: _buildBody(context, viewModel),
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserJournalViewModel viewModel) {
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

    final journalEntry = viewModel.journalEntry;

    if (journalEntry == null) {
      return Center(
        child: Text(
          'Journal entry not found.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16.0, 12.0, 16.0, 12.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 3.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${journalEntry.dateCompleted?.toString()}',
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
                          InkWell(
                            splashColor: Colors.transparent,
                            focusColor: Colors.transparent,
                            hoverColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onTap: () async {
                              await showModalBottomSheet(
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                enableDrag: false,
                                useSafeArea: true,
                                context: context,
                                builder: (context) {
                                  return WebViewAware(
                                    child: Padding(
                                      padding: MediaQuery.viewInsetsOf(context),
                                      child: UserJournalOptionsSheet(
                                        journalEntryRow: journalEntry,
                                      ),
                                    ),
                                  );
                                },
                              ).then((value) => safeSetState(() {}));
                            },
                            child: Icon(
                              Icons.keyboard_control_outlined,
                              color: FlutterFlowTheme.of(context).secondary,
                              size: 24.0,
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
                            journalEntry.journeyTitle,
                            'Journey Title',
                          ),
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                ),
                                fontSize: 12.0,
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
                          '${journalEntry.stepNumber?.toString()} - ${journalEntry.stepTitle}',
                          style: FlutterFlowTheme.of(context).titleMedium.override(
                                font: GoogleFonts.lexendDeca(
                                  fontWeight: FontWeight.w300,
                                  fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                ),
                                fontSize: 12.0,
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
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 0.0),
                            child: SelectionArea(
                              child: Text(
                                valueOrDefault<String>(
                                  journalEntry.journalSaved,
                                  'Type something here...',
                                ),
                                style: FlutterFlowTheme.of(context).bodySmall.override(
                                      font: GoogleFonts.lexendDeca(
                                        fontWeight: FontWeight.normal,
                                        fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                      ),
                                      color: FlutterFlowTheme.of(context).secondary,
                                      fontSize: 14.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.normal,
                                      fontStyle: FlutterFlowTheme.of(context).bodySmall.fontStyle,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

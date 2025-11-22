import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';

import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/index.dart';
import '../user_journal_view/user_journal_view_page.dart';
import 'view_model/user_journal_list_view_model.dart';

class UserJournalListPage extends StatefulWidget {
  const UserJournalListPage({super.key});

  static String routeName = 'userJournalList';
  static String routePath = '/userJournalList';

  @override
  State<UserJournalListPage> createState() => _UserJournalListPageState();
}

class _UserJournalListPageState extends State<UserJournalListPage> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserJournalListViewModel>().loadJournalEntries();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserJournalListViewModel>();

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
          'Your Journal',
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

  Widget _buildBody(BuildContext context, UserJournalListViewModel viewModel) {
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

    final journalEntries = viewModel.journalEntries;

    if (journalEntries.isEmpty) {
      return Center(
        child: Text(
          'No journal entries found.',
          style: FlutterFlowTheme.of(context).bodyMedium,
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(0, 12.0, 0, 0),
      shrinkWrap: true,
      scrollDirection: Axis.vertical,
      itemCount: journalEntries.length,
      itemBuilder: (context, index) {
        final entry = journalEntries[index];
        return Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 6.0),
          child: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.pushNamed(
                UserJournalViewPage.routeName,
                queryParameters: {
                  'userActivitiesId': serializeParam(
                    entry.userActivityId,
                    ParamType.int,
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
            },
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 4.0, 0.0),
                  child: Container(
                    width: MediaQuery.sizeOf(context).width * 0.9,
                    decoration: BoxDecoration(
                      color: FlutterFlowTheme.of(context).primaryBackground,
                      boxShadow: const [
                        BoxShadow(
                          blurRadius: 15.0,
                          color: Color(0x1A000000),
                          offset: Offset(0.0, 7.0),
                          spreadRadius: 3.0,
                        )
                      ],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: const Color(0xFFF5FBFB),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 12.0, 12.0, 12.0),
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
                                      AutoSizeText(
                                        dateTimeFormat(
                                          "yMMMd",
                                          entry.dateCompleted,
                                          locale: FFLocalizations.of(context).languageCode,
                                        ),
                                        minFontSize: 12.0,
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
                                        entry.journeyTitle,
                                        'Journey',
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
                                      '${entry.stepNumber?.toString()} - ${entry.stepTitle}',
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
                                        child: Text(
                                          valueOrDefault<String>(
                                            entry.journalSaved,
                                            'Your journal entry',
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
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

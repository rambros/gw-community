import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/index.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/profile/user_journal_list/view_model/user_journal_list_view_model.dart';
import 'package:gw_community/ui/profile/user_journal_view/user_journal_view_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

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
      backgroundColor: AppTheme.of(context).primaryBackground,
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
          onPressed: () => context.pop(),
        ),
        title: Text(
          'My Journal',
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.lexendDeca(),
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: SafeArea(
        top: true,
        child: Column(
          children: [
            // Header with subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Text(
                'Your journal entries are private and secure.',
                textAlign: TextAlign.center,
                style: AppTheme.of(context).bodySmall.override(
                      font: GoogleFonts.lexendDeca(),
                      color: AppTheme.of(context).secondaryText,
                      fontSize: 12.0,
                      letterSpacing: 0.0,
                    ),
              ),
            ),
            // Body content
            Expanded(
              child: _buildBody(context, viewModel),
            ),
          ],
        ),
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

    final journalEntries = viewModel.journalEntries;

    if (journalEntries.isEmpty) {
      return Center(
        child: Text(
          'No journal entries found.',
          style: AppTheme.of(context).bodyMedium,
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
                      color: AppTheme.of(context).primaryBackground,
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
                                        style: AppTheme.of(context).titleMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: FontWeight.w500,
                                                fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                              ),
                                              color: AppTheme.of(context).secondary,
                                              fontSize: 14.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FontWeight.w500,
                                              fontStyle: AppTheme.of(context).titleMedium.fontStyle,
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
                                      style: AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.lexendDeca(
                                              fontWeight: FontWeight.w300,
                                              fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                            ),
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                          ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.max,
                                  children: [
                                    Text(
                                      '${entry.stepNumber?.toString()} - ${entry.stepTitle}',
                                      style: AppTheme.of(context).titleMedium.override(
                                            font: GoogleFonts.lexendDeca(
                                              fontWeight: FontWeight.w300,
                                              fontStyle: AppTheme.of(context).titleMedium.fontStyle,
                                            ),
                                            fontSize: 12.0,
                                            letterSpacing: 0.0,
                                            fontWeight: FontWeight.w300,
                                            fontStyle: AppTheme.of(context).titleMedium.fontStyle,
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
                                          style: AppTheme.of(context).bodySmall.override(
                                                font: GoogleFonts.lexendDeca(
                                                  fontWeight: FontWeight.normal,
                                                  fontStyle: AppTheme.of(context).bodySmall.fontStyle,
                                                ),
                                                color: AppTheme.of(context).secondary,
                                                fontSize: 14.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FontWeight.normal,
                                                fontStyle: AppTheme.of(context).bodySmall.fontStyle,
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

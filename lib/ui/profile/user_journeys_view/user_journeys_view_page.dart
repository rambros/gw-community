import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '/ui/core/themes/flutter_flow_theme.dart';
import '/utils/flutter_flow_util.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/journey/journey_page/journey_page.dart';
import 'view_model/user_journeys_view_model.dart';

class UserJourneysViewPage extends StatefulWidget {
  const UserJourneysViewPage({super.key});

  static String routeName = 'userJourneysView';
  static String routePath = '/userJourneysView';

  @override
  State<UserJourneysViewPage> createState() => _UserJourneysViewPageState();
}

class _UserJourneysViewPageState extends State<UserJourneysViewPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UserJourneysViewModel>().loadJourneys();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UserJourneysViewModel>();

    return Scaffold(
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
          'Your Journeys',
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
        child: viewModel.isLoading
            ? Center(
                child: SizedBox(
                  width: 50.0,
                  height: 50.0,
                  child: SpinKitRipple(
                    color: FlutterFlowTheme.of(context).primary,
                    size: 50.0,
                  ),
                ),
              )
            : viewModel.errorMessage != null
                ? Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                            font: GoogleFonts.readexPro(
                              color: FlutterFlowTheme.of(context).error,
                            ),
                          ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(
                      0,
                      12.0,
                      0,
                      0,
                    ),
                    shrinkWrap: true,
                    scrollDirection: Axis.vertical,
                    itemCount: viewModel.journeys.length,
                    itemBuilder: (context, index) {
                      final journey = viewModel.journeys[index];
                      return Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 6.0, 0.0, 6.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: MediaQuery.sizeOf(context).width * 0.9,
                              height: 110.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).primaryBackground,
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 15.0,
                                    color: Color(0x1A000000),
                                    offset: Offset(
                                      0.0,
                                      7.0,
                                    ),
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
                                      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 1.0, 1.0, 0.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 4.0, 0.0, 3.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Text(
                                                  valueOrDefault<String>(
                                                    journey.title,
                                                    'title',
                                                  ),
                                                  style: FlutterFlowTheme.of(context).titleMedium.override(
                                                        font: GoogleFonts.lexendDeca(
                                                          fontWeight: FontWeight.w500,
                                                          fontStyle: FlutterFlowTheme.of(context).titleMedium.fontStyle,
                                                        ),
                                                        color: FlutterFlowTheme.of(context).secondary,
                                                        fontSize: 18.0,
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
                                              Padding(
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 12.0),
                                                child: Text(
                                                  'Completed  ${journey.stepsCompleted?.toString()} of ${journey.stepsTotal?.toString()} steps',
                                                  style: GoogleFonts.lexendDeca(
                                                    color: FlutterFlowTheme.of(context).secondary,
                                                    fontWeight: FontWeight.normal,
                                                    fontSize: 12.0,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 8.0),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                                                  child: FFButtonWidget(
                                                    onPressed: () async {
                                                      context.pushNamed(
                                                        JourneyPage.routeName,
                                                        queryParameters: {
                                                          'journeyId': serializeParam(
                                                            journey.journeyId,
                                                            ParamType.int,
                                                          ),
                                                        }.withoutNulls,
                                                      );
                                                    },
                                                    text: 'RESUME',
                                                    options: FFButtonOptions(
                                                      width: 100.0,
                                                      height: 32.0,
                                                      padding:
                                                          const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                                                      iconPadding:
                                                          const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                      color: FlutterFlowTheme.of(context).primary,
                                                      textStyle: FlutterFlowTheme.of(context).labelLarge.override(
                                                            font: GoogleFonts.poppins(
                                                              fontWeight:
                                                                  FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                              fontStyle:
                                                                  FlutterFlowTheme.of(context).labelLarge.fontStyle,
                                                            ),
                                                            color: FlutterFlowTheme.of(context).primaryBackground,
                                                            letterSpacing: 0.0,
                                                            fontWeight:
                                                                FlutterFlowTheme.of(context).labelLarge.fontWeight,
                                                            fontStyle:
                                                                FlutterFlowTheme.of(context).labelLarge.fontStyle,
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
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(16.0),
                                          child: Image.asset(
                                            'assets/images/logo_goodwishes_300.png',
                                            width: 74.0,
                                            height: 74.0,
                                            fit: BoxFit.scaleDown,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

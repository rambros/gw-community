import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' hide LinearGradient;
import 'package:smooth_page_indicator/smooth_page_indicator.dart' as smooth_page_indicator;

import '/flutter_flow/flutter_flow_animations.dart';
import '/flutter_flow/flutter_flow_icon_button.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import '/ui/auth/on_boarding_page/view_model/on_boarding_view_model.dart';
import '/ui/home/home_page/home_page.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  static String routeName = 'onBoardingPage';
  static String routePath = '/onBoardingPage';

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage> with TickerProviderStateMixin {
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final animationsMap = <String, AnimationInfo>{};

  @override
  void initState() {
    super.initState();
    logFirebaseEvent('screen_view', parameters: {'screen_name': 'onBoardingPage'});
    animationsMap.addAll({
      'textOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 60.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 80.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'iconButtonOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.4, 0.4),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 60.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation4': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 80.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'iconButtonOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.4, 0.4),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation5': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 60.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation6': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 80.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'iconButtonOnPageLoadAnimation3': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.4, 0.4),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation1': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(1.4, 1.4),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
      'containerOnPageLoadAnimation2': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          VisibilityEffect(duration: 1.ms),
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
          TiltEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0, 1.396),
            end: const Offset(0, 0),
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 300.0.ms,
            begin: const Offset(0.0, 40.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation7': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 70.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'textOnPageLoadAnimation8': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 90.0),
            end: const Offset(0.0, 0.0),
          ),
        ],
      ),
      'buttonOnPageLoadAnimation': AnimationInfo(
        trigger: AnimationTrigger.onPageLoad,
        effectsBuilder: () => [
          FadeEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: 0.0,
            end: 1.0,
          ),
          MoveEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.0, 100.0),
            end: const Offset(0.0, 0.0),
          ),
          ScaleEffect(
            curve: Curves.easeInOut,
            delay: 0.0.ms,
            duration: 600.0.ms,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          ),
        ],
      ),
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OnBoardingViewModel>(
      builder: (context, viewModel, child) {
        return GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            FocusManager.instance.primaryFocus?.unfocus();
          },
          child: Scaffold(
            key: scaffoldKey,
            backgroundColor: FlutterFlowTheme.of(context).alternate,
            appBar: AppBar(
              backgroundColor: FlutterFlowTheme.of(context).alternate,
              iconTheme: IconThemeData(color: FlutterFlowTheme.of(context).secondary),
              automaticallyImplyLeading: true,
              actions: const [],
              centerTitle: false,
              elevation: 0.0,
            ),
            body: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SizedBox(
                    width: double.infinity,
                    height: 700.0,
                    child: Stack(
                      children: [
                        PageView(
                          controller: viewModel.pageController,
                          onPageChanged: (_) => safeSetState(() {}),
                          scrollDirection: Axis.horizontal,
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Lottie.asset(
                                  'assets/jsons/logo_in.json',
                                  width: MediaQuery.sizeOf(context).width * 0.9,
                                  height: MediaQuery.sizeOf(context).height * 0.45,
                                  fit: BoxFit.contain,
                                  animate: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Journey',
                                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                              ),
                                              fontSize: 26.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                            ),
                                      ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation1']!),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                        child: Text(
                                          'Welcome to a wonderful journey! A journey to learn, create and share good wishes that have an impact. Good wishes are a way for self-transformation and world transformation. You will find inspirations, meditations, daily practices and companionship…',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondary,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                              ),
                                        ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation2']!),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FlutterFlowIconButton(
                                              borderColor: Colors.transparent,
                                              borderRadius: 30.0,
                                              borderWidth: 1.0,
                                              buttonSize: 60.0,
                                              icon: Icon(
                                                Icons.navigate_next_rounded,
                                                color: FlutterFlowTheme.of(context).secondary,
                                                size: 30.0,
                                              ),
                                              onPressed: () async {
                                                viewModel.nextPage();
                                              },
                                            ).animateOnPageLoad(animationsMap['iconButtonOnPageLoadAnimation1']!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Lottie.asset(
                                  'assets/jsons/logo_up.json',
                                  width: MediaQuery.sizeOf(context).width * 0.9,
                                  height: MediaQuery.sizeOf(context).height * 0.45,
                                  fit: BoxFit.contain,
                                  animate: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Learn',
                                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                              ),
                                              fontSize: 26.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                            ),
                                      ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation3']!),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                        child: Text(
                                          'When you feel that you would like to learn more, clarify or deepen your understanding and experience, new content and references are available to help you with your practice and personal progress…',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondary,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                              ),
                                        ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation4']!),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FlutterFlowIconButton(
                                              borderColor: Colors.transparent,
                                              borderRadius: 30.0,
                                              borderWidth: 1.0,
                                              buttonSize: 60.0,
                                              icon: Icon(
                                                Icons.navigate_next_rounded,
                                                color: FlutterFlowTheme.of(context).secondary,
                                                size: 30.0,
                                              ),
                                              onPressed: () async {
                                                viewModel.nextPage();
                                              },
                                            ).animateOnPageLoad(animationsMap['iconButtonOnPageLoadAnimation2']!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Lottie.asset(
                                  'assets/jsons/logo_out.json',
                                  width: MediaQuery.sizeOf(context).width * 0.9,
                                  height: MediaQuery.sizeOf(context).height * 0.45,
                                  fit: BoxFit.contain,
                                  animate: true,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Community',
                                        style: FlutterFlowTheme.of(context).headlineMedium.override(
                                              font: GoogleFonts.lexendDeca(
                                                fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                              ),
                                              fontSize: 26.0,
                                              letterSpacing: 0.0,
                                              fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                              fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                            ),
                                      ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation5']!),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 16.0, 0.0, 0.0),
                                        child: Text(
                                          'Collective good wishes are powerful. As you move along you will be part of a community of good wishers, available to help one another through the exchange of a heart-felt feelings that gives hope, strength and support… the basis for a new world.',
                                          textAlign: TextAlign.center,
                                          style: FlutterFlowTheme.of(context).labelMedium.override(
                                                font: GoogleFonts.poppins(
                                                  fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                                ),
                                                color: FlutterFlowTheme.of(context).secondary,
                                                fontSize: 16.0,
                                                letterSpacing: 0.0,
                                                fontWeight: FlutterFlowTheme.of(context).labelMedium.fontWeight,
                                                fontStyle: FlutterFlowTheme.of(context).labelMedium.fontStyle,
                                              ),
                                        ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation6']!),
                                      ),
                                      Padding(
                                        padding: const EdgeInsetsDirectional.fromSTEB(0.0, 12.0, 0.0, 0.0),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment: MainAxisAlignment.end,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            FlutterFlowIconButton(
                                              borderColor: Colors.transparent,
                                              borderRadius: 30.0,
                                              borderWidth: 1.0,
                                              buttonSize: 60.0,
                                              icon: Icon(
                                                Icons.navigate_next_rounded,
                                                color: FlutterFlowTheme.of(context).secondary,
                                                size: 30.0,
                                              ),
                                              onPressed: () async {
                                                viewModel.nextPage();
                                              },
                                            ).animateOnPageLoad(animationsMap['iconButtonOnPageLoadAnimation3']!),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 100.0,
                              height: 100.0,
                              decoration: BoxDecoration(
                                color: FlutterFlowTheme.of(context).alternate,
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: NetworkImage(
                                    'https://images.unsplash.com/photo-1522992319-0365e5f11656?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w0NTYyMDF8MHwxfHNlYXJjaHwxMnx8Y29mZmVlfGVufDB8fHx8MTcwNjY1MzkzMHww&ixlib=rb-4.0.3&q=80&w=1080',
                                  ),
                                ),
                              ),
                              child: ClipRRect(
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(
                                    sigmaX: 2.0,
                                    sigmaY: 2.0,
                                  ),
                                  child: Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      color: FlutterFlowTheme.of(context).alternate,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 100.0),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.max,
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Align(
                                            alignment: const AlignmentDirectional(0.0, -1.0),
                                            child: Padding(
                                              padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 44.0),
                                              child: Container(
                                                width: 300.0,
                                                height: 300.0,
                                                decoration: const BoxDecoration(
                                                  shape: BoxShape.circle,
                                                ),
                                                child: SizedBox(
                                                  width: 150.0,
                                                  height: 130.0,
                                                  child: RiveAnimation.asset(
                                                    'assets/rive_animations/animation_GW_01.riv',
                                                    artboard: 'GoodWishes_RGB_OUT_2.svg',
                                                    fit: BoxFit.contain,
                                                    controllers: viewModel.riveAnimationControllers,
                                                  ),
                                                ),
                                              ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation2']!),
                                            ),
                                          ),
                                          Text(
                                            'Your Journey Begins',
                                            style: FlutterFlowTheme.of(context).headlineMedium.override(
                                                  font: GoogleFonts.lexendDeca(
                                                    fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                                  ),
                                                  letterSpacing: 0.0,
                                                  fontWeight: FlutterFlowTheme.of(context).headlineMedium.fontWeight,
                                                  fontStyle: FlutterFlowTheme.of(context).headlineMedium.fontStyle,
                                                ),
                                          ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation7']!),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(24.0, 12.0, 24.0, 0.0),
                                            child: Text(
                                              'Sign up below in order to get started!',
                                              style: FlutterFlowTheme.of(context).titleSmall.override(
                                                    font: GoogleFonts.lexendDeca(
                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                    ),
                                                    color: FlutterFlowTheme.of(context).secondaryText,
                                                    letterSpacing: 0.0,
                                                    fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                    fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                  ),
                                            ).animateOnPageLoad(animationsMap['textOnPageLoadAnimation8']!),
                                          ),
                                          Padding(
                                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 24.0, 0.0, 0.0),
                                            child: FFButtonWidget(
                                              onPressed: () async {
                                                await viewModel.completeOnboarding(context);
                                                if (!context.mounted) return;
                                                context.pushNamed(HomePage.routeName);
                                              },
                                              text: 'Get Started',
                                              options: FFButtonOptions(
                                                width: 200.0,
                                                height: 50.0,
                                                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                                                color: FlutterFlowTheme.of(context).primary,
                                                textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                                                      font: GoogleFonts.lexendDeca(
                                                        fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                        fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                      ),
                                                      color: Colors.white,
                                                      letterSpacing: 0.0,
                                                      fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                                                      fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                                                    ),
                                                elevation: 2.0,
                                                borderSide: const BorderSide(
                                                  color: Colors.transparent,
                                                  width: 1.0,
                                                ),
                                                borderRadius: BorderRadius.circular(40.0),
                                              ),
                                            ).animateOnPageLoad(animationsMap['buttonOnPageLoadAnimation']!),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ).animateOnPageLoad(animationsMap['containerOnPageLoadAnimation1']!),
                          ],
                        ),
                        Align(
                          alignment: const AlignmentDirectional(0.0, 0.88),
                          child: Padding(
                            padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 10.0),
                            child: smooth_page_indicator.SmoothPageIndicator(
                              controller: viewModel.pageController,
                              count: 4,
                              axisDirection: Axis.horizontal,
                              onDotClicked: (i) async {
                                viewModel.animateToPage(i);
                              },
                              effect: smooth_page_indicator.ExpandingDotsEffect(
                                expansionFactor: 2.0,
                                spacing: 8.0,
                                radius: 16.0,
                                dotWidth: 16.0,
                                dotHeight: 4.0,
                                dotColor: FlutterFlowTheme.of(context).accent1,
                                activeDotColor: FlutterFlowTheme.of(context).primary,
                                paintStyle: PaintingStyle.fill,
                              ),
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

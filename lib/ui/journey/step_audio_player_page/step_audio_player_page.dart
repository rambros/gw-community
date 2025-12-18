import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '/ui/core/themes/app_theme.dart';
import '/ui/journey/themes/journey_theme_extension.dart';
import '/ui/core/ui/flutter_flow_icon_button.dart';
import '/ui/core/ui/flutter_flow_widgets.dart';
import '/ui/core/widgets/audio_player_widget.dart';

class StepAudioPlayerPage extends StatelessWidget {
  const StepAudioPlayerPage({
    super.key,
    this.stepAudioUrl,
    required this.audioTitle,
    required this.typeAnimation,
    required this.audioArt,
    required this.typeStep,
  });

  final String? stepAudioUrl;
  final String? audioTitle;
  final String? typeAnimation;
  final String? audioArt;
  final String? typeStep;

  static String routeName = 'stepAudioPlayerPage';
  static String routePath = '/stepAudioPlayerPage';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: AppTheme.of(context).black600,
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
            typeStep ?? 'Inspiration',
            style: AppTheme.of(context).journey.pageTitle,
          ),
          actions: const [],
          centerTitle: true,
          elevation: 2.0,
        ),
        body: SafeArea(
          top: true,
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(12.0, 32.0, 12.0, 16.0),
                child: Text(
                  audioTitle!,
                  textAlign: TextAlign.center,
                  style: AppTheme.of(context).journey.stepTitle,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimation(context),
                ],
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
                child: Container(
                  width: 600.0,
                  height: 150.0,
                  decoration: const BoxDecoration(),
                  child: SizedBox(
                    width: 600.0,
                    height: 620.0,
                    child: AudioPlayerWidget(
                      width: 600.0,
                      height: 620.0,
                      audioUrl: stepAudioUrl!,
                      audioTitle: audioTitle!,
                      audioArt: audioArt!,
                      colorButton: AppTheme.of(context).primary,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 8.0, 0.0),
                    child: FFButtonWidget(
                      onPressed: () {
                        // Audio transcript functionality
                      },
                      text: 'Audio Transcript',
                      icon: const Icon(
                        Icons.text_snippet,
                        size: 16.0,
                      ),
                      options: FFButtonOptions(
                        height: 40.0,
                        padding: const EdgeInsetsDirectional.fromSTEB(24.0, 0.0, 24.0, 0.0),
                        iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                        iconColor: AppTheme.of(context).primaryBackground,
                        color: AppTheme.of(context).secondaryText,
                        textStyle: AppTheme.of(context).journey.buttonText.override(
                              color: AppTheme.of(context).primaryText,
                            ),
                        elevation: 1.0,
                        borderSide: BorderSide(
                          color: AppTheme.of(context).primary,
                          width: 0.5,
                        ),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      showLoadingIndicator: false,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation(BuildContext context) {
    if (typeAnimation == 'IN') {
      return Lottie.asset(
        'assets/jsons/logo_in.json',
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.43,
        fit: BoxFit.contain,
        animate: true,
      );
    } else if (typeAnimation == 'UP') {
      return Lottie.asset(
        'assets/jsons/logo_up.json',
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.43,
        fit: BoxFit.contain,
        animate: true,
      );
    } else {
      return Lottie.asset(
        'assets/jsons/logo_out.json',
        width: MediaQuery.sizeOf(context).width * 0.9,
        height: MediaQuery.sizeOf(context).height * 0.43,
        fit: BoxFit.contain,
        animate: true,
      );
    }
  }
}

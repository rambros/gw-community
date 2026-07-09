import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:lottie/lottie.dart';

class StepAudioPlayerPage extends StatelessWidget {
  const StepAudioPlayerPage({
    super.key,
    this.stepAudioUrl,
    required this.audioTitle,
    required this.typeAnimation,
    required this.audioArt,
    required this.typeStep,
    this.activityId,
    this.transcript,
  });

  final String? stepAudioUrl;
  final String? audioTitle;
  final String? typeAnimation;
  final String? audioArt;
  final String? typeStep;
  final int? activityId;
  final String? transcript;

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
          actions: [
            if (transcript != null && transcript!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.text_snippet_outlined, color: Colors.white, size: 26.0),
                tooltip: 'Transcript',
                onPressed: () => _showTranscriptDialog(context),
              ),
            if (context.currentUserIdOrEmpty.isNotEmpty && activityId != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                child: FavoriteButton(
                  contentType: FavoritesRepository.typeActivity,
                  contentId: activityId!,
                  authUserId: context.currentUserIdOrEmpty,
                  size: 28.0,
                  iconColor: Colors.white,
                ),
              ),
          ],
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
              if (transcript != null && transcript!.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(24.0, 4.0, 24.0, 0.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showTranscriptDialog(context),
                      icon: const Icon(Icons.text_snippet_outlined, size: 20.0),
                      label: const Text('Transcript'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white54, width: 1.0),
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTranscriptDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  width: 40.0,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2.0),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(20.0, 16.0, 20.0, 8.0),
                child: Text(
                  audioTitle ?? 'Transcript',
                  style: AppTheme.of(context).journey.stepTitle.copyWith(
                        fontSize: 16.0,
                        color: Colors.black87,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Divider(color: Colors.black12),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsetsDirectional.fromSTEB(20.0, 8.0, 20.0, 32.0),
                  child: Text(
                    transcript!,
                    style: AppTheme.of(context).bodyMedium.copyWith(
                          height: 1.7,
                          color: Colors.black87,
                        ),
                  ),
                ),
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

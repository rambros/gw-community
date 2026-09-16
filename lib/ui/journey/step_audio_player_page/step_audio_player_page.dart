import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/core/widgets/glow_animation_config.dart';
import 'package:gw_community/ui/core/widgets/pulsing_radial_glow.dart';
import 'package:gw_community/ui/core/widgets/transcript_reading_page.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/ui/journey/widgets/journey_locale_scope.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:lottie/lottie.dart';
import 'package:rive/rive.dart' hide Image;

class StepAudioPlayerPage extends StatelessWidget {
  const StepAudioPlayerPage({
    super.key,
    this.stepAudioUrl,
    required this.audioTitle,
    required this.audioArt,
    required this.typeStep,
    this.activityId,
    this.transcript,
    this.animationUrl,
    this.animationMediaType,
    this.fixedLanguage,
  });

  final String? stepAudioUrl;
  final String? audioTitle;
  final String? audioArt;
  final String? typeStep;
  final int? activityId;
  final String? transcript;
  final String? animationUrl;
  final String? animationMediaType;
  final String? fixedLanguage;

  static String routeName = 'stepAudioPlayerPage';
  static String routePath = '/stepAudioPlayerPage';

  static const defaultAudioArt =
      'https://firebasestorage.googleapis.com/v0/b/good-wishes-project.appspot.com/o/images%2Fic_goodwishes.png?alt=media&token=e441f239-c823-468b-bff7-c16be921c7be';

  static const nativeGlowMediaType = 'glow';
  static const nativeGlowUrl = 'native://glow';

  bool get _isNativeGlow {
    final url = animationUrl;
    return animationMediaType == nativeGlowMediaType ||
        (url != null && url.startsWith(nativeGlowUrl));
  }

  /// Passes audio data via `extra` so URLs and transcripts are not stripped
  /// from the query string (`?`, `&`, `%20`, long text).
  static Future<T?> open<T extends Object?>(
    GoRouter router, {
    String? audioUrl,
    String? audioTitle,
    String? audioArt,
    String? typeStep,
    int? activityId,
    String? transcript,
    String? animationUrl,
    String? animationMediaType,
    String? fixedLanguage,
  }) {
    return router.pushNamed(
      routeName,
      extra: <String, dynamic>{
        'stepAudioUrl': audioUrl ?? '',
        'audioTitle': audioTitle,
        'audioArt': (audioArt != null && audioArt.isNotEmpty) ? audioArt : defaultAudioArt,
        'typeStep': typeStep,
        'activityId': activityId,
        'transcript': transcript,
        'animationUrl': animationUrl,
        'animationMediaType': animationMediaType,
        if (fixedLanguage != null) 'fixedLanguage': fixedLanguage,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return JourneyLocaleScope(
      fixedLanguage: fixedLanguage,
      builder: (context) => GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
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
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            localizedJourneyActivityLabel(context.l10n, typeStep),
            style: AppTheme.of(context).journey.pageTitle,
          ),
          actions: [
            if (transcript != null && transcript!.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.text_snippet_outlined, color: Colors.white, size: 26.0),
                tooltip: context.l10n.transcript,
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
        body: _buildBody(context),
      ),
    ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final theme = AppTheme.of(context);
    final content = SafeArea(
      top: true,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 32.0, 12.0, 16.0),
            child: Text(
              audioTitle ?? '',
              textAlign: TextAlign.center,
              style: theme.journey.stepTitle.override(
                color: theme.secondary,
              ),
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
                  audioUrl: stepAudioUrl ?? '',
                  audioTitle: audioTitle ?? '',
                  audioArt: audioArt,
                  colorButton: theme.primary,
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
                  label: Text(context.l10n.transcript),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: theme.primary,
                    side: BorderSide(color: theme.primary, width: 1.0),
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
    );

    return content;
  }

  void _showTranscriptDialog(BuildContext context) {
    TranscriptReadingPage.open(
      context,
      appBarTitle: context.l10n.transcript,
      title: audioTitle ?? context.l10n.transcript,
      data: transcript!,
    );
  }

  Widget _buildAnimation(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width * 0.9;
    final height = MediaQuery.sizeOf(context).height * 0.43;
    final theme = AppTheme.of(context);

    if (_isNativeGlow) {
      final glow = GlowAnimationConfig.parse(animationUrl);
      return SizedBox(
        width: width,
        height: height,
        child: PulsingRadialGlow(
          highlightColor: glow.highlightColor,
          centerColor: Color.lerp(
                glow.highlightColor,
                glow.midColor,
                0.35,
              ) ??
              glow.midColor,
          midColor: glow.midColor,
          outerColor: theme.primaryBackground,
          center: Alignment.center,
          duration: glow.duration,
          waveCount: 4,
          minRadius: glow.minRadius,
          maxRadius: glow.maxRadius,
          intensity: glow.intensityScale,
        ),
      );
    }

    if (animationUrl == null || animationUrl!.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    switch (animationMediaType) {
      case 'lottie':
        return Lottie.network(
          animationUrl!,
          width: width,
          height: height,
          fit: BoxFit.contain,
          animate: true,
          errorBuilder: (context, error, stackTrace) =>
              SizedBox(width: width, height: height),
        );
      case 'rive':
        return SizedBox(
          width: width,
          height: height,
          child: RiveAnimation.network(
            animationUrl!,
            fit: BoxFit.contain,
            onInit: (_) {},
          ),
        );
      case 'image':
        return Image.network(
          animationUrl!,
          width: width,
          height: height,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) =>
              SizedBox(width: width, height: height),
        );
      default:
        return SizedBox(width: width, height: height);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/repositories/journeys_repository.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/community/experience_add_page/experience_add_page.dart';
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
    return _StepAudioLocaleHost(page: this);
  }

  Widget _buildLocalized(BuildContext context, String? language) {
    return JourneyLocaleScope(
      fixedLanguage: language,
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
        body: _JourneyAudioColumn(page: this, shareLanguage: language),
      ),
    ),
    );
  }

  void _showTranscriptDialog(BuildContext context) {
    TranscriptReadingPage.open(
      context,
      appBarTitle: context.l10n.transcript,
      title: audioTitle ?? context.l10n.transcript,
      data: transcript!,
    );
  }

  Widget _buildAnimation(BuildContext context, {required double maxHeight}) {
    final width = MediaQuery.sizeOf(context).width * 0.9;
    final preferred = MediaQuery.sizeOf(context).height * 0.43;
    final height = preferred < maxHeight ? preferred : maxHeight;
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

class _JourneyAudioColumn extends StatefulWidget {
  const _JourneyAudioColumn({
    required this.page,
    required this.shareLanguage,
  });

  final StepAudioPlayerPage page;
  final String? shareLanguage;

  @override
  State<_JourneyAudioColumn> createState() => _JourneyAudioColumnState();
}

class _JourneyAudioColumnState extends State<_JourneyAudioColumn> {
  bool _finished = false;

  bool get _isMeditation {
    final label = widget.page.typeStep?.trim().toLowerCase() ?? '';
    final base = label.replaceFirst(RegExp(r'\s+\d+$'), '');
    switch (base) {
      case 'meditation':
      case 'meditação':
      case 'meditacao':
        return true;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final page = widget.page;
    final theme = AppTheme.of(context);

    return SafeArea(
      top: true,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12.0, 32.0, 12.0, 16.0),
            child: Text(
              page.audioTitle ?? '',
              textAlign: TextAlign.center,
              style: theme.journey.stepTitle.override(
                color: theme.secondary,
              ),
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Center(
                  child: page._buildAnimation(
                    context,
                    maxHeight: constraints.maxHeight,
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(4.0, 0.0, 4.0, 0.0),
            child: SizedBox(
              width: 600.0,
              height: 150.0,
              child: AudioPlayerWidget(
                width: 600.0,
                height: 150.0,
                audioUrl: page.stepAudioUrl ?? '',
                audioTitle: page.audioTitle ?? '',
                audioArt: page.audioArt,
                colorButton: theme.primary,
                onCompleted: _isMeditation
                    ? () {
                        if (!_finished && mounted) {
                          setState(() => _finished = true);
                        }
                      }
                    : null,
              ),
            ),
          ),
          if (_finished)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 4.0, 24.0, 12.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onPressed: () {
                    final language = widget.shareLanguage?.trim();
                    context.pushNamed(
                      ExperienceAddPage.routeName,
                      extra: <String, dynamic>{
                        'chooseGroups': true,
                        if (language != null && language.isNotEmpty)
                          'fixedLanguage': language,
                      },
                    );
                  },
                  child: Text(context.l10n.likedShareExperience),
                ),
              ),
            ),
          if (page.transcript != null && page.transcript!.isNotEmpty)
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24.0, 4.0, 24.0, 12.0),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => page._showTranscriptDialog(context),
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
  }
}

/// Keeps the player in the journey language even when the route dropped it.
class _StepAudioLocaleHost extends StatefulWidget {
  const _StepAudioLocaleHost({required this.page});

  final StepAudioPlayerPage page;

  @override
  State<_StepAudioLocaleHost> createState() => _StepAudioLocaleHostState();
}

class _StepAudioLocaleHostState extends State<_StepAudioLocaleHost> {
  String? _language;

  @override
  void initState() {
    super.initState();
    _language = _nonEmpty(widget.page.fixedLanguage);
    final activityId = widget.page.activityId;
    if (_language == null && activityId != null) {
      _loadLanguage(activityId);
    }
  }

  @override
  void didUpdateWidget(covariant _StepAudioLocaleHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = _nonEmpty(widget.page.fixedLanguage);
    if (next != null && next != _language) {
      _language = next;
    }
  }

  Future<void> _loadLanguage(int activityId) async {
    final code = await JourneysRepository().fixedLanguageForStepActivity(activityId);
    if (!mounted) return;
    final resolved = _nonEmpty(code);
    if (resolved == null || resolved == _language) return;
    setState(() => _language = resolved);
  }

  @override
  Widget build(BuildContext context) {
    return widget.page._buildLocalized(context, _language);
  }
}

String? _nonEmpty(String? value) {
  final trimmed = value?.trim();
  if (trimmed == null || trimmed.isEmpty) return null;
  return trimmed;
}

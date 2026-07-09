import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/journey/themes/journey_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:video_player/video_player.dart';

class StepVideoPlayerPage extends StatefulWidget {
  const StepVideoPlayerPage({
    super.key,
    this.videoUrl,
    this.videoTitle,
    this.typeStep,
    this.activityId,
  });

  final String? videoUrl;
  final String? videoTitle;
  final String? typeStep;
  final int? activityId;

  static String routeName = 'stepVideoPlayerPage';
  static String routePath = '/stepVideoPlayerPage';

  @override
  State<StepVideoPlayerPage> createState() => _StepVideoPlayerPageState();
}

class _StepVideoPlayerPageState extends State<StepVideoPlayerPage> {
  VideoPlayerController? _videoController;
  bool _isInitialized = false;
  bool _isError = false;

  bool get _isYouTube {
    final url = widget.videoUrl ?? '';
    return url.contains('youtube.com') || url.contains('youtu.be');
  }

  @override
  void initState() {
    super.initState();
    if (!_isYouTube && widget.videoUrl != null && widget.videoUrl!.isNotEmpty) {
      _initDirectVideoPlayer();
    }
  }

  Future<void> _initDirectVideoPlayer() async {
    try {
      _videoController = VideoPlayerController.networkUrl(
        Uri.parse(widget.videoUrl!),
      );
      await _videoController!.initialize();
      if (mounted) setState(() => _isInitialized = true);
    } catch (_) {
      if (mounted) setState(() => _isError = true);
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

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
              _videoController?.pause();
              Navigator.of(context).pop();
            },
          ),
          title: Text(
            widget.typeStep ?? 'Video',
            style: AppTheme.of(context).journey.pageTitle,
          ),
          actions: [
            if (context.currentUserIdOrEmpty.isNotEmpty && widget.activityId != null)
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 12.0, 0.0),
                child: FavoriteButton(
                  contentType: FavoritesRepository.typeActivity,
                  contentId: widget.activityId!,
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
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.videoTitle != null && widget.videoTitle!.isNotEmpty)
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(12.0, 32.0, 12.0, 32.0),
                  child: Text(
                    widget.videoTitle!,
                    textAlign: TextAlign.center,
                    style: AppTheme.of(context).journey.stepTitle,
                  ),
                ),
              _buildPlayer(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlayer(BuildContext context) {
    final url = widget.videoUrl;

    if (url == null || url.isEmpty) {
      return _buildMessage(context, 'No video URL provided.');
    }

    if (_isYouTube) {
      return FlutterFlowYoutubePlayer(
        url: url,
        autoPlay: false,
        looping: false,
        mute: false,
        showControls: true,
        showFullScreen: true,
        strictRelatedVideos: false,
      );
    }

    // Direct video URL
    if (_isError) {
      return _buildMessage(context, 'Could not load video.');
    }

    if (!_isInitialized || _videoController == null) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48.0),
        child: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    return _DirectVideoPlayer(controller: _videoController!);
  }

  Widget _buildMessage(BuildContext context, String message) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(24.0, 48.0, 24.0, 0.0),
      child: Center(
        child: Text(
          message,
          style: AppTheme.of(context).bodyMedium.copyWith(
                color: AppTheme.of(context).secondaryText,
              ),
        ),
      ),
    );
  }
}

class _DirectVideoPlayer extends StatefulWidget {
  const _DirectVideoPlayer({required this.controller});
  final VideoPlayerController controller;

  @override
  State<_DirectVideoPlayer> createState() => _DirectVideoPlayerState();
}

class _DirectVideoPlayerState extends State<_DirectVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerUpdate);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerUpdate);
    super.dispose();
  }

  void _onControllerUpdate() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final aspectRatio = controller.value.aspectRatio;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: AspectRatio(
            aspectRatio: aspectRatio > 0 ? aspectRatio : 16 / 9,
            child: VideoPlayer(controller),
          ),
        ),
        // Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              IconButton(
                icon: Icon(
                  controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                  size: 32.0,
                ),
                onPressed: () {
                  controller.value.isPlaying ? controller.pause() : controller.play();
                },
              ),
              Expanded(
                child: VideoProgressIndicator(
                  controller,
                  allowScrubbing: true,
                  colors: VideoProgressColors(
                    playedColor: Theme.of(context).colorScheme.primary,
                    bufferedColor: Colors.white30,
                    backgroundColor: Colors.white12,
                  ),
                ),
              ),
              const SizedBox(width: 8.0),
              _buildDuration(controller),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDuration(VideoPlayerController controller) {
    final position = controller.value.position;
    final duration = controller.value.duration;

    String fmt(Duration d) =>
        '${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}';

    return Text(
      '${fmt(position)} / ${fmt(duration)}',
      style: const TextStyle(color: Colors.white70, fontSize: 12.0),
    );
  }
}

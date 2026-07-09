/*
Copyright 2021 Sarbagya Dhaubanjar. All rights reserved.

Redistribution and use in source and binary forms, with or without modification,
are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/utils/flutter_flow_util.dart' show routeObserver;
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

const kYoutubeAspectRatio = 16 / 9;

class FlutterFlowYoutubePlayer extends StatefulWidget {
  const FlutterFlowYoutubePlayer({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.autoPlay = false,
    this.mute = false,
    this.looping = false,
    this.showControls = true,
    this.showFullScreen = false,
    this.pauseOnNavigate = true,
    this.strictRelatedVideos = false,
  });

  final String url;
  final double? width;
  final double? height;
  final bool autoPlay;
  final bool mute;
  final bool looping;
  final bool showControls;
  final bool showFullScreen;
  final bool pauseOnNavigate;
  final bool strictRelatedVideos;

  @override
  State<FlutterFlowYoutubePlayer> createState() => _FlutterFlowYoutubePlayerState();
}

class _FlutterFlowYoutubePlayerState extends State<FlutterFlowYoutubePlayer> with RouteAware {
  YoutubePlayerController? _controller;
  bool _subscribedRoute = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void dispose() {
    if (_subscribedRoute) routeObserver.unsubscribe(this);
    _controller?.close();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (widget.pauseOnNavigate && ModalRoute.of(context) is PageRoute) {
      _subscribedRoute = true;
      routeObserver.subscribe(this, ModalRoute.of(context)!);
    }
  }

  @override
  void didPushNext() {
    if (widget.pauseOnNavigate) _controller?.pauseVideo();
  }

  double get _width =>
      widget.width == null || widget.width! >= double.infinity ? MediaQuery.sizeOf(context).width : widget.width!;

  double get _height =>
      widget.height == null || widget.height! >= double.infinity ? _width / kYoutubeAspectRatio : widget.height!;

  void _initializePlayer() {
    if (!mounted) return;
    final videoId = _convertUrlToId(widget.url);
    if (videoId == null) return;

    _controller = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: widget.autoPlay,
      params: YoutubePlayerParams(
        origin: 'https://www.youtube-nocookie.com',
        mute: widget.mute,
        loop: widget.looping,
        showControls: widget.showControls,
        showFullscreenButton: widget.showFullScreen,
        strictRelatedVideos: widget.strictRelatedVideos,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          height: _height,
          width: _width,
          child: _controller != null
              ? YoutubePlayer(
                  controller: _controller!,
                  gestureRecognizers: const <Factory<TapGestureRecognizer>>{},
                  enableFullScreenOnVerticalDrag: false,
                )
              : Container(color: Colors.transparent),
        ),
      );
}

/// Kept for API compatibility — fullscreen is handled internally by [YoutubePlayer] in v6+.
class YoutubeFullScreenWrapper extends StatelessWidget {
  const YoutubeFullScreenWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

String? _convertUrlToId(String url, {bool trimWhitespaces = true}) {
  assert(url.isNotEmpty, 'Url cannot be empty');
  if (!url.contains("http") && (url.length == 11)) return url;
  if (trimWhitespaces) url = url.trim();
  for (final regex in [
    // ignore: deprecated_member_use
    RegExp(
      r"^https:\/\/(?:www\.|m\.)?youtube\.com\/watch\?v=([_\-a-zA-Z0-9]{11}).*$",
    ),
    // ignore: deprecated_member_use
    RegExp(
      r"^https:\/\/(?:www\.|m\.)?youtube(?:-nocookie)?\.com\/embed\/([_\-a-zA-Z0-9]{11}).*$",
    ),
    // ignore: deprecated_member_use
    RegExp(r"^https:\/\/youtu\.be\/([_\-a-zA-Z0-9]{11}).*$")
  ]) {
    final match = regex.firstMatch(url);
    if (match != null && match.groupCount >= 1) return match.group(1);
  }
  return null;
}

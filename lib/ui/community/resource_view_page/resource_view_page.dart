import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/ui/pinch_zoom_image.dart';
import 'package:gw_community/ui/core/ui/reading_text_size.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceViewPage extends StatefulWidget {
  const ResourceViewPage({super.key, required this.resource});

  final CcFileResourcesRow resource;

  @override
  State<ResourceViewPage> createState() => _ResourceViewPageState();
}

class _ResourceViewPageState extends State<ResourceViewPage> {
  String? _textContent;
  bool _loadingText = false;

  @override
  void initState() {
    super.initState();
    if (widget.resource.type == 'text') {
      _loadTextContent();
    }
  }

  String? get _authoredBody {
    final body = widget.resource.body?.trim();
    if (body == null || body.isEmpty) return null;
    return body;
  }

  Future<void> _loadTextContent() async {
    if (_authoredBody != null) return;

    // Use description stored at link time if available
    if (widget.resource.description != null &&
        widget.resource.description!.isNotEmpty) {
      setState(() => _textContent = widget.resource.description);
      return;
    }

    // Fallback: fetch from the original portal content item
    final portalId = widget.resource.portalItemId;
    if (portalId == null) return;

    setState(() => _loadingText = true);
    try {
      final rows = await ViewContentTable().queryRows(
        queryFn: (q) => q.eq('content_id', portalId),
      );
      if (mounted && rows.isNotEmpty) {
        setState(() {
          _textContent = rows.first.text;
          _loadingText = false;
        });
      } else if (mounted) {
        setState(() => _loadingText = false);
      }
    } catch (e) {
      if (mounted) setState(() => _loadingText = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        title: Text(
          widget.resource.title,
          style: GoogleFonts.montserrat(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 17,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (isImageResource(type: widget.resource.type, url: widget.resource.url)) {
      return _buildImage(context);
    }
    switch (widget.resource.type) {
      case 'pdf':
        return _buildPdfViewer(context);
      case 'audio':
        return _buildAudioPlayer(context);
      case 'video':
        return _buildVideoPlayer(context);
      case 'text':
        return _buildTextContent(context);
      default:
        return _buildFallback(context);
    }
  }

  Widget _buildImage(BuildContext context) {
    final summary = widget.resource.description?.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (summary != null && summary.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
            child: Text(
              summary,
              style: AppTheme.of(context).bodyMedium.override(
                    font: GoogleFonts.openSans(),
                    color: AppTheme.of(context).textColor,
                    fontSize: 16,
                    letterSpacing: 0,
                  ),
            ),
          ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PinchZoomImage(imageUrl: widget.resource.url),
          ),
        ),
      ],
    );
  }

  Widget _buildPdfViewer(BuildContext context) {
    return FlutterFlowPdfViewer(
      networkPath: widget.resource.url,
      width: double.infinity,
      height: double.infinity,
    );
  }

  Widget _buildAudioPlayer(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.resource.description != null &&
                widget.resource.description!.isNotEmpty) ...[
              Text(
                widget.resource.description!,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.openSans(),
                      color: AppTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            AudioPlayerWidget(
              audioUrl: widget.resource.url,
              audioTitle: widget.resource.title,
              audioArt: null,
              width: double.infinity,
              height: 180,
              colorButton: AppTheme.of(context).primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(16, 16, 16, 0),
            child: FlutterFlowYoutubePlayer(
              url: widget.resource.url,
              autoPlay: false,
              looping: false,
              mute: false,
              showControls: true,
              showFullScreen: true,
              strictRelatedVideos: false,
            ),
          ),
          if (widget.resource.description != null &&
              widget.resource.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                widget.resource.description!,
                style: AppTheme.of(context).bodyMedium.override(
                      font: GoogleFonts.openSans(),
                      color: AppTheme.of(context).secondaryText,
                      letterSpacing: 0,
                    ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTextContent(BuildContext context) {
    if (_loadingText) {
      return Center(
        child: CircularProgressIndicator(
          valueColor:
              AlwaysStoppedAnimation<Color>(AppTheme.of(context).primary),
        ),
      );
    }

    final content = _authoredBody ?? _textContent ?? '';
    final summary = widget.resource.description?.trim();
    final showSummary = _authoredBody != null &&
        summary != null &&
        summary.isNotEmpty &&
        summary != content;
    if (content.isEmpty) {
      return Center(
        child: Text(
          context.l10n.noContentAvailable,
          style: AppTheme.of(context).bodyMedium.override(
                font: GoogleFonts.openSans(),
                color: AppTheme.of(context).secondaryText,
              ),
        ),
      );
    }

    return ReadingTextSize(
      barColor: AppTheme.of(context).primaryBackground,
      builder: (context, fontSize, controls) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            controls,
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showSummary) ...[
                      Text(
                        summary,
                        style: AppTheme.of(context).bodyMedium.override(
                              font: GoogleFonts.openSans(),
                              color: AppTheme.of(context).textColor,
                              fontSize: 16,
                              letterSpacing: 0,
                            ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    MarkdownBody(
                      data: content,
                      onTapLink: (text, href, title) async {
                        if (href != null) {
                          final uri = Uri.tryParse(href);
                          if (uri != null) {
                            await launchUrl(
                              uri,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      styleSheet: _resourceMarkdownStyle(context, fontSize),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.tryParse(widget.resource.url);
          if (uri != null)
            await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Open Resource'),
      ),
    );
  }
}

MarkdownStyleSheet _resourceMarkdownStyle(
  BuildContext context,
  double fontSize,
) {
  final paragraph = GoogleFonts.lexendDeca(
    color: Colors.black87,
    fontSize: fontSize,
    fontWeight: FontWeight.normal,
    height: 1.6,
  );
  return MarkdownStyleSheet(
    textAlign: WrapAlignment.start,
    p: paragraph,
    strong: paragraph.copyWith(fontWeight: FontWeight.bold),
    em: paragraph.copyWith(fontStyle: FontStyle.italic),
    h1: GoogleFonts.lexendDeca(
      color: Colors.black,
      fontSize: readingMarkdownHeadingSize(fontSize, 1),
      fontWeight: FontWeight.bold,
    ),
    h2: GoogleFonts.lexendDeca(
      color: Colors.black,
      fontSize: readingMarkdownHeadingSize(fontSize, 2),
      fontWeight: FontWeight.bold,
    ),
    h3: GoogleFonts.lexendDeca(
      color: Colors.black,
      fontSize: readingMarkdownHeadingSize(fontSize, 3),
      fontWeight: FontWeight.w600,
    ),
    a: GoogleFonts.lexendDeca(
      color: AppTheme.of(context).primary,
      fontSize: fontSize,
      decoration: TextDecoration.underline,
    ),
    blockquote: GoogleFonts.lexendDeca(
      color: Colors.black54,
      fontSize: fontSize,
      fontStyle: FontStyle.italic,
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_pdf_viewer.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_youtube_player.dart';
import 'package:gw_community/ui/core/widgets/audio_player_widget.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceViewPage extends StatelessWidget {
  const ResourceViewPage({super.key, required this.resource});

  final CcFileResourcesRow resource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        title: Text(
          resource.title,
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
    switch (resource.type) {
      case 'pdf':
        return _buildPdfViewer(context);
      case 'audio':
        return _buildAudioPlayer(context);
      case 'video':
        return _buildVideoPlayer(context);
      default:
        return _buildFallback(context);
    }
  }

  Widget _buildPdfViewer(BuildContext context) {
    return FlutterFlowPdfViewer(
      networkPath: resource.url,
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
            if (resource.description != null && resource.description!.isNotEmpty) ...[
              Text(
                resource.description!,
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
              audioUrl: resource.url,
              audioTitle: resource.title,
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
              url: resource.url,
              autoPlay: false,
              looping: false,
              mute: false,
              showControls: true,
              showFullScreen: true,
              strictRelatedVideos: false,
            ),
          ),
          if (resource.description != null && resource.description!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Text(
                resource.description!,
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

  Widget _buildFallback(BuildContext context) {
    return Center(
      child: ElevatedButton.icon(
        onPressed: () async {
          final uri = Uri.tryParse(resource.url);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        },
        icon: const Icon(Icons.open_in_new),
        label: const Text('Open Resource'),
      ),
    );
  }
}

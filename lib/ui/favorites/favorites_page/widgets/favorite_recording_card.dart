import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/content_view/content_view.dart';
import 'package:gw_community/ui/learn/themes/learn_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Card de recording favorito (baseado no ContentCard)
class FavoriteRecordingCard extends StatelessWidget {
  const FavoriteRecordingCard({
    super.key,
    required this.recording,
    this.onUnfavorite,
  });

  final CcViewUserFavoriteRecordingsRow recording;
  final VoidCallback? onUnfavorite;

  Future<void> _openContent(BuildContext context) async {
    // Converte para ViewContentRow para compatibilidade com ContentView
    final viewContentRow = ViewContentRow({
      'content_id': recording.contentId,
      'title': recording.title,
      'description': recording.description,
      'authors_names': recording.authorsNames,
      'midia_type': recording.midiaType,
      'audio_url': recording.audioUrl,
      'midia_file_url': recording.midiaFileUrl,
      'cott_event_id': recording.cottEventId,
      'event_name': recording.eventName,
    });

    await showModalBottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      isDismissible: true,
      context: context,
      builder: (context) {
        return WebViewAware(
          child: Padding(
            padding: MediaQuery.viewInsetsOf(context),
            child: ContentView(
              contentId: recording.contentId!,
              viewContentRow: viewContentRow,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openContent(context),
        child: Container(
          width: double.infinity,
          height: 110.0,
          decoration: BoxDecoration(
            color: AppTheme.of(context).primaryBackground,
            boxShadow: const [
              BoxShadow(
                blurRadius: 8.0,
                color: Color(0x1A000000),
                offset: Offset(0.0, 2.0),
                spreadRadius: 1.0,
              )
            ],
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(
              color: AppTheme.of(context).primaryBackground,
              width: 1.0,
            ),
          ),
          child: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsetsDirectional.fromSTEB(
                                        0.0, 0.0, 0.0, 4.0),
                                    child: AutoSizeText(
                                      valueOrDefault<String>(
                                        recording.title,
                                        'Title',
                                      ),
                                      textAlign: TextAlign.start,
                                      minFontSize: 12.0,
                                      style: AppTheme.of(context)
                                          .learn
                                          .contentTitle
                                          .override(
                                            color:
                                                AppTheme.of(context).secondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              (List<String> listAuthors) {
                                return listAuthors.join(', ');
                              }(recording.authorsNames.toList()),
                              style:
                                  AppTheme.of(context).learn.metadata.override(
                                        color: AppTheme.of(context).secondary,
                                      ),
                            ),
                            Flexible(
                              child: Align(
                                alignment:
                                    const AlignmentDirectional(-1.0, -1.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsetsDirectional
                                            .fromSTEB(0.0, 4.0, 0.0, 0.0),
                                        child: Text(
                                          valueOrDefault<String>(
                                            recording.description,
                                            'description',
                                          ).maybeHandleOverflow(
                                            maxChars: 150,
                                            replacement: '…',
                                          ),
                                          textAlign: TextAlign.start,
                                          maxLines: 3,
                                          style: AppTheme.of(context)
                                              .learn
                                              .bodyLight
                                              .override(
                                                color: AppTheme.of(context)
                                                    .secondary,
                                                fontSize: 12.0,
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
                      if (context.currentUserIdOrEmpty.isNotEmpty &&
                          recording.contentId != null)
                        FavoriteButton(
                          contentType: FavoritesRepository.typeRecording,
                          contentId: recording.contentId!,
                          authUserId: context.currentUserIdOrEmpty,
                          size: 22.0,
                          initialIsFavorite: true,
                          onToggle: (isFavorite) {
                            if (!isFavorite) {
                              onUnfavorite?.call();
                            }
                          },
                        ),
                      Padding(
                        padding: const EdgeInsetsDirectional.fromSTEB(
                            0.0, 0.0, 8.0, 0.0),
                        child: _buildMediaIcon(context),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMediaIcon(BuildContext context) {
    if (recording.midiaType == 'audio') {
      return Icon(
        Icons.audiotrack_sharp,
        color: AppTheme.of(context).primary,
        size: 32.0,
      );
    } else if (recording.midiaType == 'text') {
      return Icon(
        Icons.text_snippet,
        color: AppTheme.of(context).primary,
        size: 32.0,
      );
    } else if (recording.midiaType == 'video') {
      return Icon(
        Icons.ondemand_video,
        color: AppTheme.of(context).primary,
        size: 34.0,
      );
    } else {
      return const SizedBox(width: 4.0, height: 4.0);
    }
  }
}

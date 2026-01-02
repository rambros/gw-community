import 'package:flutter/material.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/content_view/content_view.dart';
import 'package:gw_community/ui/learn/themes/learn_theme_extension.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';
import 'package:webviewx_plus/webviewx_plus.dart';

/// Card de recording favorito (redesenhado com novo layout)
class FavoriteRecordingCard extends StatefulWidget {
  const FavoriteRecordingCard({
    super.key,
    required this.recording,
    this.onUnfavorite,
  });

  final CcViewUserFavoriteRecordingsRow recording;
  final VoidCallback? onUnfavorite;

  @override
  State<FavoriteRecordingCard> createState() => _FavoriteRecordingCardState();
}

class _FavoriteRecordingCardState extends State<FavoriteRecordingCard> {
  int _favoriteVersion = 0;

  Future<void> _openContent(BuildContext context) async {
    // Capturar valores antes do async gap
    final repository = context.read<FavoritesRepository>();
    final currentUserId = context.currentUserIdOrEmpty;

    // Converte para ViewContentRow para compatibilidade com ContentView
    final viewContentRow = ViewContentRow({
      'content_id': widget.recording.contentId,
      'title': widget.recording.title,
      'description': widget.recording.description,
      'authors_names': widget.recording.authorsNames,
      'midia_type': widget.recording.midiaType,
      'audio_url': widget.recording.audioUrl,
      'midia_file_url': widget.recording.midiaFileUrl,
      'cott_event_id': widget.recording.cottEventId,
      'event_name': widget.recording.eventName,
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
              contentId: widget.recording.contentId!,
              viewContentRow: viewContentRow,
            ),
          ),
        );
      },
    );

    // Após fechar o modal, verificar se ainda está favoritado
    if (mounted && currentUserId.isNotEmpty) {
      final isFavorite = await repository.isFavorite(
        authUserId: currentUserId,
        contentType: FavoritesRepository.typeRecording,
        contentId: widget.recording.contentId!,
      );

      // Se foi desfavoritado no modal, remover da lista
      if (!isFavorite && mounted) {
        widget.onUnfavorite?.call();
      } else if (mounted) {
        // Apenas atualizar o ícone se ainda estiver favoritado
        setState(() {
          _favoriteVersion++;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 6.0, 16.0, 6.0),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => _openContent(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12.0),
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              Text(
                valueOrDefault<String>(widget.recording.title, 'Title'),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).learn.contentTitle.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 4.0),
              // Autor
              Text(
                widget.recording.authorsNames.join(', '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).learn.metadata.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 12.0,
                    ),
              ),
              const SizedBox(height: 6.0),
              // Descrição
              Text(
                valueOrDefault<String>(widget.recording.description, '').maybeHandleOverflow(
                  maxChars: 120,
                  replacement: '…',
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.of(context).learn.bodyLight.override(
                      color: AppTheme.of(context).secondary,
                      fontSize: 12.0,
                    ),
              ),
              const SizedBox(height: 10.0),
              // Tags de mídia + Favorito
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tags de tipo de mídia
                  Expanded(
                    child: Wrap(
                      spacing: 6.0,
                      runSpacing: 4.0,
                      children: _buildMediaTags(context),
                    ),
                  ),
                  // Favorito
                  if (context.currentUserIdOrEmpty.isNotEmpty && widget.recording.contentId != null)
                    FavoriteButton(
                      key: ValueKey('favorite_${widget.recording.contentId}_$_favoriteVersion'),
                      contentType: FavoritesRepository.typeRecording,
                      contentId: widget.recording.contentId!,
                      authUserId: context.currentUserIdOrEmpty,
                      size: 20.0,
                      initialIsFavorite: true,
                      onToggle: (isFavorite) {
                        if (!isFavorite && mounted) {
                          // Remove da lista quando desfavoritar
                          widget.onUnfavorite?.call();
                        }
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildMediaTags(BuildContext context) {
    final tags = <Widget>[];

    // Tag baseada no midiaType
    if (widget.recording.midiaType == 'audio') {
      tags.add(_MediaTypeTag(label: 'Audio', context: context));
    } else if (widget.recording.midiaType == 'video') {
      tags.add(_MediaTypeTag(label: 'Video', context: context));
    } else if (widget.recording.midiaType == 'text') {
      tags.add(_MediaTypeTag(label: 'Text', context: context));
    }

    return tags;
  }
}

class _MediaTypeTag extends StatelessWidget {
  const _MediaTypeTag({
    required this.label,
    required this.context,
  });

  final String label;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: AppTheme.of(context).primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppTheme.of(context).primary,
          fontSize: 11.0,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

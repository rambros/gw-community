import 'package:flutter/material.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/content_view/content_view_page.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/ui/learn/widgets/group_link_sheet.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:provider/provider.dart';

class ContentCard extends StatefulWidget {
  const ContentCard({
    super.key,
    required this.contentRow,
    this.librarySection,
  });

  final ViewContentRow contentRow;
  final LibraryContentSection? librarySection;

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  int _favoriteVersion = 0;

  void _openContent(BuildContext context) {
    if (widget.contentRow.contentId == null) return;
    context.pushNamed(
      ContentViewPage.routeName,
      queryParameters:
          {'id': widget.contentRow.contentId.toString()}.withoutNulls,
      extra: {
        'previewRow': widget.contentRow,
        if (widget.librarySection != null)
          'librarySection': widget.librarySection!.name,
      },
    ).then((_) {
      if (mounted) setState(() => _favoriteVersion++);
    });
  }

  String _formatEventLine(BuildContext context) {
    final isMessage = isMessageContentType(widget.contentRow.contentTypeId);
    if (isMessage) {
      final year = widget.contentRow.yearPublished?.toInt();
      return year != null
          ? context.l10n.messageYear('$year')
          : context.l10n.portalMessages;
    }

    return widget.contentRow.eventName ?? '';
  }

  String _formatAuthorsLine(BuildContext context) {
    final authors = widget.contentRow.authorsNames.join(', ');
    if (isMessageContentType(widget.contentRow.contentTypeId)) {
      return authors.isNotEmpty ? context.l10n.fromAuthors(authors) : '';
    }

    final date = widget.contentRow.datePublished;
    final formattedDate =
        date != null ? DateFormat('M/d/yyyy').format(date) : '';
    if (formattedDate.isNotEmpty && authors.isNotEmpty)
      return '$formattedDate - $authors';
    if (formattedDate.isNotEmpty) return formattedDate;
    return authors;
  }

  Widget _mediaIcon(BuildContext context) {
    final type = (widget.contentRow.midiaType ?? '').toLowerCase();
    if (type.contains('audio')) {
      return Icon(Icons.headphones_outlined,
          color: AppTheme.of(context).primary, size: 24);
    }
    if (type.contains('video')) {
      return Icon(Icons.ondemand_video,
          color: AppTheme.of(context).primary, size: 24);
    }
    if (type.contains('text')) {
      return Icon(Icons.article_outlined,
          color: AppTheme.of(context).primary, size: 24);
    }
    return Icon(Icons.help_outline,
        color: AppTheme.of(context).primary, size: 22);
  }

  Widget? _favoriteButton() {
    if (context.currentUserIdOrEmpty.isEmpty ||
        widget.contentRow.contentId == null) {
      return null;
    }
    return FavoriteButton(
      key:
          ValueKey('favorite_${widget.contentRow.contentId}_$_favoriteVersion'),
      contentType: FavoritesRepository.typeRecording,
      contentId: widget.contentRow.contentId!,
      authUserId: context.currentUserIdOrEmpty,
      size: 20,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    final appState = context.watch<FFAppState>();
    final canLink = context.currentUserIdOrEmpty.isNotEmpty &&
        appState.loginUser.roles.hasAdminOrGroupManager &&
        widget.contentRow.contentId != null;
    final eventLine = _formatEventLine(context);
    final authorsLine = _formatAuthorsLine(context);

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 12.0),
      child: Container(
        width: double.infinity,
        decoration: portalCardDecoration(context),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(12.0),
            onTap: () => _openContent(context),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 14.0, 12.0, 14.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          valueOrDefault<String>(
                              widget.contentRow.title, context.l10n.untitled),
                          style: theme.titleMedium.override(
                            color: theme.secondary,
                            fontSize: 16.0,
                          ),
                        ),
                      ),
                      if (canLink)
                        _ActionsMenu(
                          onLinkToGroups: () =>
                              showGroupLinkSheet(context, widget.contentRow),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (eventLine.isNotEmpty)
                              Text(
                                eventLine,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodySmall.override(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            if (authorsLine.isNotEmpty) ...[
                              if (eventLine.isNotEmpty)
                                const SizedBox(height: 2),
                              Text(
                                authorsLine,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.bodySmall.override(
                                  color: theme.secondaryText,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _TrailingActions(
                        mediaIcon: _mediaIcon(context),
                        favorite: _favoriteButton(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TrailingActions extends StatelessWidget {
  const _TrailingActions({
    required this.mediaIcon,
    this.favorite,
  });

  final Widget mediaIcon;
  final Widget? favorite;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        mediaIcon,
        if (favorite != null) ...[
          const SizedBox(width: 10),
          favorite!,
        ],
      ],
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.onLinkToGroups});

  final VoidCallback onLinkToGroups;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      padding: EdgeInsets.zero,
      iconSize: 18,
      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(32, 32),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        visualDensity: VisualDensity.compact,
      ),
      icon: Icon(Icons.more_vert,
          size: 18, color: AppTheme.of(context).secondaryText),
      onSelected: (value) {
        if (value == 'link') onLinkToGroups();
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'link',
          child: Row(
            children: [
              const Icon(Icons.link, size: 18),
              const SizedBox(width: 10),
              Text(context.l10n.linkToGroups),
            ],
          ),
        ),
      ],
    );
  }
}

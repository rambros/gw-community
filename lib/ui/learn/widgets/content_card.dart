import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gw_community/data/models/enums/enums.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/data/services/supabase/supabase.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/favorite_button.dart';
import 'package:gw_community/ui/learn/content_view/content_view_page.dart';
import 'package:gw_community/ui/learn/utils/portal_content_mapper.dart';
import 'package:gw_community/ui/learn/widgets/group_link_sheet.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ContentCard extends StatefulWidget {
  const ContentCard({
    super.key,
    required this.contentRow,
  });

  final ViewContentRow contentRow;

  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  int _favoriteVersion = 0;

  void _openContent(BuildContext context) {
    if (widget.contentRow.contentId == null) return;
    context.pushNamed(
      ContentViewPage.routeName,
      queryParameters: {'id': widget.contentRow.contentId.toString()}.withoutNulls,
      extra: widget.contentRow,
    ).then((_) {
      if (mounted) setState(() => _favoriteVersion++);
    });
  }

  String _formatEventLine() {
    final isMessage = isMessageContentType(widget.contentRow.contentTypeId);
    if (isMessage) {
      final year = widget.contentRow.yearPublished?.toInt();
      return year != null ? 'Message - $year' : 'Message';
    }

    final eventName = widget.contentRow.eventName ?? '';
    final date = widget.contentRow.datePublished;
    if (date != null) {
      final monthYear = DateFormat('MMM/yyyy').format(date);
      if (eventName.isNotEmpty) return '$monthYear - $eventName';
      return monthYear;
    }
    return eventName;
  }

  String _formatAuthorsLine() {
    final authors = widget.contentRow.authorsNames.join(', ');
    if (isMessageContentType(widget.contentRow.contentTypeId)) {
      return authors.isNotEmpty ? 'From $authors' : '';
    }

    final date = widget.contentRow.datePublished;
    if (date != null) {
      final formatted = DateFormat('M/d/yyyy').format(date);
      if (authors.isNotEmpty) return '$formatted - $authors';
      return formatted;
    }
    return authors;
  }

  Widget _mediaIcon(BuildContext context) {
    final type = (widget.contentRow.midiaType ?? '').toLowerCase();
    if (type.contains('audio')) {
      return FaIcon(FontAwesomeIcons.music, color: AppTheme.of(context).primary, size: 22);
    }
    if (type.contains('video')) {
      return Icon(Icons.ondemand_video, color: AppTheme.of(context).primary, size: 24);
    }
    if (type.contains('text')) {
      return Icon(Icons.article_outlined, color: AppTheme.of(context).primary, size: 24);
    }
    return Icon(Icons.help_outline, color: AppTheme.of(context).primary, size: 22);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<FFAppState>();
    final canLink = context.currentUserIdOrEmpty.isNotEmpty &&
        appState.loginUser.roles.hasAdminOrGroupManager &&
        widget.contentRow.contentId != null;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16.0, 4.0, 16.0, 4.0),
      child: Material(
        color: Colors.transparent,
        elevation: 1.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: () => _openContent(context),
          child: Container(
            decoration: BoxDecoration(
              color: AppTheme.of(context).secondaryBackground,
              borderRadius: BorderRadius.circular(12.0),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              valueOrDefault<String>(widget.contentRow.title, context.l10n.untitled),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: AppTheme.of(context).bodyMedium.override(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                            ),
                          ),
                          if (canLink)
                            _ActionsMenu(
                              onLinkToGroups: () => showGroupLinkSheet(context, widget.contentRow),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatEventLine(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.of(context).bodySmall.override(fontSize: 13),
                      ),
                      if (_formatAuthorsLine().isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          _formatAuthorsLine(),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.of(context).bodySmall.override(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    _mediaIcon(context),
                    if (context.currentUserIdOrEmpty.isNotEmpty && widget.contentRow.contentId != null)
                      FavoriteButton(
                        key: ValueKey('favorite_${widget.contentRow.contentId}_$_favoriteVersion'),
                        contentType: FavoritesRepository.typeRecording,
                        contentId: widget.contentRow.contentId!,
                        authUserId: context.currentUserIdOrEmpty,
                        size: 18,
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionsMenu extends StatelessWidget {
  const _ActionsMenu({required this.onLinkToGroups});

  final VoidCallback onLinkToGroups;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, size: 18, color: AppTheme.of(context).secondaryText),
      padding: EdgeInsets.zero,
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

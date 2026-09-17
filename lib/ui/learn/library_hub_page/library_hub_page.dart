import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/screen_hint.dart';
import 'package:gw_community/ui/learn/learn_list_page/learn_list_page.dart';
import 'package:gw_community/ui/learn/library_hub_page/widgets/library_hub_card.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_page.dart';
import 'package:gw_community/ui/learn/portal_events/portal_events_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class LibraryHubPage extends StatelessWidget {
  const LibraryHubPage({super.key});

  static String routeName = 'libraryHubPage';
  static String routePath = '/libraryHubPage';

  void _openGlobalSearch(BuildContext context) {
    context.pushNamed(
      LearnListPage.routeName,
      queryParameters: {'autofocusSearch': 'true'}.withoutNulls,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        flexibleSpace: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0xFF73449B), Color(0xFF9A61B5)],
            ),
          ),
        ),
        automaticallyImplyLeading: false,
        title: Text(
          l10n.library,
          style: AppTheme.of(context).headlineMedium.override(
                color: Colors.white,
                fontSize: 20.0,
              ),
        ),
        centerTitle: true,
        elevation: 2.0,
      ),
      body: ScreenHint(
        hintKey: 'hint_library',
        title: l10n.libraryHintTitle,
        message: l10n.libraryHintMessage,
        pointerFraction: 0.3,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 0.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SearchField(onTap: () => _openGlobalSearch(context)),
                const SizedBox(height: 28.0),
                Expanded(child: _HubGrid(cards: _cards(context))),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<LibraryHubCardData> _cards(BuildContext context) {
    final l10n = context.l10n;
    return [
      LibraryHubCardData(
        title: l10n.portalDialoguesRetreats,
        glyph: LibraryHubGlyph.dialogues,
        gradient: const [Color(0xFF3B1468), Color(0xFF5C2A8A)],
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '1'}.withoutNulls,
        ),
      ),
      LibraryHubCardData(
        title: l10n.portalHeartToHeart,
        glyph: LibraryHubGlyph.heartToHeart,
        gradient: const [Color(0xFF6B3398), Color(0xFF8750B4)],
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '2'}.withoutNulls,
        ),
      ),
      LibraryHubCardData(
        title: l10n.portalDadiJanki,
        glyph: LibraryHubGlyph.dadiJanki,
        gradient: const [Color(0xFF8A55B8), Color(0xFFA072C8)],
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.dadiJanki.name}.withoutNulls,
        ),
      ),
      LibraryHubCardData(
        title: l10n.portalMeditations,
        glyph: LibraryHubGlyph.meditations,
        gradient: const [Color(0xFFB48AD4), Color(0xFFC9A8E0)],
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.meditations.name}.withoutNulls,
        ),
      ),
    ];
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme.of(context);
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AbsorbPointer(
        child: TextFormField(
          readOnly: true,
          canRequestFocus: false,
          decoration: InputDecoration(
            hintText: context.l10n.searchAllContent,
            hintStyle: theme.bodyMedium.override(
              color: theme.secondaryText,
            ),
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(Icons.search_rounded, color: theme.primary),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.alternate, width: 1.5),
              borderRadius: BorderRadius.circular(16.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: theme.primary, width: 1.5),
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
        ),
      ),
    );
  }
}

class _HubGrid extends StatelessWidget {
  const _HubGrid({required this.cards});

  final List<LibraryHubCardData> cards;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.only(bottom: 16.0),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 14.0,
        mainAxisSpacing: 14.0,
        childAspectRatio: 0.82,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) => LibraryHubCard(data: cards[index]),
    );
  }
}

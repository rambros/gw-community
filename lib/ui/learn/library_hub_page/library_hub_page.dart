import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/screen_hint.dart';
import 'package:gw_community/ui/learn/learn_list_page/learn_list_page.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_page.dart';
import 'package:gw_community/ui/learn/portal_events/portal_events_page.dart';
import 'package:gw_community/ui/learn/widgets/portal_search_bar.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class LibraryHubPage extends StatefulWidget {
  const LibraryHubPage({super.key});

  static String routeName = 'libraryHubPage';
  static String routePath = '/libraryHubPage';

  @override
  State<LibraryHubPage> createState() => _LibraryHubPageState();
}

class _LibraryHubPageState extends State<LibraryHubPage> {
  void _openGlobalSearch() {
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
            padding: const EdgeInsetsDirectional.fromSTEB(8.0, 16.0, 8.0, 0.0),
            child: Column(
              children: [
                _buildSearchField(context),
                Expanded(child: _buildGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 16.0),
      child: GestureDetector(
        onTap: _openGlobalSearch,
        behavior: HitTestBehavior.opaque,
        child: AbsorbPointer(
          child: TextFormField(
            readOnly: true,
            canRequestFocus: false,
            decoration: InputDecoration(
              hintText: context.l10n.searchAllContent,
              hintStyle: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              suffixIcon: Icon(Icons.search_rounded, color: AppTheme.of(context).primary),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.of(context).alternate, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: AppTheme.of(context).primary, width: 2.0),
                borderRadius: BorderRadius.circular(12.0),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    final theme = AppTheme.of(context);
    final cards = [
      _HubCardData(
        title: context.l10n.portalDialoguesRetreats,
        color: theme.secondary,
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '1'}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalHeartToHeart,
        color: GWPalette.rebeccaPurple,
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '2'}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalMessages,
        color: theme.primary,
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.messages.name}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalDadiJanki,
        color: Color.lerp(theme.primary, theme.alternate, 0.35)!,
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.dadiJanki.name}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalMeditations,
        color: Color.lerp(theme.primary, theme.alternate, 0.65)!,
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.meditations.name}.withoutNulls,
        ),
      ),
    ];

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
      clipBehavior: Clip.none,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16.0,
        mainAxisSpacing: 16.0,
        childAspectRatio: 1.8,
      ),
      itemCount: cards.length,
      itemBuilder: (context, index) {
        final card = cards[index];
        return _HubCard(data: card);
      },
    );
  }
}

class _HubCardData {
  const _HubCardData({
    required this.title,
    required this.color,
    required this.onTap,
  });

  final String title;
  final Color color;
  final VoidCallback onTap;
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.data});

  final _HubCardData data;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: portalCardDecoration(context, color: data.color),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12.0),
          onTap: data.onTap,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                data.title,
                textAlign: TextAlign.center,
                style: AppTheme.of(context).titleMedium.override(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

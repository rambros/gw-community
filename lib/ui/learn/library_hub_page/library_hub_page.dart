import 'package:flutter/material.dart';
import 'package:gw_community/l10n/l10n.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/widgets/screen_hint.dart';
import 'package:gw_community/ui/learn/learn_list_page/learn_list_page.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_kind.dart';
import 'package:gw_community/ui/learn/portal_catalog/portal_catalog_page.dart';
import 'package:gw_community/ui/learn/portal_events/portal_events_page.dart';
import 'package:gw_community/utils/flutter_flow_util.dart';

class LibraryHubPage extends StatefulWidget {
  const LibraryHubPage({super.key});

  static String routeName = 'libraryHubPage';
  static String routePath = '/libraryHubPage';

  @override
  State<LibraryHubPage> createState() => _LibraryHubPageState();
}

class _LibraryHubPageState extends State<LibraryHubPage> {
  final _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _searchFocusNode.addListener(_onSearchFocus);
  }

  void _onSearchFocus() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
      context.pushNamed(LearnListPage.routeName);
    }
  }

  @override
  void dispose() {
    _searchFocusNode.removeListener(_onSearchFocus);
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppTheme.of(context).secondaryBackground,
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
                _buildHeader(context),
                _buildSearchField(context),
                Expanded(child: _buildGrid(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 16.0),
      child: Text(
        context.l10n.portalHubTitle,
        textAlign: TextAlign.center,
        style: AppTheme.of(context).headlineSmall.override(
              color: AppTheme.of(context).primary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(8.0, 0.0, 8.0, 16.0),
      child: TextFormField(
        focusNode: _searchFocusNode,
        readOnly: true,
        onTap: () => context.pushNamed(LearnListPage.routeName),
        decoration: InputDecoration(
          labelText: context.l10n.searchAllContent,
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
    );
  }

  Widget _buildGrid(BuildContext context) {
    final cards = [
      _HubCardData(
        title: context.l10n.portalDialoguesRetreats,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFF48FB1)],
          begin: AlignmentDirectional(-1.0, -1.0),
          end: AlignmentDirectional(1.0, 1.0),
        ),
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '1'}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalHeartToHeart,
        gradient: const LinearGradient(
          colors: [Colors.red, Color(0xFFEF9A9A)],
          begin: AlignmentDirectional(1.0, -1.0),
          end: AlignmentDirectional(-1.0, 1.0),
        ),
        onTap: () => context.pushNamed(
          PortalEventsPage.routeName,
          queryParameters: {'dashboardGroupId': '2'}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalMessages,
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFFFCC80)],
          begin: AlignmentDirectional(-1.0, 1.0),
          end: AlignmentDirectional(1.0, -1.0),
        ),
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.messages.name}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalDadiJanki,
        gradient: const LinearGradient(
          colors: [Color(0xFFF9A825), Color(0xFFFFEE58)],
          begin: AlignmentDirectional(1.0, 1.0),
          end: AlignmentDirectional(-1.0, -1.0),
        ),
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.dadiJanki.name}.withoutNulls,
        ),
      ),
      _HubCardData(
        title: context.l10n.portalMeditations,
        gradient: const LinearGradient(
          colors: [Color(0xFFEC407A), Color(0xFFF48FB1)],
          begin: AlignmentDirectional(-1.0, -1.0),
          end: AlignmentDirectional(1.0, 1.0),
        ),
        onTap: () => context.pushNamed(
          PortalCatalogPage.routeName,
          queryParameters: {'kind': PortalCatalogKind.meditations.name}.withoutNulls,
        ),
      ),
    ];

    return GridView.builder(
      padding: EdgeInsets.zero,
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
    required this.gradient,
    required this.onTap,
  });

  final String title;
  final Gradient gradient;
  final VoidCallback onTap;
}

class _HubCard extends StatelessWidget {
  const _HubCard({required this.data});

  final _HubCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAliasWithSaveLayer,
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell(
        onTap: data.onTap,
        child: Ink(
          decoration: BoxDecoration(gradient: data.gradient),
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

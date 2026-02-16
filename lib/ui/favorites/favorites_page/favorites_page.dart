import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/favorites/favorites_page/view_model/favorites_view_model.dart';
import 'package:gw_community/ui/favorites/favorites_page/widgets/unified_favorite_card.dart';
import 'package:gw_community/utils/context_extensions.dart';
import 'package:provider/provider.dart';

/// Página de favoritos com abas para Recordings e Activities
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  static const String routeName = 'favoritesPage';
  static const String routePath = '/favorites';

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => FavoritesViewModel(
        repository: context.read<FavoritesRepository>(),
        currentUserId: context.currentUserIdOrEmpty,
      )..loadFavorites(),
      child: const _FavoritesPageContent(),
    );
  }
}

class _FavoritesPageContent extends StatelessWidget {
  const _FavoritesPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.of(context).primaryBackground,
      appBar: AppBar(
        backgroundColor: AppTheme.of(context).primary,
        automaticallyImplyLeading: false,
        leading: FlutterFlowIconButton(
          borderColor: Colors.transparent,
          borderRadius: 30.0,
          borderWidth: 1.0,
          buttonSize: 60.0,
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 30.0,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'My Favorites',
          style: GoogleFonts.lexendDeca(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
        centerTitle: true,
        elevation: 4.0,
      ),
      body: Consumer<FavoritesViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: AppTheme.of(context).primary,
              ),
            );
          }

          if (viewModel.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    color: AppTheme.of(context).error,
                    size: 48.0,
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    viewModel.errorMessage!,
                    style: AppTheme.of(context).bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    onPressed: () => viewModel.loadFavorites(),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return _buildUnifiedList(context, viewModel);
        },
      ),
    );
  }

  Widget _buildUnifiedList(BuildContext context, FavoritesViewModel viewModel) {
    if (viewModel.unifiedFavorites.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.favorite_border_outlined,
        message: 'No favorites yet',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: viewModel.unifiedFavorites.length,
        itemBuilder: (context, index) {
          final item = viewModel.unifiedFavorites[index];
          return UnifiedFavoriteCard(
            item: item,
            onUnfavorite: () {
              if (item.isRecording) {
                viewModel.removeRecordingFromFavorites(item.contentId);
              } else {
                viewModel.removeActivityFromFavorites(item.contentId);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context, {
    required IconData icon,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.of(context).secondaryText,
              size: 64.0,
            ),
            const SizedBox(height: 16.0),
            Text(
              message,
              style: AppTheme.of(context).headlineSmall.override(
                    color: AppTheme.of(context).primaryText,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8.0),
            RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                style: AppTheme.of(context).bodyMedium.override(
                      color: AppTheme.of(context).secondaryText,
                    ),
                children: [
                  const TextSpan(text: 'Tap '),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: Icon(
                      Icons.favorite_border_outlined,
                      color: AppTheme.of(context).secondaryText,
                      size: 16.0,
                    ),
                  ),
                  const TextSpan(text: ' throughout the app to collect your favorites'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

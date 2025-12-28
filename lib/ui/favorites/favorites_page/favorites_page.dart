import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/data/repositories/favorites_repository.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/core/ui/flutter_flow_icon_button.dart';
import 'package:gw_community/ui/favorites/favorites_page/view_model/favorites_view_model.dart';
import 'package:gw_community/ui/favorites/favorites_page/widgets/favorite_activity_card.dart';
import 'package:gw_community/ui/favorites/favorites_page/widgets/favorite_recording_card.dart';
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
    return DefaultTabController(
      length: 2,
      child: Scaffold(
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
            'Favorites',
            style: GoogleFonts.lexendDeca(
              color: Colors.white,
              fontSize: 20.0,
            ),
          ),
          centerTitle: true,
          elevation: 4.0,
          bottom: TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 3.0,
            labelStyle: GoogleFonts.lexendDeca(
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.lexendDeca(
              fontWeight: FontWeight.normal,
            ),
            tabs: const [
              Tab(text: 'Recordings'),
              Tab(text: 'Activities'),
            ],
          ),
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

            return TabBarView(
              children: [
                // Recordings tab
                _buildRecordingsList(context, viewModel),
                // Activities tab
                _buildActivitiesList(context, viewModel),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRecordingsList(
      BuildContext context, FavoritesViewModel viewModel) {
    if (viewModel.favoriteRecordings.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.audiotrack_outlined,
        message: 'No favorite recordings yet',
        subtitle: 'Tap the heart icon on any recording to add it here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: viewModel.favoriteRecordings.length,
        itemBuilder: (context, index) {
          final recording = viewModel.favoriteRecordings[index];
          return FavoriteRecordingCard(
            recording: recording,
            onUnfavorite: () {
              if (recording.contentId != null) {
                viewModel.removeRecordingFromFavorites(recording.contentId!);
              }
            },
          );
        },
      ),
    );
  }

  Widget _buildActivitiesList(
      BuildContext context, FavoritesViewModel viewModel) {
    if (viewModel.favoriteActivities.isEmpty) {
      return _buildEmptyState(
        context,
        icon: Icons.assignment_outlined,
        message: 'No favorite activities yet',
        subtitle: 'Tap the heart icon on any activity to add it here',
      );
    }

    return RefreshIndicator(
      onRefresh: () => viewModel.loadFavorites(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        itemCount: viewModel.favoriteActivities.length,
        itemBuilder: (context, index) {
          final activity = viewModel.favoriteActivities[index];
          return FavoriteActivityCard(
            activity: activity,
            onUnfavorite: () {
              viewModel.removeActivityFromFavorites(activity.id);
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
    required String subtitle,
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
            Text(
              subtitle,
              style: AppTheme.of(context).bodyMedium.override(
                    color: AppTheme.of(context).secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

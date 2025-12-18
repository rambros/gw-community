import '/ui/core/themes/app_theme.dart';
import 'community_typography.dart';

/// Extension to access Community-specific typography through AppTheme
///
/// Usage example:
/// ```dart
/// Text(
///   'Event Title',
///   style: AppTheme.of(context).community.cardTitle,
/// )
/// ```
extension CommunityThemeExtension on AppTheme {
  /// Access community-specific typography
  CommunityTypography get community => CommunityTypography(this);
}

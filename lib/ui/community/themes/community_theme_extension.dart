import 'package:gw_community/ui/community/themes/community_typography.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

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

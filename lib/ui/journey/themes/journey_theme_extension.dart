import 'package:gw_community/ui/core/themes/app_theme.dart';
import 'package:gw_community/ui/journey/themes/journey_typography.dart';

/// Extension to access Journey-specific typography through AppTheme
///
/// Usage example:
/// ```dart
/// Text(
///   'Journey Title',
///   style: AppTheme.of(context).journey.stepTitle,
/// )
/// ```
extension JourneyThemeExtension on AppTheme {
  /// Access journey-specific typography
  JourneyTypography get journey => JourneyTypography(this);
}

import '/ui/core/themes/app_theme.dart';
import 'learn_typography.dart';

/// Extension to access Learn-specific typography through AppTheme
///
/// Usage example:
/// ```dart
/// Text(
///   'Content Title',
///   style: AppTheme.of(context).learn.contentTitle,
/// )
/// ```
extension LearnThemeExtension on AppTheme {
  /// Access learn-specific typography
  LearnTypography get learn => LearnTypography(this);
}

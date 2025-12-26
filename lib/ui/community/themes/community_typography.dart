import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Community module typography system
/// Uses Cormorant Garamond for titles/headings and Nunito for body text
/// Provides consistent text styles across all community components
class CommunityTypography {
  final AppTheme theme;

  CommunityTypography(this.theme);

  // ==================== TITLES / HEADINGS (Cormorant Garamond) ====================

  /// Page titles - Used in AppBar titles
  /// Font: Cormorant Garamond, Size: 24px, Weight: 600
  TextStyle get pageTitle => theme.titleLarge.override(
        font: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w600,
        ),
        fontSize: 24.0,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w600,
      );

  /// Section titles - Used for major sections and card headers
  /// Font: Cormorant Garamond, Size: 20px, Weight: 500
  TextStyle get sectionTitle => theme.titleMedium.override(
        font: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 20.0,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
      );

  /// Card title - Used in event cards, group cards, sharing cards
  /// Font: Cormorant Garamond, Size: 18px, Weight: 500
  TextStyle get cardTitle => theme.titleMedium.override(
        font: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 18.0,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
      );

  /// User name - Used for display names in cards and headers
  /// Font: Cormorant Garamond, Size: 16px, Weight: 500
  TextStyle get userName => theme.bodyLarge.override(
        font: GoogleFonts.cormorantGaramond(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      );

  // ==================== BODY TEXT (Nunito) ====================

  /// Body text - Standard content text
  /// Font: Nunito, Size: 16px, Weight: 400
  TextStyle get bodyText => theme.bodyMedium.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 16.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
      );

  /// Body small - Secondary content and descriptions
  /// Font: Nunito, Size: 14px, Weight: 400
  TextStyle get bodySmall => theme.bodyMedium.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 14.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w400,
      );

  /// Metadata - Dates, times, facilitators, group info
  /// Font: Nunito, Size: 13px, Weight: 400
  TextStyle get metadata => theme.bodySmall.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 13.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      );

  /// Caption - Small informational text, visibility badges
  /// Font: Nunito, Size: 12px, Weight: 400
  TextStyle get caption => theme.bodySmall.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 12.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      );

  // ==================== FORMS (Nunito) ====================

  /// Input label - Form field labels
  /// Font: Nunito, Size: 16px, Weight: 500
  TextStyle get inputLabel => theme.labelLarge.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      );

  /// Input hint - Placeholder text in form fields
  /// Font: Nunito, Size: 14px, Weight: 400
  TextStyle get inputHint => theme.bodySmall.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 14.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      );

  // ==================== BUTTONS (Nunito) ====================

  /// Button text - Primary and secondary buttons
  /// Font: Nunito, Size: 16px, Weight: 500
  TextStyle get buttonText => theme.labelLarge.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      );

  /// Small button text - Compact buttons
  /// Font: Nunito, Size: 14px, Weight: 500
  TextStyle get buttonSmall => theme.labelMedium.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 14.0,
        letterSpacing: 0.3,
        fontWeight: FontWeight.w500,
      );

  // ==================== COMMENTS (Nunito) ====================

  /// Comment author - User name in comments
  /// Font: Nunito, Size: 14px, Weight: 600
  TextStyle get commentAuthor => theme.bodyMedium.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w600,
        ),
        fontSize: 14.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w600,
      );

  /// Comment content - Comment text body
  /// Font: Nunito, Size: 14px, Weight: 400
  TextStyle get commentContent => theme.bodyMedium.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 14.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      );

  /// Comment timestamp - Time metadata in comments
  /// Font: Nunito, Size: 12px, Weight: 400
  TextStyle get commentTimestamp => theme.bodySmall.override(
        font: GoogleFonts.nunito(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 12.0,
        letterSpacing: 0.2,
        fontWeight: FontWeight.w400,
      );

  // ==================== COLOR VARIANTS ====================
  // Helper methods to apply common color overrides

  /// Returns the style with primary text color
  TextStyle withPrimaryColor(TextStyle style) => style.override(
        color: theme.primaryText,
      );

  /// Returns the style with secondary text color
  TextStyle withSecondaryColor(TextStyle style) => style.override(
        color: theme.secondary,
      );

  /// Returns the style with tertiary text color
  TextStyle withTertiaryColor(TextStyle style) => style.override(
        color: theme.tertiary,
      );

  /// Returns the style with alternate text color (for disabled/inactive states)
  TextStyle withAlternateColor(TextStyle style) => style.override(
        color: theme.alternate,
      );

  /// Returns the style with error text color
  TextStyle withErrorColor(TextStyle style) => style.override(
        color: theme.error,
      );

  /// Returns the style with primary background color (white text)
  TextStyle withPrimaryBackgroundColor(TextStyle style) => style.override(
        color: theme.primaryBackground,
      );

  /// Returns the style with custom color
  TextStyle withColor(TextStyle style, Color color) => style.override(
        color: color,
      );
}

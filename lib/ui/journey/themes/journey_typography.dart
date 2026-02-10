import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Journey module typography system
/// Uses LexendDeca for titles/headings and body text
/// Fontes Originais - Padrão do projeto antes da migração
/// Provides consistent text styles across all journey components
class JourneyTypography {
  final AppTheme theme;

  JourneyTypography(this.theme);

  // ==================== TITLES / HEADINGS (LexendDeca) ====================

  /// Page titles - Used in main journey pages
  /// Font: LexendDeca, Size: 28px, Weight: 500
  TextStyle get pageTitle => theme.titleLarge.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 20.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Section titles - Used for sections within pages
  /// Font: LexendDeca, Size: 22px, Weight: 500
  TextStyle get sectionTitle => theme.titleMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 22.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Step title - Used in step list items and step details
  /// Font: LexendDeca, Size: 18px, Weight: 500
  TextStyle get stepTitle => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 18.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Card title - Used in journey cards
  /// Font: LexendDeca, Size: 18px, Weight: 500
  TextStyle get cardTitle => theme.titleMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 18.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  // ==================== BODY TEXT (LexendDeca) ====================

  /// Body text - Standard text content
  /// Font: LexendDeca, Size: 16px, Weight: 400
  TextStyle get bodyText => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 16.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  /// Step description - Descriptions in step list items
  /// Font: LexendDeca, Size: 14px, Weight: 300
  TextStyle get stepDescription => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w300,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w300,
      );

  /// Caption - Metadata, timestamps, small info
  /// Font: LexendDeca, Size: 13px, Weight: 400
  TextStyle get caption => theme.bodySmall.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 13.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  /// Small caption - Very small text, labels
  /// Font: LexendDeca, Size: 12px, Weight: 400
  TextStyle get captionSmall => theme.bodySmall.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 12.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  // ==================== BUTTONS (Poppins) ====================

  /// Button text - Primary buttons
  /// Font: Poppins, Size: 16px, Weight: 500
  TextStyle get buttonText => theme.labelLarge.override(
        font: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Small button text - Secondary/small buttons
  /// Font: Poppins, Size: 14px, Weight: 500
  TextStyle get buttonSmall => theme.labelMedium.override(
        font: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  // ==================== SPECIAL ELEMENTS (LexendDeca) ====================

  /// Step number - Numbers in step indicators/badges
  /// Font: LexendDeca, Size: 14px, Weight: 600
  TextStyle get stepNumber => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w600,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
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

  /// Returns the style with custom color
  TextStyle withColor(TextStyle style, Color color) => style.override(
        color: color,
      );
}

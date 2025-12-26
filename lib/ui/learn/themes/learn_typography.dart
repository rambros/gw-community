import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:gw_community/ui/core/themes/app_theme.dart';

/// Library module typography system
/// Uses LexendDeca for titles/headings and body text
/// Fontes Originais - Padrão do projeto antes da migração
/// Provides consistent text styles across all library components
class LearnTypography {
  final AppTheme theme;

  LearnTypography(this.theme);

  // ==================== TITLES / HEADINGS (LexendDeca) ====================

  /// Page title - Used in AppBar
  /// Font: LexendDeca, Size: 24px, Weight: 500
  TextStyle get pageTitle => theme.headlineMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 24.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Section header - Used for major sections like "Portal Content Library"
  /// Font: LexendDeca, Size: 20px, Weight: 500
  TextStyle get sectionHeader => theme.headlineMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 20.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Content title - Used for content names in cards and modal
  /// Font: LexendDeca, Size: 18px, Weight: 500
  TextStyle get contentTitle => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 18.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Modal title - Emphasized content title in modal view
  /// Font: LexendDeca, Size: 18px, Weight: 600
  TextStyle get modalTitle => theme.bodyLarge.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w600,
        ),
        fontSize: 18.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w600,
      );

  /// List header - Used for "List of Contents" headers
  /// Font: LexendDeca, Size: 16px, Weight: 500
  TextStyle get listHeader => theme.labelLarge.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  // ==================== BODY TEXT (LexendDeca) ====================

  /// Body text - Standard content descriptions
  /// Font: LexendDeca, Size: 14px, Weight: 400
  TextStyle get bodyText => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  /// Body light - Long descriptions with lighter weight
  /// Font: LexendDeca, Size: 14px, Weight: 300
  TextStyle get bodyLight => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w300,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w300,
      );

  /// Metadata - Authors, event names, contextual info
  /// Font: LexendDeca, Size: 12px, Weight: 400
  TextStyle get metadata => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 12.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  /// Caption - Filter descriptions, hints
  /// Font: LexendDeca, Size: 12px, Weight: 400
  TextStyle get caption => theme.labelLarge.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 12.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w400,
      );

  // ==================== BUTTONS & LABELS (Poppins) ====================

  /// Button text - Primary action buttons
  /// Font: Poppins, Size: 16px, Weight: 500
  TextStyle get buttonText => theme.labelLarge.override(
        font: GoogleFonts.poppins(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 16.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  /// Filter label - Filter section headers
  /// Font: LexendDeca, Size: 14px, Weight: 500
  TextStyle get filterLabel => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w500,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
        fontWeight: FontWeight.w500,
      );

  // ==================== SPECIAL ELEMENTS (LexendDeca) ====================

  /// Separator text - Small connecting text like "or"
  /// Font: LexendDeca, Size: 14px, Weight: 400
  TextStyle get separatorText => theme.bodyMedium.override(
        font: GoogleFonts.lexendDeca(
          fontWeight: FontWeight.w400,
        ),
        fontSize: 14.0,
        letterSpacing: 0.0,
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

  /// Returns the style with primary background color (white text)
  TextStyle withPrimaryBackgroundColor(TextStyle style) => style.override(
        color: theme.primaryBackground,
      );

  /// Returns the style with white color
  TextStyle withWhiteColor(TextStyle style) => style.override(
        color: Colors.white,
      );

  /// Returns the style with custom color
  TextStyle withColor(TextStyle style, Color color) => style.override(
        color: color,
      );
}

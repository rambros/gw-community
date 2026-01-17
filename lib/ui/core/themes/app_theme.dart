import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ===========================================================================
// GW PALETTE - Single Source of Truth for Colors
// ===========================================================================
class GWPalette {
  // Brand Colors
  static const Color purplePrimary = Color(0xFF7C52A0);
  static const Color purpleSecondary = Color(0xFF340964);
  static const Color yellowTertiary = Color(0xFFFCC612);
  static const Color lilacAlternate = Color(0xFFB9A0CB);

  // Text Colors
  static const Color textPrimary = Color(0xFFF5F5F6); // Off-white
  static const Color textSecondary = Color(0xFF57636C); // Slate Gray
  static const Color textDark = Color(0xFF1E2429); // Dark text for light backgrounds

  // Background Colors
  static const Color bgPrimary = Color(0xFFF9FAFB);
  static const Color bgSecondary = Color(0xFFE1E2E1);

  // Status Colors
  static const Color success = Color(0xFF04A24C);
  static const Color warning = Color(0xFFFCDC0C);
  static const Color error = Color(0xFFE21C3D);
  static const Color info = Color(0xFEFFFFFF); // Almost white

  // Accents / Grays
  static const Color gray1 = Color(0xFF616161);
  static const Color gray2 = Color(0xFF757575);
  static const Color gray3 = Color(0xFFE0E0E0);
  static const Color gray4 = Color(0xFFEEEEEE);

  // Misc / Legacy
  static const Color rebeccaPurple = Color(0xFF633693);
  static const Color copperRed = Color(0xFFD66853);
  static const Color orangeYellow = Color(0xFFFFD971);
  static const Color cadetGrey = Color(0xFF97A7B3);
  static const Color beauBlue = Color(0xFFC1CFDA);
  static const Color black = Color(0xFF000000); // Was named 'transparent'
  static const Color grayIcon = Color(0xFF95A1AC);
  static const Color gray200 = Color(0xFFDBE2E7);
  static const Color gray600 = Color(0xFF262D34);
  static const Color black600 = Color(0xFF090F13);
  static const Color teal = Color(0xFF39D2C0);
}

// ===========================================================================
// APP THEME
// ===========================================================================

abstract class AppTheme {
  static AppTheme of(BuildContext context) {
    return LightModeTheme();
  }

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color rebeccaPurple;
  late Color copperRed;
  late Color orangeYellowCrayola;
  late Color cadetGrey;
  late Color beauBlue;
  late Color transparent;
  late Color grayIcon;
  late Color gray200;
  late Color gray600;
  late Color black600;
  late Color tertiary400;
  late Color textColor;

  String get displayLargeFamily => typography.displayLargeFamily;
  bool get displayLargeIsCustom => typography.displayLargeIsCustom;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  bool get displayMediumIsCustom => typography.displayMediumIsCustom;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  bool get displaySmallIsCustom => typography.displaySmallIsCustom;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  bool get headlineLargeIsCustom => typography.headlineLargeIsCustom;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  bool get headlineMediumIsCustom => typography.headlineMediumIsCustom;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  bool get headlineSmallIsCustom => typography.headlineSmallIsCustom;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  bool get titleLargeIsCustom => typography.titleLargeIsCustom;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  bool get titleMediumIsCustom => typography.titleMediumIsCustom;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  bool get titleSmallIsCustom => typography.titleSmallIsCustom;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  bool get labelLargeIsCustom => typography.labelLargeIsCustom;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  bool get labelMediumIsCustom => typography.labelMediumIsCustom;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  bool get labelSmallIsCustom => typography.labelSmallIsCustom;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  bool get bodyLargeIsCustom => typography.bodyLargeIsCustom;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  bool get bodyMediumIsCustom => typography.bodyMediumIsCustom;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  bool get bodySmallIsCustom => typography.bodySmallIsCustom;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends AppTheme {
  late Color primary = GWPalette.purplePrimary;
  late Color secondary = GWPalette.purpleSecondary;
  late Color tertiary = GWPalette.yellowTertiary;
  late Color alternate = GWPalette.lilacAlternate;
  late Color primaryText = GWPalette.textPrimary;
  late Color secondaryText = GWPalette.textSecondary;
  late Color primaryBackground = GWPalette.bgPrimary;
  late Color secondaryBackground = GWPalette.bgSecondary;
  late Color accent1 = GWPalette.gray1;
  late Color accent2 = GWPalette.gray2;
  late Color accent3 = GWPalette.gray3;
  late Color accent4 = GWPalette.gray4;
  late Color success = GWPalette.success;
  late Color warning = GWPalette.warning;
  late Color error = GWPalette.error;
  late Color info = GWPalette.info;

  late Color rebeccaPurple = GWPalette.rebeccaPurple;
  late Color copperRed = GWPalette.copperRed;
  late Color orangeYellowCrayola = GWPalette.orangeYellow;
  late Color cadetGrey = GWPalette.cadetGrey;
  late Color beauBlue = GWPalette.beauBlue;
  late Color transparent = GWPalette.black; // Kept as 'transparent' for compatibility, but mapped to Black
  late Color grayIcon = GWPalette.grayIcon;
  late Color gray200 = GWPalette.gray200;
  late Color gray600 = GWPalette.gray600;
  late Color black600 = GWPalette.black600;
  late Color tertiary400 = GWPalette.teal;
  late Color textColor = GWPalette.textDark;
}

abstract class Typography {
  String get displayLargeFamily;
  bool get displayLargeIsCustom;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  bool get displayMediumIsCustom;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  bool get displaySmallIsCustom;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  bool get headlineLargeIsCustom;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  bool get headlineMediumIsCustom;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  bool get headlineSmallIsCustom;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  bool get titleLargeIsCustom;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  bool get titleMediumIsCustom;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  bool get titleSmallIsCustom;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  bool get labelLargeIsCustom;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  bool get labelMediumIsCustom;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  bool get labelSmallIsCustom;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  bool get bodyLargeIsCustom;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  bool get bodyMediumIsCustom;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  bool get bodySmallIsCustom;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final AppTheme theme;

  String get displayLargeFamily => 'Poppins';
  bool get displayLargeIsCustom => false;
  TextStyle get displayLarge => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 57.0,
      );
  String get displayMediumFamily => 'Poppins';
  bool get displayMediumIsCustom => false;
  TextStyle get displayMedium => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 45.0,
      );
  String get displaySmallFamily => 'Lexend Deca';
  bool get displaySmallIsCustom => false;
  TextStyle get displaySmall => GoogleFonts.lexendDeca(
        color: theme.secondary, // Dynamic
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
      );
  String get headlineLargeFamily => 'Poppins';
  bool get headlineLargeIsCustom => false;
  TextStyle get headlineLarge => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 32.0,
      );
  String get headlineMediumFamily => 'Lexend Deca';
  bool get headlineMediumIsCustom => false;
  TextStyle get headlineMedium => GoogleFonts.lexendDeca(
        color: theme.secondary, // Dynamic
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
      );
  String get headlineSmallFamily => 'Lexend Deca';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.lexendDeca(
        color: theme.secondary, // Dynamic
        fontWeight: FontWeight.w500,
        fontSize: 20.0,
      );
  String get titleLargeFamily => 'Poppins';
  bool get titleLargeIsCustom => false;
  TextStyle get titleLarge => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 22.0,
      );
  String get titleMediumFamily => 'Lexend Deca';
  bool get titleMediumIsCustom => false;
  TextStyle get titleMedium => GoogleFonts.lexendDeca(
        color: theme.grayIcon, // Dynamic
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Lexend Deca';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.lexendDeca(
        color: theme.secondary, // Dynamic
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );
  String get labelLargeFamily => 'Poppins';
  bool get labelLargeIsCustom => false;
  TextStyle get labelLarge => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 14.0,
      );
  String get labelMediumFamily => 'Poppins';
  bool get labelMediumIsCustom => false;
  TextStyle get labelMedium => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 12.0,
      );
  String get labelSmallFamily => 'Poppins';
  bool get labelSmallIsCustom => false;
  TextStyle get labelSmall => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.w500,
        fontSize: 11.0,
      );
  String get bodyLargeFamily => 'Poppins';
  bool get bodyLargeIsCustom => false;
  TextStyle get bodyLarge => GoogleFonts.poppins(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
      );
  String get bodyMediumFamily => 'Lexend Deca';
  bool get bodyMediumIsCustom => false;
  TextStyle get bodyMedium => GoogleFonts.lexendDeca(
        color: theme.grayIcon, // Dynamic
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Lexend Deca';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.lexendDeca(
        color: theme.secondary, // Dynamic
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight, fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            shadows: shadows,
          );
  }
}

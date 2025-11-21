// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class FlutterFlowTheme {
  static FlutterFlowTheme of(BuildContext context) {
    return LightModeTheme();
  }

  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

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

  @Deprecated('Use displaySmallFamily instead')
  String get title1Family => displaySmallFamily;
  @Deprecated('Use displaySmall instead')
  TextStyle get title1 => typography.displaySmall;
  @Deprecated('Use headlineMediumFamily instead')
  String get title2Family => typography.headlineMediumFamily;
  @Deprecated('Use headlineMedium instead')
  TextStyle get title2 => typography.headlineMedium;
  @Deprecated('Use headlineSmallFamily instead')
  String get title3Family => typography.headlineSmallFamily;
  @Deprecated('Use headlineSmall instead')
  TextStyle get title3 => typography.headlineSmall;
  @Deprecated('Use titleMediumFamily instead')
  String get subtitle1Family => typography.titleMediumFamily;
  @Deprecated('Use titleMedium instead')
  TextStyle get subtitle1 => typography.titleMedium;
  @Deprecated('Use titleSmallFamily instead')
  String get subtitle2Family => typography.titleSmallFamily;
  @Deprecated('Use titleSmall instead')
  TextStyle get subtitle2 => typography.titleSmall;
  @Deprecated('Use bodyMediumFamily instead')
  String get bodyText1Family => typography.bodyMediumFamily;
  @Deprecated('Use bodyMedium instead')
  TextStyle get bodyText1 => typography.bodyMedium;
  @Deprecated('Use bodySmallFamily instead')
  String get bodyText2Family => typography.bodySmallFamily;
  @Deprecated('Use bodySmall instead')
  TextStyle get bodyText2 => typography.bodySmall;

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

class LightModeTheme extends FlutterFlowTheme {
  @Deprecated('Use primary instead')
  Color get primaryColor => primary;
  @Deprecated('Use secondary instead')
  Color get secondaryColor => secondary;
  @Deprecated('Use tertiary instead')
  Color get tertiaryColor => tertiary;

  late Color primary = const Color(0xFF7C52A0);
  late Color secondary = const Color(0xFF340964);
  late Color tertiary = const Color(0xFFFCC612);
  late Color alternate = const Color(0xFFB9A0CB);
  late Color primaryText = const Color(0xFFF5F5F6);
  late Color secondaryText = const Color(0x00000000);
  late Color primaryBackground = const Color(0xFFF9FAFB);
  late Color secondaryBackground = const Color(0xFFE1E2E1);
  late Color accent1 = const Color(0xFF616161);
  late Color accent2 = const Color(0xFF757575);
  late Color accent3 = const Color(0xFFE0E0E0);
  late Color accent4 = const Color(0xFFEEEEEE);
  late Color success = const Color(0xFF04A24C);
  late Color warning = const Color(0xFFFCDC0C);
  late Color error = const Color(0xFFE21C3D);
  late Color info = const Color(0xFEFFFFFF);

  late Color rebeccaPurple = const Color(0xFF633693);
  late Color copperRed = const Color(0xFFD66853);
  late Color orangeYellowCrayola = const Color(0xFFFFD971);
  late Color cadetGrey = const Color(0xFF97A7B3);
  late Color beauBlue = const Color(0xFFC1CFDA);
  late Color transparent = const Color(0xFF000000);
  late Color grayIcon = const Color(0xFF95A1AC);
  late Color gray200 = const Color(0xFFDBE2E7);
  late Color gray600 = const Color(0xFF262D34);
  late Color black600 = const Color(0xFF090F13);
  late Color tertiary400 = const Color(0xFF39D2C0);
  late Color textColor = const Color(0xFF1E2429);
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

  final FlutterFlowTheme theme;

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
        color: const Color(0xFF340964),
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
        color: const Color(0xFF340964),
        fontWeight: FontWeight.w500,
        fontSize: 24.0,
      );
  String get headlineSmallFamily => 'Lexend Deca';
  bool get headlineSmallIsCustom => false;
  TextStyle get headlineSmall => GoogleFonts.lexendDeca(
        color: const Color(0xFF340964),
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
        color: const Color(0xFF95A1AC),
        fontWeight: FontWeight.w500,
        fontSize: 18.0,
      );
  String get titleSmallFamily => 'Lexend Deca';
  bool get titleSmallIsCustom => false;
  TextStyle get titleSmall => GoogleFonts.lexendDeca(
        color: const Color(0xFF340964),
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
        color: const Color(0xFF95A1AC),
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
      );
  String get bodySmallFamily => 'Lexend Deca';
  bool get bodySmallIsCustom => false;
  TextStyle get bodySmall => GoogleFonts.lexendDeca(
        color: const Color(0xFF340964),
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
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
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

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const darkBase = Color(0xFF0A0806);
  static const darkSurface = Color(0xFF15120F);
  static const darkCard = Color(0xFF1F1B16);

  static const parchment = Color(0xFFEAE0D0);
  static const parchment90 = Color(0xFFE6D9C5);
  static const parchment70 = Color(0xFFCFBFA6);

  static const white = Colors.white;
  static const white90 = Color(0xE6FFFFFF);
  static const white70 = Color(0xB3FFFFFF);
  static const white40 = Color(0x66FFFFFF);
}

class AppTextStyles {
  static TextStyle displayLarge({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 54,
        fontWeight: FontWeight.w800,
        height: 0.92,
        letterSpacing: -1.2,
        color: color ?? AppColors.parchment,
      );

  static TextStyle displayMedium({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 38,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.parchment,
      );

  static TextStyle displaySmall({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 29,
        fontWeight: FontWeight.w700,
        color: color ?? AppColors.parchment,
      );

  static TextStyle storyBody({Color? color}) => GoogleFonts.playfairDisplay(
        fontSize: 19.5,
        height: 1.95,
        letterSpacing: -0.3,
        color: color ?? AppColors.parchment90,
      );

  static TextStyle label({Color? color, double? size}) => GoogleFonts.inter(
        fontSize: size ?? 14,
        color: color ?? AppColors.parchment70,
        fontWeight: FontWeight.w400,
      );

  static TextStyle labelMedium({Color? color, double? size}) =>
      GoogleFonts.inter(
        fontSize: size ?? 14,
        color: color ?? AppColors.parchment70,
        fontWeight: FontWeight.w500,
      );

  static TextStyle mono({Color? color, double? size}) => GoogleFonts.spaceMono(
        fontSize: size ?? 12,
        color: color ?? AppColors.parchment70,
        fontWeight: FontWeight.w700,
      );

  static TextStyle overline({Color? color}) => GoogleFonts.spaceMono(
        fontSize: 11,
        letterSpacing: 4,
        color: color ?? AppColors.parchment70.withValues(alpha: 0.6),
      );
}

class AppTheme {
  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.darkBase,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF9B8FFF),
          surface: AppColors.darkSurface,
        ),
      );
}

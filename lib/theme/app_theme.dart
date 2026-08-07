import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData get darkTheme {
    final baseTextTheme = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepMatteBlack,
      canvasColor: AppColors.deepMatteBlack,
      cardColor: AppColors.elevation1,
      primaryColor: AppColors.dropletRed,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.dropletRed,
        onPrimary: Colors.white,
        surface: AppColors.elevation1,
        onSurface: AppColors.primaryText,
        secondary: AppColors.nebulaCyan,
        onSecondary: Colors.black,
        tertiary: AppColors.nebulaViolet,
        surfaceContainerHighest: AppColors.elevation2,
        outline: AppColors.glassBorder,
      ),
      textTheme: baseTextTheme.copyWith(
        displayLarge: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontSize: 34,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.8,
        ),
        displayMedium: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontSize: 28,
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
        titleLarge: GoogleFonts.outfit(
          color: AppColors.primaryText,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        titleMedium: GoogleFonts.inter(
          color: AppColors.primaryText,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: GoogleFonts.inter(
          color: AppColors.primaryText,
          fontSize: 15,
          fontWeight: FontWeight.w400,
          height: 1.45,
        ),
        bodyMedium: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 13,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelSmall: GoogleFonts.inter(
          color: AppColors.secondaryText,
          fontSize: 11,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
        ),
      ),
      iconTheme: const IconThemeData(
        color: AppColors.primaryText,
        size: 22,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Voice Mode Lyric Styles matching design.md
  static TextStyle get activeLyricStyle => GoogleFonts.outfit(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.3,
        letterSpacing: -0.5,
        color: AppColors.highlightedLyric,
        shadows: [
          Shadow(
            color: AppColors.highlightedLyric.withValues(alpha: 0.6),
            blurRadius: 16,
          ),
        ],
      );

  static TextStyle get inactiveLyricStyle => GoogleFonts.outfit(
        fontSize: 22,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: AppColors.dimmedLyric,
      );
}

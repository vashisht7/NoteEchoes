import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  static ThemeData darkTheme(Color accent) {
    final baseTextTheme = GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.deepMatteBlack,
      canvasColor: AppColors.deepMatteBlack,
      cardColor: AppColors.elevation1,
      primaryColor: accent,
      colorScheme: ColorScheme.dark(
        primary: accent,
        onPrimary: Colors.white,
        surface: AppColors.elevation1,
        onSurface: AppColors.primaryText,
        secondary: accent,
        onSecondary: Colors.white,
        tertiary: accent,
        surfaceContainerHighest: AppColors.elevation2,
        outline: AppColors.glassBorder,
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: accent,
        selectionColor: accent.withValues(alpha: 0.26),
        selectionHandleColor: accent,
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
      iconTheme: const IconThemeData(color: AppColors.primaryText, size: 22),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.deepMatteBlack,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.primaryText,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.elevation1,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.elevation3,
        elevation: 12,
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentTextStyle: GoogleFonts.inter(
          color: AppColors.primaryText,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        actionTextColor: accent,
        disabledActionTextColor: const Color(0xFF8E8E93),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: false,
        fillColor: Colors.transparent,
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
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

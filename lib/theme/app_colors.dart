import 'package:flutter/material.dart';

class AppColors {
  // Logo-derived foundation: ink black, graphite and restrained crimson.
  static const Color deepMatteBlack = Color(0xFF050505);
  static const Color elevation1 = Color(0xFF101011);
  static const Color elevation2 = Color(0xFF181819);
  static const Color elevation3 = Color(0xFF222224);
  static const Color glassmorphicTint = Color(
    0x0DFFFFFF,
  ); // rgba(255, 255, 255, 0.05)
  static const Color glassBorder = Color(
    0x14FFFFFF,
  ); // rgba(255, 255, 255, 0.08)
  static const Color glassBorderBright = Color(
    0x33FFFFFF,
  ); // rgba(255, 255, 255, 0.20)

  // Voice & State Accents
  static const Color logoCrimson = Color(0xFFD7192D);
  static const Color logoCrimsonDeep = Color(0xFF8E1020);
  static const Color logoCrimsonSoft = Color(0x24D7192D);
  static const Color dropletRed = logoCrimson;
  static const Color dropletRedSoft = logoCrimsonSoft;
  static const Color dropletRedGlow = Color(0x38D7192D);

  // Legacy AI names now resolve to the logo palette so older surfaces remain
  // visually coherent while they are migrated to semantic theme colours.
  static const Color nebulaViolet = Color(0xFF6F0C18);
  static const Color nebulaCyan = logoCrimson;
  static const Color nebulaMagenta = Color(0xFFB51426);
  static const Color nebulaIndigo = Color(0xFF33070D);

  // Typography & Overlays
  static const Color primaryText = Color(0xFFF5F5F7); // 100% Opacity White
  static const Color secondaryText = Color(0xFF8E8E93); // 60% Opacity Muted
  static const Color tertiaryText = Color(0xFF636366); // 40% Opacity
  static const Color highlightedLyric = Color(
    0xFFFFFFFF,
  ); // Active Voice Text + Glow
  static const Color dimmedLyric = Color(0xFF48484A); // Past/Future Text

  // Badges & Tags
  static const Color badgePdf = Color(0xFFFF3B30);
  static const Color badgeTag = Color(0xFF2C2C34);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color accentOrange = Color(0xFFFF9F0A);
  static const Color accentPurple = Color(0xFFBF5AF2);
}

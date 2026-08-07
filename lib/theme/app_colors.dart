import 'package:flutter/material.dart';

class AppColors {
  // Base Backgrounds
  static const Color deepMatteBlack = Color(0xFF0A0A0C); // Primary Screen Canvas
  static const Color elevation1 = Color(0xFF141418); // Surface Tiles
  static const Color elevation2 = Color(0xFF1E1E24); // Search & Modals
  static const Color elevation3 = Color(0xFF282830); // Raised elements
  static const Color glassmorphicTint = Color(0x0DFFFFFF); // rgba(255, 255, 255, 0.05)
  static const Color glassBorder = Color(0x14FFFFFF); // rgba(255, 255, 255, 0.08)
  static const Color glassBorderBright = Color(0x33FFFFFF); // rgba(255, 255, 255, 0.20)

  // Voice & State Accents
  static const Color dropletRed = Color(0xFFFF2D55); // Mic / Ripple Active State
  static const Color dropletRedSoft = Color(0x40FF2D55); // rgba(255, 45, 85, 0.25)
  static const Color dropletRedGlow = Color(0x80FF2D55); // rgba(255, 45, 85, 0.50)

  // Nebula AI Gradients
  static const Color nebulaViolet = Color(0xFF7D2AE8); // AI Thinking Gradient A
  static const Color nebulaCyan = Color(0xFF00F2FE); // AI Thinking Gradient B
  static const Color nebulaMagenta = Color(0xFFFF0844); // AI Thinking Gradient C
  static const Color nebulaIndigo = Color(0xFF4A00E0); // AI Thinking Deep Indigo

  // Typography & Overlays
  static const Color primaryText = Color(0xFFF5F5F7); // 100% Opacity White
  static const Color secondaryText = Color(0xFF8E8E93); // 60% Opacity Muted
  static const Color tertiaryText = Color(0xFF636366); // 40% Opacity
  static const Color highlightedLyric = Color(0xFFFFFFFF); // Active Voice Text + Glow
  static const Color dimmedLyric = Color(0xFF48484A); // Past/Future Text

  // Badges & Tags
  static const Color badgePdf = Color(0xFFFF3B30);
  static const Color badgeTag = Color(0xFF2C2C34);
  static const Color accentGreen = Color(0xFF34C759);
  static const Color accentBlue = Color(0xFF0A84FF);
  static const Color accentOrange = Color(0xFFFF9F0A);
  static const Color accentPurple = Color(0xFFBF5AF2);
}

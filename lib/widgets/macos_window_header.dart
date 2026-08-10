import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MacOSWindowHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onLogoTap;

  const MacOSWindowHeader({
    super.key,
    this.title = "notechoes",
    this.trailing,
    this.onLogoTap,
  });

  bool get isDesktopPlatform {
    if (kIsWeb) return false;
    return Platform.isMacOS || Platform.isWindows || Platform.isLinux;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: isDesktopPlatform ? 14 : 6,
        bottom: 8,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          if (isDesktopPlatform) ...[
            // macOS Red, Yellow, Green Traffic Lights
            Row(
              children: [
                _buildTrafficDot(const Color(0xFFFF5F56)),
                const SizedBox(width: 8),
                _buildTrafficDot(const Color(0xFFFFBD2E)),
                const SizedBox(width: 8),
                _buildTrafficDot(const Color(0xFF27C93F)),
              ],
            ),
            const SizedBox(width: 16),
          ],

          // Blended NoteEchoes Logo Emblem
          GestureDetector(
            onTap: onLogoTap,
            child: Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(right: 10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.dropletRed.withValues(alpha: 0.6), width: 1.4),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.dropletRed.withValues(alpha: 0.35),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.asset(
                  "assets/images/notechoes_logo.png",
                  fit: BoxFit.cover,
                  errorBuilder: (context, err, stack) => const Icon(
                    Icons.auto_awesome,
                    color: AppColors.dropletRed,
                    size: 18,
                  ),
                ),
              ),
            ),
          ),

          // App Name: NoteEchoes (Single word, No space)
          Text(
            title,
            style: GoogleFonts.outfit(
              fontSize: 23,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),

          const Spacer(),

          ?trailing,
        ],
      ),
    );
  }

  Widget _buildTrafficDot(Color color) {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }
}

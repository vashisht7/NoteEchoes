import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';

class AuthSignInSheet extends StatelessWidget {
  final VoidCallback? onComplete;

  const AuthSignInSheet({super.key, this.onComplete});

  static Future<void> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const AuthSignInSheet(),
    );
  }

  void _signInWithProvider(BuildContext context, String provider, String email) {
    NoteService().signIn(email: email, provider: provider);
    Navigator.of(context).pop();
    onComplete?.call();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.elevation2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
            const SizedBox(width: 8),
            Text("Signed in with $provider ($email)"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.elevation1,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorderBright, width: 1.2),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.glassBorderBright,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // Blended Logo Emblem
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.dropletRed.withValues(alpha: 0.5), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.dropletRed.withValues(alpha: 0.35),
                      blurRadius: 20,
                      spreadRadius: 2,
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
                      size: 38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // App Name (No Space between Note and Echoes!)
              Text(
                "NoteEchoes",
                style: GoogleFonts.outfit(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 6),

              // Subtitle
              Text(
                "Your spatial voice & math-enabled second brain",
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 28),

              // Apple Sign In Button
              _buildAuthButton(
                icon: Icons.apple,
                label: "Sign in with Apple",
                backgroundColor: Colors.white,
                textColor: Colors.black,
                onTap: () => _signInWithProvider(context, "Apple ID", "user@icloud.com"),
              ),
              const SizedBox(height: 12),

              // Google Sign In Button
              _buildAuthButton(
                icon: Icons.g_mobiledata_rounded,
                label: "Sign in with Google",
                backgroundColor: AppColors.elevation2,
                textColor: Colors.white,
                iconColor: const Color(0xFF4285F4),
                border: Border.all(color: AppColors.glassBorderBright),
                onTap: () => _signInWithProvider(context, "Google", "user@gmail.com"),
              ),
              const SizedBox(height: 16),

              // Continue as Guest / Skip
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onComplete?.call();
                },
                child: Text(
                  "Continue without signing in",
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    color: AppColors.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAuthButton({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required Color textColor,
    Color? iconColor,
    BoxBorder? border,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 0,
          side: border is Border ? border.top : BorderSide.none,
        ),
        onPressed: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 22, color: iconColor ?? textColor),
            const SizedBox(width: 10),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

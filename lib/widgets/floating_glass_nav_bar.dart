import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';

class FloatingGlassNavBar extends StatelessWidget {
  final VoidCallback onAddNote;
  final VoidCallback onSearch;
  final VoidCallback onTranscribeVoice;
  final VoidCallback onDiscuss;
  final VoidCallback onSettings;
  final int selectedIndex;

  const FloatingGlassNavBar({
    super.key,
    required this.onAddNote,
    required this.onSearch,
    required this.onTranscribeVoice,
    required this.onDiscuss,
    required this.onSettings,
    this.selectedIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      height: 64,
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.elevation2.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(32),
                border: Border.all(
                  color: AppColors.glassBorderBright,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.65),
                    blurRadius: 28,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 1. [ + Add Note ] Button
                  _buildNavIconButton(
                    icon: Icons.add_rounded,
                    tooltip: "Add Note",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onAddNote();
                    },
                  ),

                  const SizedBox(width: 8),

                  // 2. [ 🔍 Search ] Button
                  _buildNavIconButton(
                    icon: Icons.search_rounded,
                    tooltip: "Search Notes",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSearch();
                    },
                  ),

                  const SizedBox(width: 10),

                  // 3. [ 🎙️ Live Transcribe Voice Note ] (Primary Accent Button)
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      onTranscribeVoice();
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.32),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 26,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  // 4. [ 💬 Discuss / Voice AI Chat ] Button
                  _buildNavIconButton(
                    icon: Icons.forum_rounded,
                    tooltip: "Discuss Notes",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onDiscuss();
                    },
                  ),

                  const SizedBox(width: 8),

                  // 5. [ ⚙️ Settings ] Button
                  _buildNavIconButton(
                    icon: Icons.settings_rounded,
                    tooltip: "Settings",
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onSettings();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.glassmorphicTint,
            ),
            child: Center(
              child: Icon(icon, color: AppColors.primaryText, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

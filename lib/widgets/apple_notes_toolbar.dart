import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class AppleNotesToolbar extends StatelessWidget {
  final VoidCallback onInsertTable;
  final VoidCallback onFormatText;
  final VoidCallback onInsertChecklist;
  final VoidCallback onAddAttachment;
  final VoidCallback onOpenDrawing;
  final VoidCallback onInsertMath;
  final VoidCallback onHideKeyboard;
  final bool isKeyboardVisible;

  const AppleNotesToolbar({
    super.key,
    required this.onInsertTable,
    required this.onFormatText,
    required this.onInsertChecklist,
    required this.onAddAttachment,
    required this.onOpenDrawing,
    required this.onInsertMath,
    required this.onHideKeyboard,
    this.isKeyboardVisible = false,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isKeyboardOpen = bottomInset > 0 || isKeyboardVisible;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22).withValues(alpha: 0.95),
        border: const Border(
          top: BorderSide(color: Color(0xFF32323A), width: 0.8),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 25, sigmaY: 25),
          child: SafeArea(
            top: false,
            bottom: !isKeyboardOpen,
            child: Container(
              height: 46,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. Table Tool
                  _buildToolbarIcon(
                    icon: Icons.table_chart_outlined,
                    tooltip: "Insert Table",
                    onTap: onInsertTable,
                  ),

                  // 2. Aa Typography & Styling
                  InkWell(
                    onTap: onFormatText,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Aa",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD60A), // Apple Notes Yellow
                        ),
                      ),
                    ),
                  ),

                  // 3. Checklist
                  _buildToolbarIcon(
                    icon: Icons.checklist_rounded,
                    tooltip: "Checklist",
                    onTap: onInsertChecklist,
                  ),

                  // 4. Camera & Attachments
                  _buildToolbarIcon(
                    icon: Icons.camera_alt_outlined,
                    tooltip: "Camera & Photos",
                    onTap: onAddAttachment,
                  ),

                  // 5. Drawing & Markup Canvas
                  _buildToolbarIcon(
                    icon: Icons.draw_outlined,
                    tooltip: "Markup & Sketch",
                    color: const Color(0xFFFF9F0A),
                    onTap: onOpenDrawing,
                  ),

                  // 6. Math & LaTeX Formula
                  _buildToolbarIcon(
                    icon: Icons.functions_rounded,
                    tooltip: "LaTeX Math",
                    color: AppColors.nebulaCyan,
                    onTap: onInsertMath,
                  ),

                  // 7. Dismiss Keyboard
                  if (isKeyboardOpen)
                    _buildToolbarIcon(
                      icon: Icons.keyboard_hide_rounded,
                      tooltip: "Hide Keyboard",
                      color: Colors.white70,
                      onTap: onHideKeyboard,
                    )
                  else
                    const SizedBox(width: 36),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToolbarIcon({
    required IconData icon,
    required String tooltip,
    Color? color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 21, color: color ?? Colors.white),
      tooltip: tooltip,
      splashRadius: 18,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      onPressed: onTap,
    );
  }
}

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

  const AppleNotesToolbar({
    super.key,
    required this.onInsertTable,
    required this.onFormatText,
    required this.onInsertChecklist,
    required this.onAddAttachment,
    required this.onOpenDrawing,
    required this.onInsertMath,
    required this.onHideKeyboard,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E).withValues(alpha: 0.92),
        border: const Border(
          top: BorderSide(color: Color(0xFF2C2C2E), width: 0.8),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: SafeArea(
            top: false,
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 10),
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
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      child: Text(
                        "Aa",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.nebulaCyan,
                        ),
                      ),
                    ),
                  ),

                  // 3. Checklist
                  _buildToolbarIcon(
                    icon: Icons.checklist_rounded,
                    tooltip: "Add Checklist",
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
                    onTap: onOpenDrawing,
                  ),

                  // 6. Math & LaTeX Formula
                  _buildToolbarIcon(
                    icon: Icons.functions_rounded,
                    tooltip: "LaTeX Math Formula",
                    onTap: onInsertMath,
                  ),

                  // 7. Dismiss Keyboard
                  _buildToolbarIcon(
                    icon: Icons.keyboard_hide_rounded,
                    tooltip: "Dismiss Keyboard",
                    color: Colors.white38,
                    onTap: onHideKeyboard,
                  ),
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
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      onPressed: onTap,
    );
  }
}

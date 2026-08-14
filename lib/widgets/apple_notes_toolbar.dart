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
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0 || isKeyboardVisible;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E22).withValues(alpha: 0.97),
        border: const Border(
          top: BorderSide(color: Color(0xFF36363E), width: 0.6),
        ),
      ),
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: Padding(
            // Only add safe area bottom padding when the keyboard is NOT open
            padding: EdgeInsets.only(
              bottom: isKeyboardOpen ? 0 : MediaQuery.of(context).padding.bottom,
            ),
            child: SizedBox(
              height: 46,
              child: Row(
                children: [
                  const SizedBox(width: 8),

                  // Table
                  _toolButton(
                    icon: Icons.table_chart_outlined,
                    tooltip: "Insert Table",
                    onTap: onInsertTable,
                  ),
                  const SizedBox(width: 2),

                  // Aa Typography
                  InkWell(
                    onTap: onFormatText,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFD60A).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Aa",
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFFFFD60A),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2),

                  // Checklist
                  _toolButton(
                    icon: Icons.checklist_rounded,
                    tooltip: "Checklist",
                    onTap: onInsertChecklist,
                  ),
                  const SizedBox(width: 2),

                  // Camera & Attachments
                  _toolButton(
                    icon: Icons.camera_alt_outlined,
                    tooltip: "Camera & Photos",
                    onTap: onAddAttachment,
                  ),
                  const SizedBox(width: 2),

                  // Drawing
                  _toolButton(
                    icon: Icons.draw_outlined,
                    tooltip: "Markup & Sketch",
                    color: const Color(0xFFFF9F0A),
                    onTap: onOpenDrawing,
                  ),
                  const SizedBox(width: 2),

                  // Math
                  _toolButton(
                    icon: Icons.functions_rounded,
                    tooltip: "LaTeX Math",
                    color: AppColors.nebulaCyan,
                    onTap: onInsertMath,
                  ),

                  const Spacer(),

                  // Dismiss keyboard
                  if (isKeyboardOpen)
                    _toolButton(
                      icon: Icons.keyboard_hide_rounded,
                      tooltip: "Hide Keyboard",
                      color: Colors.white70,
                      onTap: onHideKeyboard,
                    ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _toolButton({
    required IconData icon,
    required String tooltip,
    Color? color,
    required VoidCallback onTap,
  }) {
    return IconButton(
      icon: Icon(icon, size: 22, color: color ?? Colors.white),
      tooltip: tooltip,
      padding: const EdgeInsets.all(8),
      constraints: const BoxConstraints(minWidth: 38, minHeight: 38),
      splashRadius: 20,
      onPressed: onTap,
    );
  }
}

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum TextFormattingType {
  title,
  heading,
  subheading,
  body,
  monospaced,
  bold,
  italic,
  strikethrough,
  underline,
  bulletList,
  numberedList,
  blockquote,
  indent,
  outdent,
}

class AppleTextFormatSheet extends StatelessWidget {
  final ValueChanged<TextFormattingType> onFormatSelected;

  const AppleTextFormatSheet({
    super.key,
    required this.onFormatSelected,
  });

  static void show(
    BuildContext context, {
    required ValueChanged<TextFormattingType> onFormatSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C1C1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => AppleTextFormatSheet(
        onFormatSelected: (format) {
          Navigator.pop(ctx);
          onFormatSelected(format);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Format Text",
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  "Aa",
                  style: GoogleFonts.outfit(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.nebulaCyan,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Text Hierarchy (Title, Heading, Subheading, Body, Monospaced)
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildHierarchyRow(
                    label: "Title",
                    style: GoogleFonts.outfit(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    type: TextFormattingType.title,
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  _buildHierarchyRow(
                    label: "Heading",
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    type: TextFormattingType.heading,
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  _buildHierarchyRow(
                    label: "Subheading",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                    type: TextFormattingType.subheading,
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  _buildHierarchyRow(
                    label: "Body Text",
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.normal,
                      color: Colors.white60,
                    ),
                    type: TextFormattingType.body,
                  ),
                  const Divider(height: 1, color: Colors.white12),
                  _buildHierarchyRow(
                    label: "Monospaced (Code)",
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 13,
                      color: AppColors.nebulaCyan,
                    ),
                    type: TextFormattingType.monospaced,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Inline Styles (B, I, U, S)
            Row(
              children: [
                Expanded(
                  child: _buildInlineStyleButton(
                    label: "B",
                    isBold: true,
                    type: TextFormattingType.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInlineStyleButton(
                    label: "I",
                    isItalic: true,
                    type: TextFormattingType.italic,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInlineStyleButton(
                    label: "U",
                    isUnderline: true,
                    type: TextFormattingType.underline,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildInlineStyleButton(
                    label: "S",
                    isStrikethrough: true,
                    type: TextFormattingType.strikethrough,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Lists & Blockquote
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildListButton(
                    icon: Icons.format_list_bulleted_rounded,
                    tooltip: "Bullet List",
                    type: TextFormattingType.bulletList,
                  ),
                  _buildListButton(
                    icon: Icons.format_list_numbered_rounded,
                    tooltip: "Numbered List",
                    type: TextFormattingType.numberedList,
                  ),
                  _buildListButton(
                    icon: Icons.format_quote_rounded,
                    tooltip: "Blockquote",
                    type: TextFormattingType.blockquote,
                  ),
                  _buildListButton(
                    icon: Icons.format_indent_increase_rounded,
                    tooltip: "Indent",
                    type: TextFormattingType.indent,
                  ),
                  _buildListButton(
                    icon: Icons.format_indent_decrease_rounded,
                    tooltip: "Outdent",
                    type: TextFormattingType.outdent,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildHierarchyRow({
    required String label,
    required TextStyle style,
    required TextFormattingType type,
  }) {
    return InkWell(
      onTap: () => onFormatSelected(type),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: style),
            const Icon(
              Icons.check,
              size: 16,
              color: Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInlineStyleButton({
    required String label,
    bool isBold = false,
    bool isItalic = false,
    bool isUnderline = false,
    bool isStrikethrough = false,
    required TextFormattingType type,
  }) {
    return InkWell(
      onTap: () => onFormatSelected(type),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2E),
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
            decoration: isUnderline
                ? TextDecoration.underline
                : (isStrikethrough ? TextDecoration.lineThrough : null),
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildListButton({
    required IconData icon,
    required String tooltip,
    required TextFormattingType type,
  }) {
    return IconButton(
      icon: Icon(icon, color: Colors.white70, size: 20),
      tooltip: tooltip,
      onPressed: () => onFormatSelected(type),
    );
  }
}

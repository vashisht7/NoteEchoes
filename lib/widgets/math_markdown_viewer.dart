import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class MathMarkdownViewer extends StatelessWidget {
  final String content;
  final TextStyle? baseStyle;

  const MathMarkdownViewer({
    super.key,
    required this.content,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (content.trim().isEmpty) return const SizedBox.shrink();

    final lines = content.split('\n');
    final widgets = <Widget>[];

    bool inTable = false;
    final tableRows = <List<String>>[];

    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];

      // 1. Table Detection
      if (line.trim().startsWith('|') && line.trim().endsWith('|')) {
        inTable = true;
        final cells = line.split('|').map((c) => c.trim()).where((c) => c.isNotEmpty).toList();
        if (!line.contains('---')) {
          tableRows.add(cells);
        }
        continue;
      } else if (inTable) {
        // Flush table
        widgets.add(_buildTable(tableRows));
        tableRows.clear();
        inTable = false;
      }

      // 2. Block Display Math: $$ ... $$
      if (line.trim().startsWith(r'$$') && line.trim().endsWith(r'$$') && line.trim().length > 4) {
        final mathEquation = line.trim().substring(2, line.trim().length - 2).trim();
        widgets.add(_buildDisplayMath(mathEquation));
        continue;
      }

      // 3. Headings (#, ##, ###)
      if (line.startsWith('# ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 14, bottom: 6),
          child: Text(
            line.substring(2),
            style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ));
        continue;
      } else if (line.startsWith('## ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 10, bottom: 4),
          child: Text(
            line.substring(3),
            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.primaryText),
          ),
        ));
        continue;
      } else if (line.startsWith('### ')) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(top: 8, bottom: 4),
          child: Text(
            line.substring(4),
            style: GoogleFonts.inter(fontSize: 14.5, fontWeight: FontWeight.w600, color: AppColors.primaryText),
          ),
        ));
        continue;
      }

      // 4. Bullet list items
      if (line.trim().startsWith('- ') || line.trim().startsWith('• ')) {
        final bulletText = line.trim().substring(2);
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("• ", style: TextStyle(color: AppColors.dropletRed, fontSize: 14, fontWeight: FontWeight.bold)),
              Expanded(child: _buildInlineRichText(bulletText)),
            ],
          ),
        ));
        continue;
      }

      // 5. Standard line with potential inline math
      if (line.trim().isNotEmpty) {
        widgets.add(Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: _buildInlineRichText(line),
        ));
      }
    }

    if (inTable && tableRows.isNotEmpty) {
      widgets.add(_buildTable(tableRows));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }

  Widget _buildDisplayMath(String equation) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.elevation2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF00F2FE).withValues(alpha: 0.35)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Math.tex(
            equation,
            textStyle: const TextStyle(fontSize: 17, color: Color(0xFF00F2FE)),
            mathStyle: MathStyle.display,
          ),
        ),
      ),
    );
  }

  Widget _buildInlineRichText(String text) {
    // Check if contains inline math $ ... $
    if (text.contains(r'$')) {
      final parts = text.split(r'$');
      final spans = <InlineSpan>[];

      for (int i = 0; i < parts.length; i++) {
        if (i % 2 == 1 && parts[i].trim().isNotEmpty) {
          // Math span
          spans.add(WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: Math.tex(
                parts[i].trim(),
                textStyle: const TextStyle(fontSize: 13.5, color: Color(0xFF00F2FE)),
                mathStyle: MathStyle.text,
              ),
            ),
          ));
        } else {
          spans.add(TextSpan(
            text: parts[i],
            style: baseStyle ??
                GoogleFonts.inter(
                  fontSize: 13.5,
                  height: 1.45,
                  color: AppColors.primaryText,
                ),
          ));
        }
      }

      return RichText(text: TextSpan(children: spans));
    }

    return Text(
      text,
      style: baseStyle ??
          GoogleFonts.inter(
            fontSize: 13.5,
            height: 1.45,
            color: AppColors.primaryText,
          ),
    );
  }

  Widget _buildTable(List<List<String>> rows) {
    if (rows.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.elevation2.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.glassBorderBright),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Table(
          defaultColumnWidth: const IntrinsicColumnWidth(),
          border: TableBorder.all(color: AppColors.glassBorder, width: 0.8),
          children: rows.asMap().entries.map((entry) {
            final rowIndex = entry.key;
            final cells = entry.value;
            final isHeader = rowIndex == 0;

            return TableRow(
              decoration: BoxDecoration(
                color: isHeader ? AppColors.elevation3.withValues(alpha: 0.8) : Colors.transparent,
              ),
              children: cells.map((cell) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    cell,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isHeader ? FontWeight.bold : FontWeight.w500,
                      color: isHeader ? Colors.white : AppColors.primaryText,
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }
}

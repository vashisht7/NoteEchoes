import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ExpandingSearchBar extends StatefulWidget {
  final bool isExpanded;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleExpand;
  final VoidCallback onClose;

  const ExpandingSearchBar({
    super.key,
    required this.isExpanded,
    required this.onChanged,
    required this.onToggleExpand,
    required this.onClose,
  });

  @override
  State<ExpandingSearchBar> createState() => _ExpandingSearchBarState();
}

class _ExpandingSearchBarState extends State<ExpandingSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void didUpdateWidget(covariant ExpandingSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isExpanded && !oldWidget.isExpanded) {
      _focusNode.requestFocus();
    } else if (!widget.isExpanded && oldWidget.isExpanded) {
      _controller.clear();
      widget.onChanged('');
      _focusNode.unfocus();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: const Cubic(0.16, 1, 0.3, 1),
      width: widget.isExpanded ? screenWidth - 32 : 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.elevation2,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: widget.isExpanded ? AppColors.glassBorderBright : AppColors.glassBorder,
          width: widget.isExpanded ? 1.4 : 1.0,
        ),
        boxShadow: widget.isExpanded
            ? [
                BoxShadow(
                  color: Colors.white.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 1,
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 12,
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 6,
                ),
              ],
      ),
      child: widget.isExpanded
          ? Row(
              children: [
                const SizedBox(width: 14),
                const Icon(Icons.search_rounded, size: 20, color: AppColors.primaryText),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode,
                    onChanged: widget.onChanged,
                    cursorColor: Colors.white,
                    style: GoogleFonts.inter(
                      fontSize: 14.5,
                      color: AppColors.primaryText,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search notes, tags, transcripts...",
                      hintStyle: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppColors.secondaryText,
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                if (_controller.text.isNotEmpty)
                  GestureDetector(
                    onTap: () {
                      _controller.clear();
                      widget.onChanged('');
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Icon(Icons.clear_rounded, size: 16, color: AppColors.secondaryText),
                    ),
                  ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.elevation1,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, size: 16, color: AppColors.primaryText),
                  ),
                ),
              ],
            )
          : InkWell(
              onTap: widget.onToggleExpand,
              borderRadius: BorderRadius.circular(22),
              child: const Center(
                child: Icon(Icons.search_rounded, size: 20, color: AppColors.primaryText),
              ),
            ),
    );
  }
}

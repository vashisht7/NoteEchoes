import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';

class KeepTextNoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final Function(String itemId)? onToggleCheckItem;

  const KeepTextNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onToggleCheckItem,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.elevation1,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: note.isPinned
                ? AppColors.dropletRed.withValues(alpha: 0.4)
                : AppColors.glassBorder,
            width: note.isPinned ? 1.2 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Title & Pin
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                        height: 1.25,
                      ),
                    ),
                  ),
                  if (note.isPinned) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.push_pin_rounded,
                      size: 13,
                      color: AppColors.dropletRed,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),

              // Checklist preview if present
              if (note.checklist.isNotEmpty) ...[
                ...note.checklist.take(4).map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => onToggleCheckItem?.call(item.id),
                          child: Icon(
                            item.isCompleted
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            size: 14,
                            color: item.isCompleted
                                ? AppColors.accentGreen
                                : AppColors.secondaryText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.text,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: item.isCompleted
                                  ? AppColors.secondaryText
                                  : AppColors.primaryText,
                              decoration: item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : TextDecoration.none,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                if (note.checklist.length > 4)
                  Text(
                    "+${note.checklist.length - 4} more items",
                    style: const TextStyle(
                      fontSize: 10.5,
                      color: AppColors.secondaryText,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                const SizedBox(height: 6),
              ] else ...[
                // Content Truncated at 4 lines (Google Keep style)
                Text(
                  note.textContent.isNotEmpty ? note.textContent : note.summarySnippet,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                    height: 1.42,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 10),
              ],

              // Bottom Tags / Date
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  ...note.tags.take(2).map((tag) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.badgeTag,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          "#$tag",
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primaryText,
                          ),
                        ),
                      )),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

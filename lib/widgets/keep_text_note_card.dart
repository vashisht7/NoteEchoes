import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';

class KeepTextNoteCard extends StatelessWidget {
  final NoteModel note;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String itemId)? onToggleCheckItem;

  const KeepTextNoteCard({
    super.key,
    required this.note,
    this.onTap,
    this.onLongPress,
    this.onToggleCheckItem,
  });

  @override
  Widget build(BuildContext context) {
    final isVoiceMemo = note.tags.contains('voice-memos') ||
        note.tags.contains('voice-memo') ||
        note.tags.contains('voice');

    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF16161C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: note.isPinned
                ? AppColors.dropletRed.withValues(alpha: 0.6)
                : (isVoiceMemo
                    ? AppColors.nebulaCyan.withValues(alpha: 0.25)
                    : const Color(0xFF282832)),
            width: note.isPinned ? 1.5 : 1.1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.45),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
            if (note.isPinned)
              BoxShadow(
                color: AppColors.dropletRed.withValues(alpha: 0.15),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header: Timestamp & Pin / Voice Indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Timestamp
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVoiceMemo
                            ? Icons.mic_rounded
                            : Icons.access_time_rounded,
                        size: 12,
                        color: isVoiceMemo
                            ? AppColors.nebulaCyan
                            : AppColors.secondaryText,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        formatNoteTimestamp(note.createdAt),
                        style: GoogleFonts.inter(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isVoiceMemo
                              ? AppColors.nebulaCyan.withValues(alpha: 0.9)
                              : AppColors.secondaryText,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),

                  // Pin Icon / Badge
                  if (note.isPinned)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.dropletRed.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.push_pin_rounded,
                            size: 11,
                            color: AppColors.dropletRed,
                          ),
                          SizedBox(width: 3),
                          Text(
                            "PIN",
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: AppColors.dropletRed,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),

              // Note Title
              Text(
                note.title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryText,
                  height: 1.25,
                ),
              ),
              const SizedBox(height: 6),

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
                // Content Truncated at 4 lines
                Text(
                  note.textContent.isNotEmpty
                      ? note.textContent
                      : note.summarySnippet,
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

              // Bottom Tags
              Wrap(
                spacing: 5,
                runSpacing: 4,
                children: [
                  ...note.tags.take(3).map((tag) {
                    final isVoiceTag =
                        tag == 'voice-memos' || tag == 'voice-memo';
                    return Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2.5),
                      decoration: BoxDecoration(
                        color: isVoiceTag
                            ? AppColors.nebulaCyan.withValues(alpha: 0.15)
                            : AppColors.badgeTag,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isVoiceTag
                              ? AppColors.nebulaCyan.withValues(alpha: 0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Text(
                        "#$tag",
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: isVoiceTag
                              ? AppColors.nebulaCyan
                              : AppColors.primaryText,
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

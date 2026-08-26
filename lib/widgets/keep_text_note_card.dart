import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../theme/app_colors.dart';
import '../utils/date_formatter.dart';
import '../services/note_quick_action_service.dart';

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
    final accent = Theme.of(context).colorScheme.primary;
    final isVoiceMemo =
        note.tags.contains('voice-memo') || note.tags.contains('voice');
    final quickAction = NoteQuickActionService.classify(note);

    return Semantics(
      button: true,
      label:
          '${note.isPinned ? 'Pinned note. ' : ''}${note.title}. ${note.summarySnippet}',
      hint: 'Double tap to open. Long press for note actions.',
      child: GestureDetector(
        onTap: onTap,
        onLongPress: onLongPress,
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.elevation2,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: note.isPinned
                  ? accent.withValues(alpha: 0.7)
                  : AppColors.glassBorder,
              width: note.isPinned ? 1.4 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.28),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              BoxShadow(
                color: accent.withValues(alpha: note.isPinned ? 0.10 : 0.025),
                blurRadius: 14,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header: Timestamp & Pin / Voice Indicator
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Timestamp
                    Flexible(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isVoiceMemo
                                ? Icons.mic_rounded
                                : Icons.access_time_rounded,
                            size: 12,
                            color: isVoiceMemo
                                ? accent
                                : AppColors.secondaryText,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              formatNoteTimestamp(note.createdAt),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                                color: isVoiceMemo
                                    ? accent.withValues(alpha: 0.9)
                                    : AppColors.secondaryText,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Pin Icon / Badge
                    if (note.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: accent.withValues(alpha: 0.14),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.push_pin_rounded,
                              size: 11,
                              color: accent,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              "PIN",
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: accent,
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
                if (note.tags.contains('reminders')) ...[
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      Icon(
                        note.tags.contains('reminder-failed')
                            ? Icons.error_outline_rounded
                            : note.tags.contains('reminder-pending')
                            ? Icons.schedule_rounded
                            : Icons.alarm_rounded,
                        size: 13,
                        color: note.tags.contains('reminder-failed')
                            ? const Color(0xFFFF9F0A)
                            : accent,
                      ),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          note.tags.contains('reminder-failed')
                              ? 'Reminder needs attention'
                              : note.tags.contains('reminder-pending')
                              ? 'Scheduling reminder…'
                              : note.reminderAt == null
                              ? 'Reminder scheduled'
                              : 'Reminder • ${formatNoteTimestamp(note.reminderAt!)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.inter(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: note.tags.contains('reminder-failed')
                                ? const Color(0xFFFF9F0A)
                                : accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

                // Compact metadata with one predictable action at bottom-right.
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Wrap(
                        spacing: 5,
                        runSpacing: 4,
                        children: note.tags
                            .where(
                              (tag) => !{
                                'reminder-pending',
                                'reminder-scheduled',
                                'reminder-failed',
                              }.contains(tag),
                            )
                            .take(2)
                            .map((tag) {
                              final isVoiceTag =
                                  tag == 'voice-memos' || tag == 'voice-memo';
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 2.5,
                                ),
                                decoration: BoxDecoration(
                                  color: isVoiceTag
                                      ? accent.withValues(alpha: 0.10)
                                      : AppColors.badgeTag,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: isVoiceTag
                                        ? accent.withValues(alpha: 0.24)
                                        : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  "#$tag",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isVoiceTag
                                        ? accent
                                        : AppColors.primaryText,
                                  ),
                                ),
                              );
                            })
                            .toList(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    _NoteQuickActionButton(
                      kind: quickAction,
                      onTap: () async {
                        if (quickAction == NoteQuickActionKind.message ||
                            quickAction == NoteQuickActionKind.email) {
                          final opened =
                              await NoteQuickActionService.launchComposer(note);
                          if (!opened && context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Could not open the composer.'),
                              ),
                            );
                          }
                          return;
                        }
                        onTap?.call();
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NoteQuickActionButton extends StatelessWidget {
  const _NoteQuickActionButton({required this.kind, required this.onTap});

  final NoteQuickActionKind kind;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final (icon, label, color) = switch (kind) {
      NoteQuickActionKind.reminder => (
        Icons.alarm_rounded,
        'Open reminder note',
        const Color(0xFFFF9F0A),
      ),
      NoteQuickActionKind.checklist => (
        Icons.checklist_rounded,
        'Open checklist',
        AppColors.accentGreen,
      ),
      NoteQuickActionKind.email => (
        Icons.mail_outline_rounded,
        'Compose email',
        const Color(0xFF64D2FF),
      ),
      NoteQuickActionKind.message => (
        Icons.chat_bubble_outline_rounded,
        'Compose message',
        AppColors.accentGreen,
      ),
      NoteQuickActionKind.note => (Icons.notes_rounded, 'Open note', accent),
    };
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: InkResponse(
          key: ValueKey('note_quick_action_${kind.name}'),
          onTap: onTap,
          radius: 22,
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              shape: BoxShape.circle,
              border: Border.all(color: color.withValues(alpha: .22)),
            ),
            child: Icon(icon, size: 15, color: color),
          ),
        ),
      ),
    );
  }
}

// agent_prompt_review_card.dart
// Review-first UI widget for displaying and copying formatted agent briefs.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../ai/domain/note_interpretation.dart';

class AgentPromptReviewCard extends StatelessWidget {
  final AgentPromptDraft promptDraft;

  const AgentPromptReviewCard({
    super.key,
    required this.promptDraft,
  });

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.smart_toy_rounded, color: accent, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Agent Coding Prompt Draft',
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${(promptDraft.confidence * 100).toInt()}% match',
                  style: GoogleFonts.inter(fontSize: 11, color: accent, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            promptDraft.goal,
            style: GoogleFonts.inter(
              fontSize: 14.5,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            promptDraft.context,
            style: GoogleFonts.inter(fontSize: 12.5, color: Colors.white70),
          ),
          if (promptDraft.requirements.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              'REQUIREMENTS',
              style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white38),
            ),
            const SizedBox(height: 4),
            ...promptDraft.requirements.take(3).map((r) => Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(color: Colors.white54)),
                      Expanded(
                        child: Text(r, style: GoogleFonts.inter(fontSize: 12, color: Colors.white70)),
                      ),
                    ],
                  ),
                )),
          ],
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _copyToClipboard(
                    context,
                    promptDraft.toCodexMarkdown(),
                    'Codex brief',
                  ),
                  icon: const Icon(Icons.copy_rounded, size: 16),
                  label: const Text('Copy for Codex'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              OutlinedButton.icon(
                onPressed: () => _copyToClipboard(
                  context,
                  promptDraft.toCodexMarkdown(),
                  'Agent prompt',
                ),
                icon: const Icon(Icons.content_paste_go_rounded, size: 16),
                label: const Text('Copy for Agent'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: const BorderSide(color: Colors.white24),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

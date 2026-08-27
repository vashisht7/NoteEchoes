import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_colors.dart';

class NoteEchoesGuideScreen extends StatelessWidget {
  const NoteEchoesGuideScreen({super.key});

  static const _guides = <_VoiceGuide>[
    _VoiceGuide(
      icon: Icons.mic_none_rounded,
      color: AppColors.logoCrimson,
      title: 'Capture a thought',
      result: 'Saves a clean note without losing your wording.',
      examples: [
        'Remember that the client prefers weekly updates.',
        'Save this idea: a voice-first daily planning screen.',
      ],
    ),
    _VoiceGuide(
      icon: Icons.check_circle_outline_rounded,
      color: AppColors.accentGreen,
      title: 'Tasks & checklists',
      result: 'Creates actionable items you can check off.',
      examples: [
        'Add a task to send the proposal.',
        'Create a checklist: first buy milk, second call Mom, third pack my charger.',
      ],
    ),
    _VoiceGuide(
      icon: Icons.notifications_none_rounded,
      color: AppColors.accentOrange,
      title: 'Set a reminder',
      result: 'Shows a review before creating the reminder.',
      examples: [
        'Remind me in one minute to check the app.',
        'Remind me tomorrow at 9 AM to call Sam.',
      ],
    ),
    _VoiceGuide(
      icon: Icons.calendar_month_outlined,
      color: AppColors.accentBlue,
      title: 'Schedule something',
      result: 'Prepares a calendar event for your confirmation.',
      examples: [
        'Schedule a design review Friday at 3 PM for 30 minutes.',
        'Add a dentist appointment on September 8 at 10 AM.',
      ],
    ),
    _VoiceGuide(
      icon: Icons.forum_outlined,
      color: AppColors.accentPurple,
      title: 'Talk to your memory',
      result: 'Searches your notes, tasks, checklists, and reminders.',
      examples: [
        'What did I need to do yesterday?',
        'Summarize my open tasks and upcoming reminders.',
        'What did I decide about Project Atlas?',
      ],
    ),
    _VoiceGuide(
      icon: Icons.picture_as_pdf_outlined,
      color: AppColors.badgePdf,
      title: 'Ask about a PDF',
      result: 'Answers from the document and keeps page references.',
      examples: [
        'Summarize this PDF in five points.',
        'What does page four say about costs?',
      ],
    ),
    _VoiceGuide(
      icon: Icons.send_outlined,
      color: Color(0xFF64D2FF),
      title: 'Draft a message or email',
      result: 'Creates a draft for review—it never sends silently.',
      examples: [
        'Draft a message to Alex saying I am running ten minutes late.',
        'Draft an email to Priya with today’s project update.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepMatteBlack,
        elevation: 0,
        title: Text(
          'NoteEchoes Guide',
          style: GoogleFonts.inter(
            color: AppColors.primaryText,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: CustomScrollView(
        key: const ValueKey('noteechoes_guide_scroll'),
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            sliver: SliverToBoxAdapter(child: _GuideHero(accent: accent)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            sliver: SliverToBoxAdapter(child: _CommandFormula(accent: accent)),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'TRY SAYING',
                style: GoogleFonts.inter(
                  color: Colors.white38,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.1,
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: _guides.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) =>
                  _VoiceGuideCard(guide: _guides[index]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
            sliver: SliverToBoxAdapter(child: _BestResultsCard(accent: accent)),
          ),
          const SliverPadding(padding: EdgeInsets.only(bottom: 36)),
        ],
      ),
    );
  }
}

class _GuideHero extends StatelessWidget {
  final Color accent;

  const _GuideHero({required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [accent.withValues(alpha: 0.28), AppColors.elevation2],
      ),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: accent.withValues(alpha: 0.35)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accent,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(color: accent.withValues(alpha: 0.32), blurRadius: 22),
            ],
          ),
          child: const Icon(Icons.graphic_eq_rounded, color: Colors.white),
        ),
        const SizedBox(height: 18),
        Text(
          'Speak naturally.\nInclude what matters.',
          style: GoogleFonts.inter(
            color: AppColors.primaryText,
            fontSize: 25,
            height: 1.12,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'NoteEchoes removes fillers and self-corrections, then turns the clean meaning into the right note or action.',
          style: GoogleFonts.inter(
            color: Colors.white70,
            fontSize: 13.5,
            height: 1.45,
          ),
        ),
      ],
    ),
  );
}

class _CommandFormula extends StatelessWidget {
  final Color accent;

  const _CommandFormula({required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.elevation1,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.glassBorderBright),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, color: accent, size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The reliable voice formula',
                style: GoogleFonts.inter(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final chipWidth = (constraints.maxWidth - 7) / 2;
            return Wrap(
              spacing: 7,
              runSpacing: 7,
              children: [
                SizedBox(
                  width: chipWidth,
                  child: const _FormulaChip(
                    label: 'ACTION',
                    example: 'Remind me',
                  ),
                ),
                SizedBox(
                  width: chipWidth,
                  child: const _FormulaChip(
                    label: 'WHAT',
                    example: 'to call Sam',
                  ),
                ),
                SizedBox(
                  width: chipWidth,
                  child: const _FormulaChip(
                    label: 'WHEN',
                    example: 'tomorrow at 9',
                  ),
                ),
                SizedBox(
                  width: chipWidth,
                  child: const _FormulaChip(
                    label: 'DETAILS',
                    example: 'about the proposal',
                  ),
                ),
              ],
            );
          },
        ),
      ],
    ),
  );
}

class _FormulaChip extends StatelessWidget {
  final String label;
  final String example;

  const _FormulaChip({required this.label, required this.example});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.055),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '$label  ',
            style: GoogleFonts.inter(
              color: Colors.white38,
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.7,
            ),
          ),
          TextSpan(
            text: example,
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    ),
  );
}

class _VoiceGuideCard extends StatelessWidget {
  final _VoiceGuide guide;

  const _VoiceGuideCard({required this.guide});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.elevation2,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.glassBorder),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: guide.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(guide.icon, color: guide.color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    guide.title,
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    guide.result,
                    style: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 13),
        ...guide.examples.map(
          (example) => Padding(
            padding: const EdgeInsets.only(top: 7),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.28),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.format_quote_rounded,
                    color: guide.color.withValues(alpha: 0.8),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      example,
                      style: GoogleFonts.inter(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12.5,
                        height: 1.38,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _BestResultsCard extends StatelessWidget {
  final Color accent;

  const _BestResultsCard({required this.accent});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: AppColors.elevation1,
      borderRadius: BorderRadius.circular(17),
      border: Border.all(color: AppColors.glassBorderBright),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'For the best results',
          style: GoogleFonts.inter(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        const _Tip(
          text: 'Use an exact time for reminders and calendar events.',
        ),
        const _Tip(
          text:
              'After asking a question, pause naturally—NoteEchoes starts searching automatically.',
        ),
        const _Tip(text: 'Say “first,” “second,” and “third” for a checklist.'),
        const _Tip(
          text: 'Say “cancel” before saving if you want to discard it.',
        ),
        const _Tip(
          text:
              'Review reminders, events, messages, and emails before confirming.',
        ),
        const _Tip(
          text:
              'If your notes do not contain the answer, conversation mode can use an attributed web source while online.',
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: accent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.language_rounded, color: accent, size: 18),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  'English is currently the most reliable action language. For Telugu or Hindi, select the matching Recognition Language in Settings and review dates and actions before confirming.',
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _Tip extends StatelessWidget {
  final String text;

  const _Tip({required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 2),
          child: Icon(
            Icons.check_rounded,
            color: AppColors.accentGreen,
            size: 16,
          ),
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.inter(
              color: Colors.white70,
              fontSize: 12.5,
              height: 1.38,
            ),
          ),
        ),
      ],
    ),
  );
}

class _VoiceGuide {
  final IconData icon;
  final Color color;
  final String title;
  final String result;
  final List<String> examples;

  const _VoiceGuide({
    required this.icon,
    required this.color,
    required this.title,
    required this.result,
    required this.examples,
  });
}

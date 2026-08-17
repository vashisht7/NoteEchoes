// journal_review_page.dart
// Journal insights and personal reflection view.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../config/ai_feature_flags.dart';
import 'model_feature_gate.dart';

class JournalReviewPage extends StatefulWidget {
  const JournalReviewPage({super.key});

  @override
  State<JournalReviewPage> createState() => _JournalReviewPageState();
}

class _JournalReviewPageState extends State<JournalReviewPage> {
  String? _weeklyReview;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.white70,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Journal Review',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _WeekHeader(),
            const SizedBox(height: 20),
            if (!AiFeatureFlags.instance.journalingMemoryEnabled) ...[
              _AiDisabledBanner(),
            ] else if (_isLoading) ...[
              const Center(
                child: CircularProgressIndicator(color: Color(0xFFD7192D)),
              ),
            ] else if (_weeklyReview != null) ...[
              Expanded(child: _ReviewContent(text: _weeklyReview!)),
            ] else ...[
              _GeneratePrompt(
                onGenerate: () {
                  // TODO: inject JournalReviewUseCase and call generateWeeklyReview
                  setState(() => _isLoading = true);
                  Future.delayed(const Duration(seconds: 2), () {
                    if (mounted) {
                      setState(() {
                        _isLoading = false;
                        _weeklyReview =
                            'Weekly review feature will be available once the Qwen AI model is installed.\n\nInstall the model from Settings → AI Models to unlock AI-powered journaling insights.';
                      });
                    }
                  });
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeekHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final fmt = DateFormat('MMM d');
    final label = '${fmt.format(weekStart)} – ${fmt.format(now)}';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'This Week',
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(fontSize: 14, color: Colors.white38),
        ),
      ],
    );
  }
}

class _AiDisabledBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ModelUpgradeNotice(
      availableNow: 'Journal notes remain available without a model.',
      enhancedWithModel:
          'Download Qwen3 to create private weekly reflections and recurring themes.',
      onTap: () =>
          requireQwenModel(context, featureName: 'weekly journal reflections'),
    );
  }
}

class _GeneratePrompt extends StatelessWidget {
  final VoidCallback onGenerate;
  const _GeneratePrompt({required this.onGenerate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFD7192D).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              size: 40,
              color: Color(0xFFD7192D),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Weekly Reflection',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Review your notes from this week and get AI-powered insights\nabout recurring themes, mood, and progress.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white38,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onGenerate,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(
              'Generate Weekly Review',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD7192D),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReviewContent extends StatelessWidget {
  final String text;
  const _ReviewContent({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7192D).withOpacity(0.2)),
      ),
      child: SingleChildScrollView(
        child: Text(
          text,
          style: GoogleFonts.inter(
            fontSize: 15,
            color: Colors.white,
            height: 1.7,
          ),
        ),
      ),
    );
  }
}

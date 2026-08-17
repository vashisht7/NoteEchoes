// note_insights_view.dart
// Expandable AI insights panel displayed inline on NoteDetailSheet.
// Safely handles the case where LLM is not yet installed (graceful no-op).

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../domain/note_analysis.dart';
import '../config/ai_feature_flags.dart';
import 'model_feature_gate.dart';

class NoteInsightsView extends StatefulWidget {
  final String noteId;
  final NoteAnalysisResult? analysis;
  final VoidCallback? onRegenerate;

  const NoteInsightsView({
    super.key,
    required this.noteId,
    this.analysis,
    this.onRegenerate,
  });

  @override
  State<NoteInsightsView> createState() => _NoteInsightsViewState();
}

class _NoteInsightsViewState extends State<NoteInsightsView>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _expandAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _expandAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _ctrl.duration = MediaQuery.of(context).disableAnimations
        ? Duration.zero
        : const Duration(milliseconds: 300);
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _ctrl.forward();
    } else {
      _ctrl.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final flags = AiFeatureFlags.instance;
    if (!flags.noteAnalysisEnabled) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ModelUpgradeNotice(
          availableNow: 'Your note is saved and searchable without a model.',
          enhancedWithModel:
              'Download Qwen3 for summaries, topics, people, places, and action extraction.',
          onTap: () => requireQwenModel(
            context,
            featureName: 'AI note insights',
            basicAlternative:
                'Saving, tags, checklists, and keyword search remain available.',
          ),
        ),
      );
    }

    final analysis = widget.analysis;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD7192D).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Header row
          InkWell(
            onTap: _toggle,
            borderRadius: BorderRadius.circular(14),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD7192D).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      size: 14,
                      color: Color(0xFFD7192D),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      analysis != null
                          ? 'AI Insights'
                          : 'AI Insights (analysing…)',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (widget.onRegenerate != null)
                    GestureDetector(
                      onTap: widget.onRegenerate,
                      child: const Icon(
                        Icons.refresh_rounded,
                        size: 16,
                        color: Colors.white38,
                      ),
                    ),
                  const SizedBox(width: 6),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: const Icon(
                      Icons.expand_more_rounded,
                      size: 18,
                      color: Colors.white38,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          SizeTransition(
            sizeFactor: _expandAnim,
            child: analysis == null ? _buildLoading() : _buildContent(analysis),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: LinearProgressIndicator(
        backgroundColor: Color(0xFF1E1E22),
        valueColor: AlwaysStoppedAnimation(Color(0xFFD7192D)),
      ),
    );
  }

  Widget _buildContent(NoteAnalysisResult analysis) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          if (analysis.summary.isNotEmpty) ...[
            _InsightRow(label: 'Summary', content: analysis.summary),
            const SizedBox(height: 10),
          ],
          if (analysis.topics.isNotEmpty) ...[
            _ChipRow(label: 'Topics', items: analysis.topics),
            const SizedBox(height: 10),
          ],
          if (analysis.people.isNotEmpty) ...[
            _ChipRow(label: 'People', items: analysis.people),
            const SizedBox(height: 10),
          ],
          if (analysis.places.isNotEmpty) ...[
            _ChipRow(label: 'Places', items: analysis.places),
            const SizedBox(height: 10),
          ],
          if (analysis.actionItems.isNotEmpty) ...[
            _ActionItemsList(items: analysis.actionItems),
            const SizedBox(height: 10),
          ],
          if (analysis.events.isNotEmpty || analysis.reminders.isNotEmpty) ...[
            _SuggestedEventsRow(
              events: analysis.events,
              reminders: analysis.reminders,
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightRow extends StatelessWidget {
  final String label;
  final String content;
  const _InsightRow({required this.label, required this.content});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: GoogleFonts.inter(
            fontSize: 13,
            color: Colors.white70,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}

class _ChipRow extends StatelessWidget {
  final String label;
  final List<String> items;
  const _ChipRow({required this.label, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: items.take(6).map((item) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.06),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                item,
                style: GoogleFonts.inter(fontSize: 12, color: Colors.white54),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ActionItemsList extends StatelessWidget {
  final List<ActionItem> items;
  const _ActionItemsList({required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ACTION ITEMS',
          style: GoogleFonts.inter(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Colors.white38,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 6),
        ...items
            .take(5)
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Icon(
                        Icons.radio_button_unchecked_rounded,
                        size: 12,
                        color: Color(0xFFD7192D),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.task,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: Colors.white70,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      ],
    );
  }
}

class _SuggestedEventsRow extends StatelessWidget {
  final List<CalendarEvent> events;
  final List<Reminder> reminders;
  const _SuggestedEventsRow({required this.events, required this.reminders});

  @override
  Widget build(BuildContext context) {
    final count = events.length + reminders.length;
    return Row(
      children: [
        const Icon(
          Icons.event_note_rounded,
          size: 14,
          color: Color(0xFFFBBF24),
        ),
        const SizedBox(width: 6),
        Text(
          '$count suggested event${count == 1 ? '' : 's'} / reminder${count == 1 ? '' : 's'}',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFFBBF24),
          ),
        ),
        const Spacer(),
        Text(
          'Review →',
          style: GoogleFonts.inter(
            fontSize: 12,
            color: const Color(0xFFD7192D),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

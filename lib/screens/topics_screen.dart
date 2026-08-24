import 'dart:math' as math;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ai/domain/semantic_models.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import 'note_detail_screen.dart';

enum TopicsViewMode { knowledgeGraph, topicCards }

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen>
    with SingleTickerProviderStateMixin {
  final _semantic = SemanticKnowledgeService.instance;
  final _notes = NoteService();
  TopicsViewMode _viewMode = TopicsViewMode.topicCards;
  NoteTopic? _selectedTopic;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _semantic.addListener(_refresh);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _semantic.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepMatteBlack,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.white70,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Topics',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        actions: [
          if (_semantic.isIndexing)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Center(
                child: Semantics(
                  label:
                      'Organizing notes ${(_semantic.progress * 100).round()} percent',
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      value: _semantic.progress,
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(accent),
                    ),
                  ),
                ),
              ),
            ),
          // View Toggle: Graph vs Grouped Cards
          IconButton(
            tooltip: _viewMode == TopicsViewMode.knowledgeGraph
                ? 'Switch to Section List'
                : 'Switch to Knowledge Graph',
            icon: Icon(
              _viewMode == TopicsViewMode.knowledgeGraph
                  ? Icons.view_agenda_rounded
                  : Icons.hub_rounded,
              color: Colors.white70,
              size: 20,
            ),
            onPressed: () {
              setState(() {
                _viewMode = _viewMode == TopicsViewMode.knowledgeGraph
                    ? TopicsViewMode.topicCards
                    : TopicsViewMode.knowledgeGraph;
              });
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: FutureBuilder<List<NoteTopic>>(
        future: _semantic.topics(_notes.allNotes),
        builder: (context, snapshot) {
          final topics = snapshot.data ?? const <NoteTopic>[];
          if (snapshot.connectionState == ConnectionState.waiting &&
              topics.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (topics.isEmpty) return _emptyState();

          return _viewMode == TopicsViewMode.knowledgeGraph
              ? _buildKnowledgeGraphView(topics)
              : _buildTopicCardsView(topics);
        },
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.hub_rounded,
              size: 42,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              _semantic.isIndexing
                  ? 'Building Neural Brain Graph…'
                  : 'No topic clusters yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add voice notes, tasks, or ideas. Your on-device brain will automatically link them into a cohesive knowledge constellation.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: AppColors.secondaryText,
                height: 1.45,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Interactive Neural Knowledge Graph
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildKnowledgeGraphView(List<NoteTopic> topics) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final center = Offset(
          constraints.maxWidth / 2,
          (constraints.maxHeight - 160) / 2,
        );
        final radius =
            math.min(constraints.maxWidth, constraints.maxHeight - 160) * 0.38;

        return Stack(
          children: [
            Positioned.fill(
              child: InteractiveViewer(
                boundaryMargin: const EdgeInsets.all(160),
                minScale: 0.5,
                maxScale: 2.5,
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                  child: Stack(
                    children: [
                      // Background ambient grid / connections canvas
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: _KnowledgeGraphPainter(
                                center: center,
                                topics: topics,
                                radius: radius,
                                pulse: _pulseCtrl.value,
                                accent: Theme.of(context).colorScheme.primary,
                                selectedTopic: _selectedTopic,
                              ),
                            );
                          },
                        ),
                      ),

                      // Central Brain Node
                      Positioned(
                        left: center.dx - 46,
                        top: center.dy - 46,
                        child: _buildCentralBrainNode(),
                      ),

                      // Orbiting Intent / Topic Nodes
                      ...topics.asMap().entries.map((entry) {
                        final idx = entry.key;
                        final topic = entry.value;
                        final angle =
                            (2 * math.pi / topics.length) * idx - (math.pi / 2);
                        final nodeX = center.dx + radius * math.cos(angle) - 40;
                        final nodeY = center.dy + radius * math.sin(angle) - 40;

                        return Positioned(
                          left: nodeX,
                          top: nodeY,
                          child: _buildTopicNode(topic),
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom Selected Topic / Node Inspector Sheet
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: _buildBottomNodeInspector(topics),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCentralBrainNode() {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () => setState(() => _selectedTopic = null),
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (context, child) {
          final scale = 1.0 + (_pulseCtrl.value * 0.05);
          return Transform.scale(
            scale: scale,
            child: Container(
              width: 92,
              height: 92,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    accent.withValues(alpha: 0.35),
                    const Color(0xFF1C1C1E),
                    const Color(0xFF0F0F11),
                  ],
                ),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: accent.withValues(alpha: 0.25),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.psychology_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'My Brain',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${_notes.allNotes.length} notes',
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: Colors.white60,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTopicNode(NoteTopic topic) {
    final isSelected = _selectedTopic?.id == topic.id;
    final accent = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTopic = topic;
        });
        _showTopicDetail(topic);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? const Color(0xFF2C2C2E) : const Color(0xFF1C1C1E),
          border: Border.all(
            color: isSelected ? accent : Colors.white.withValues(alpha: 0.15),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accent.withValues(alpha: 0.3),
                blurRadius: 14,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _topicIcon(topic.label),
              size: 20,
              color: isSelected ? accent : Colors.white70,
            ),
            const SizedBox(height: 3),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                topic.label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.outfit(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : Colors.white70,
                ),
              ),
            ),
            Text(
              '${topic.notes.length}',
              style: GoogleFonts.inter(
                fontSize: 9,
                color: AppColors.secondaryText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _topicIcon(String label) {
    final l = label.toLowerCase();
    if (l.contains('task') || l.contains('todo')) {
      return Icons.check_circle_outline_rounded;
    }
    if (l.contains('meet') || l.contains('call')) return Icons.groups_rounded;
    if (l.contains('grocer') || l.contains('shop')) {
      return Icons.shopping_basket_rounded;
    }
    if (l.contains('math') || l.contains('formula')) {
      return Icons.functions_rounded;
    }
    if (l.contains('idea') || l.contains('brain')) {
      return Icons.lightbulb_outline_rounded;
    }
    if (l.contains('design') || l.contains('ui')) return Icons.palette_outlined;
    if (l.contains('finance') || l.contains('money')) {
      return Icons.attach_money_rounded;
    }
    if (l.contains('travel') || l.contains('trip')) {
      return Icons.flight_takeoff_rounded;
    }
    if (l.contains('health') || l.contains('fitness')) {
      return Icons.favorite_border_rounded;
    }
    if (l.contains('doc') || l.contains('pdf')) {
      return Icons.description_outlined;
    }
    return Icons.bubble_chart_rounded;
  }

  Widget _buildBottomNodeInspector(List<NoteTopic> allTopics) {
    final active = _selectedTopic ?? allTopics.first;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2C2C2E)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.6),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _topicIcon(active.label),
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  active.label,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${active.notes.length} connected notes',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (active.summary.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              active.summary,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 12,
                color: Colors.white54,
                height: 1.4,
              ),
            ),
          ],
          const SizedBox(height: 12),
          // Horizontal notes list
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: active.notes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final note = active.notes[idx];
                return InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => Navigator.of(context).push(
                    CupertinoPageRoute(
                      builder: (_) => NoteDetailScreen(existingNote: note),
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notes_rounded,
                          size: 14,
                          color: Colors.white54,
                        ),
                        const SizedBox(width: 6),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 140),
                          child: Text(
                            note.title.isNotEmpty
                                ? note.title
                                : 'Untitled Note',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.inter(
                              fontSize: 12.5,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Alternative Section Card List View
  // ───────────────────────────────────────────────────────────────────────────
  Widget _buildTopicCardsView(List<NoteTopic> topics) {
    final collections = topics
        .where((topic) => topic.id.startsWith('collection_'))
        .length;
    final connectedNotes = topics
        .expand((topic) => topic.notes)
        .map((note) => note.noteId)
        .toSet()
        .length;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          margin: const EdgeInsets.only(bottom: 20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                AppColors.elevation2,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.glassBorderBright),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.bubble_chart_rounded, size: 27),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your knowledge, organized',
                      style: GoogleFonts.outfit(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$collections smart collections • $connectedNotes notes',
                      style: GoogleFonts.inter(
                        color: Colors.white70,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(4, 0, 4, 12),
          child: Text(
            'COLLECTIONS & CONNECTIONS',
            style: GoogleFonts.inter(
              color: AppColors.secondaryText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ),
        ...topics.map(_topicCard),
      ],
    );
  }

  Widget _topicCard(NoteTopic topic) {
    final confirmed = topic.status == SemanticSuggestionStatus.confirmed;
    final color = _topicColor(topic.label);
    return GestureDetector(
      onTap: () => _showTopicDetail(topic),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withValues(alpha: 0.18), AppColors.elevation1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.28),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(_topicIcon(topic.label), color: color, size: 21),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    topic.label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  '${topic.notes.length} notes',
                  style: GoogleFonts.inter(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
                if (!topic.id.startsWith('collection_'))
                  IconButton(
                    visualDensity: VisualDensity.compact,
                    tooltip: 'Rename topic',
                    onPressed: () => _renameTopic(topic),
                    icon: const Icon(
                      Icons.edit_rounded,
                      size: 16,
                      color: Colors.white54,
                    ),
                  ),
              ],
            ),
            if (topic.summary.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                topic.summary,
                style: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 12.5,
                ),
              ),
            ],
            const SizedBox(height: 12),
            ...topic.notes
                .take(4)
                .map(
                  (note) => InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (_) => NoteDetailScreen(existingNote: note),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.notes_rounded,
                            color: Colors.white54,
                            size: 16,
                          ),
                          const SizedBox(width: 9),
                          Expanded(
                            child: Text(
                              note.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.inter(
                                color: Colors.white,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.white30,
                            size: 18,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            if (topic.notes.length > 4)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  '+ ${topic.notes.length - 4} more',
                  style: GoogleFonts.inter(
                    color: AppColors.secondaryText,
                    fontSize: 12,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'View connected notes',
                  style: GoogleFonts.inter(
                    color: color,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.arrow_forward_rounded, color: color, size: 17),
              ],
            ),
            if (!confirmed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _semantic.setTopicStatus(
                        topic.id,
                        SemanticSuggestionStatus.dismissed,
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.white12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Dismiss'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _semantic.setTopicStatus(
                        topic.id,
                        SemanticSuggestionStatus.confirmed,
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.check_rounded, size: 16),
                      label: const Text('Keep Topic'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _topicColor(String label) {
    final value = label.toLowerCase();
    if (value.contains('reminder')) return AppColors.accentOrange;
    if (value.contains('check') || value.contains('task')) {
      return AppColors.accentGreen;
    }
    if (value.contains('event') || value.contains('plan')) {
      return AppColors.accentBlue;
    }
    if (value.contains('idea')) return const Color(0xFFFFD60A);
    if (value.contains('project')) return AppColors.accentPurple;
    if (value.contains('meeting')) return const Color(0xFF64D2FF);
    if (value.contains('document')) return const Color(0xFFFF453A);
    return Theme.of(context).colorScheme.primary;
  }

  void _showTopicDetail(NoteTopic topic) {
    final color = _topicColor(topic.label);
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => DraggableScrollableSheet(
        initialChildSize: 0.78,
        minChildSize: 0.48,
        maxChildSize: 0.94,
        expand: false,
        builder: (context, controller) => Container(
          decoration: const BoxDecoration(
            color: AppColors.elevation1,
            borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
          ),
          child: ListView(
            controller: controller,
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 30),
            children: [
              Center(
                child: Container(
                  width: 38,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: Icon(
                      _topicIcon(topic.label),
                      color: color,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          topic.label,
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${topic.notes.length} connected notes',
                          style: GoogleFonts.inter(
                            color: AppColors.secondaryText,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (topic.summary.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  topic.summary,
                  style: GoogleFonts.inter(
                    color: Colors.white70,
                    fontSize: 13.5,
                    height: 1.45,
                  ),
                ),
              ],
              const SizedBox(height: 22),
              Text(
                'CONNECTED NOTES',
                style: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),
              ...topic.notes.map(
                (note) => Padding(
                  padding: const EdgeInsets.only(bottom: 9),
                  child: Material(
                    color: AppColors.elevation2,
                    borderRadius: BorderRadius.circular(17),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(17),
                      onTap: () {
                        Navigator.pop(sheetContext);
                        Navigator.of(this.context).push(
                          CupertinoPageRoute(
                            builder: (_) =>
                                NoteDetailScreen(existingNote: note),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Icon(
                              note.tags.any(
                                    (tag) =>
                                        tag.toLowerCase().contains('reminder'),
                                  )
                                  ? Icons.notifications_active_rounded
                                  : note.checklist.isNotEmpty
                                  ? Icons.checklist_rounded
                                  : Icons.note_rounded,
                              color: color,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    note.title.isEmpty
                                        ? 'Untitled Note'
                                        : note.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (note.summarySnippet.isNotEmpty)
                                    Text(
                                      note.summarySnippet,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: GoogleFonts.inter(
                                        color: AppColors.secondaryText,
                                        fontSize: 12,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Colors.white30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _renameTopic(NoteTopic topic) async {
    final controller = TextEditingController(text: topic.label);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1E),
        title: Text(
          'Rename topic',
          style: GoogleFonts.outfit(color: Colors.white),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
          style: const TextStyle(color: Colors.white),
          textCapitalization: TextCapitalization.words,
          decoration: const InputDecoration(hintText: 'Topic name'),
          onSubmitted: (value) => Navigator.pop(context, value),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (value != null) await _semantic.renameTopic(topic, value);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom Painter for Neural Constellation & Connections
// ─────────────────────────────────────────────────────────────────────────────
class _KnowledgeGraphPainter extends CustomPainter {
  final Offset center;
  final List<NoteTopic> topics;
  final double radius;
  final double pulse;
  final Color accent;
  final NoteTopic? selectedTopic;

  _KnowledgeGraphPainter({
    required this.center,
    required this.topics,
    required this.radius,
    required this.pulse,
    required this.accent,
    required this.selectedTopic,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Orbital guidance circle
    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.04)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    canvas.drawCircle(center, radius, orbitPaint);

    // 2. Pulse aura around brain
    final auraPaint = Paint()
      ..color = accent.withValues(alpha: 0.03 + (pulse * 0.03))
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * (0.6 + pulse * 0.1), auraPaint);

    if (topics.isEmpty) return;

    // 3. Connective neural lines from center brain to topic nodes
    for (var i = 0; i < topics.length; i++) {
      final topic = topics[i];
      final isSelected = selectedTopic?.id == topic.id;
      final angle = (2 * math.pi / topics.length) * i - (math.pi / 2);
      final nodePos = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );

      final linePaint = Paint()
        ..color = isSelected
            ? accent.withValues(alpha: 0.8)
            : Colors.white.withValues(alpha: 0.12)
        ..strokeWidth = isSelected ? 2.0 : 1.0;

      canvas.drawLine(center, nodePos, linePaint);

      // Connect neighboring nodes to form a constellation web
      final nextAngle =
          (2 * math.pi / topics.length) * ((i + 1) % topics.length) -
          (math.pi / 2);
      final nextPos = Offset(
        center.dx + radius * math.cos(nextAngle),
        center.dy + radius * math.sin(nextAngle),
      );
      final webPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.05)
        ..strokeWidth = 0.8;
      canvas.drawLine(nodePos, nextPos, webPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _KnowledgeGraphPainter oldDelegate) {
    return oldDelegate.pulse != pulse ||
        oldDelegate.selectedTopic?.id != selectedTopic?.id ||
        oldDelegate.topics.length != topics.length;
  }
}

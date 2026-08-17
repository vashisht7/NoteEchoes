import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../ai/domain/semantic_models.dart';
import '../ai/infrastructure/semantic_knowledge_service.dart';
import '../services/note_service.dart';
import '../theme/app_colors.dart';
import 'note_detail_screen.dart';

class TopicsScreen extends StatefulWidget {
  const TopicsScreen({super.key});

  @override
  State<TopicsScreen> createState() => _TopicsScreenState();
}

class _TopicsScreenState extends State<TopicsScreen> {
  final _semantic = SemanticKnowledgeService.instance;
  final _notes = NoteService();

  @override
  void initState() {
    super.initState();
    _semantic.addListener(_refresh);
  }

  @override
  void dispose() {
    _semantic.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepMatteBlack,
        title: Text(
          'Topics',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: [
          if (_semantic.isIndexing)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Semantics(
                  label:
                      'Organizing notes ${(_semantic.progress * 100).round()} percent',
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      value: _semantic.progress,
                      strokeWidth: 2,
                    ),
                  ),
                ),
              ),
            ),
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
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 36),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 18),
                child: Text(
                  'Private, on-device suggestions. Confirm what feels right or dismiss anything that does not.',
                  style: GoogleFonts.inter(
                    color: AppColors.secondaryText,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
              ),
              ...topics.map(_topicCard),
            ],
          );
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
                  ? 'Understanding your notes…'
                  : 'No topic groups yet',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Two or more meaningfully related notes are needed. Suggestions appear automatically as your collection grows.',
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

  Widget _topicCard(NoteTopic topic) {
    final confirmed = topic.status == SemanticSuggestionStatus.confirmed;
    return Semantics(
      container: true,
      label:
          '${topic.label}, ${topic.notes.length} related notes, ${confirmed ? 'confirmed' : 'suggested'} topic',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.elevation1,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: confirmed
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)
                : AppColors.glassBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  confirmed
                      ? Icons.folder_special_rounded
                      : Icons.auto_awesome_rounded,
                  color: Theme.of(context).colorScheme.primary,
                  size: 19,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    topic.label,
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 18,
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
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Rename topic',
                  onPressed: () => _renameTopic(topic),
                  icon: const Icon(
                    Icons.edit_rounded,
                    size: 17,
                    color: Colors.white54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Text(
              topic.summary,
              style: GoogleFonts.inter(
                color: AppColors.secondaryText,
                fontSize: 12.5,
              ),
            ),
            const SizedBox(height: 12),
            ...topic.notes
                .take(4)
                .map(
                  (note) => Semantics(
                    button: true,
                    label: 'Open ${note.title}',
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.of(context).push(
                        CupertinoPageRoute(
                          builder: (_) => NoteDetailScreen(existingNote: note),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.notes_rounded,
                              color: Colors.white54,
                              size: 17,
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                note.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                ),
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
            if (topic.notes.length > 4)
              Text(
                '+ ${topic.notes.length - 4} more',
                style: GoogleFonts.inter(
                  color: AppColors.secondaryText,
                  fontSize: 12,
                ),
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
                      child: const Text('Not related'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () => _semantic.setTopicStatus(
                        topic.id,
                        SemanticSuggestionStatus.confirmed,
                      ),
                      icon: const Icon(Icons.check_rounded, size: 17),
                      label: const Text('Keep section'),
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

  Future<void> _renameTopic(NoteTopic topic) async {
    final controller = TextEditingController(text: topic.label);
    final value = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename topic'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 60,
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

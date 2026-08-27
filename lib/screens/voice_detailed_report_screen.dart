import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/note_model.dart';
import '../services/note_service.dart';
import '../services/voice_assistant_service.dart';
import '../theme/app_colors.dart';

class VoiceDetailedReportScreen extends StatefulWidget {
  const VoiceDetailedReportScreen({
    super.key,
    this.embedded = false,
    this.scrollController,
  });

  final bool embedded;
  final ScrollController? scrollController;

  @override
  State<VoiceDetailedReportScreen> createState() =>
      _VoiceDetailedReportScreenState();
}

class _VoiceDetailedReportScreenState extends State<VoiceDetailedReportScreen> {
  final VoiceAssistantService _voiceService = VoiceAssistantService();
  late final ScrollController _scrollController;
  late final bool _ownsScrollController;
  bool _copied = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _voiceService.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(
      ClipboardData(text: _voiceService.fullGeneratedResponse),
    );
    await HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  Future<void> _saveReport() async {
    if (_saved || _voiceService.fullGeneratedResponse.trim().isEmpty) return;
    final now = DateTime.now();
    final compact = _voiceService.fullGeneratedResponse
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    await NoteService().addNote(
      NoteModel(
        noteId: 'conversation-${now.microsecondsSinceEpoch}',
        title: _voiceService.summaryTitle,
        contentType: NoteContentType.textOnly,
        summarySnippet: compact.length <= 180
            ? compact
            : '${compact.substring(0, 179).trimRight()}…',
        textContent: _voiceService.fullGeneratedResponse,
        createdAt: now,
        tags: const ['conversation-report'],
      ),
    );
    await HapticFeedback.lightImpact();
    if (mounted) setState(() => _saved = true);
  }

  @override
  void dispose() {
    _voiceService.removeListener(_refresh);
    if (_ownsScrollController) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final blocks = _reportBlocks(_voiceService.fullGeneratedResponse);
    final audioError = _voiceService.audioOutputError;

    return Scaffold(
      backgroundColor: const Color(0xFF090A0D),
      appBar: AppBar(
        toolbarHeight: 56,
        backgroundColor: const Color(0xFF090A0D),
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? IconButton(
                tooltip: 'Close report',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.keyboard_arrow_down_rounded),
              )
            : null,
        title: Text(
          widget.embedded ? 'Report ready' : 'Report',
          style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        actions: widget.embedded
            ? [
                IconButton(
                  tooltip: 'Open full screen',
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const VoiceDetailedReportScreen(),
                    ),
                  ),
                  icon: const Icon(Icons.open_in_full_rounded, size: 19),
                ),
              ]
            : null,
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: SelectionArea(
                child: ListView(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(22, 14, 22, 36),
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: .12),
                            borderRadius: BorderRadius.circular(13),
                            border: Border.all(
                              color: accent.withValues(alpha: .20),
                            ),
                          ),
                          child: Icon(
                            Icons.auto_awesome_rounded,
                            size: 18,
                            color: accent,
                          ),
                        ),
                        const SizedBox(width: 13),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _voiceService.summaryTitle,
                                style: GoogleFonts.outfit(
                                  fontSize: 25,
                                  height: 1.12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primaryText,
                                ),
                              ),
                              const SizedBox(height: 7),
                              Text(
                                _voiceService.reportSourceLabel,
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.secondaryText,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 26),
                    Divider(color: Colors.white.withValues(alpha: .08)),
                    const SizedBox(height: 10),
                    ...blocks.map((block) => _ReportBlockView(block: block)),
                    if (audioError != null) ...[
                      const SizedBox(height: 18),
                      Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9F0A).withValues(alpha: .09),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: const Color(
                              0xFFFF9F0A,
                            ).withValues(alpha: .18),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.volume_off_rounded,
                              size: 18,
                              color: Color(0xFFFF9F0A),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                audioError,
                                style: GoogleFonts.inter(
                                  fontSize: 12.5,
                                  height: 1.4,
                                  color: AppColors.primaryText,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            _ReportActionBar(
              copied: _copied,
              saved: _saved,
              onListen: _voiceService.restartKaraoke,
              onCopy: _copyReport,
              onSave: _saveReport,
            ),
          ],
        ),
      ),
    );
  }
}

enum _ReportBlockKind { heading, bullet, paragraph }

class _ReportBlock {
  const _ReportBlock(this.kind, this.text);
  final _ReportBlockKind kind;
  final String text;
}

List<_ReportBlock> _reportBlocks(String report) {
  const headings = {
    'Summary',
    'Key points',
    'Sources',
    'सारांश',
    'मुख्य बातें',
    'स्रोत नोट्स',
    'సారాంశం',
    'ముఖ్య విషయాలు',
    'మూల నోట్స్',
  };
  return report
      .split(RegExp(r'\n+'))
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((line) {
        if (headings.contains(line)) {
          return _ReportBlock(_ReportBlockKind.heading, line);
        }
        if (line.startsWith('•') || line.startsWith('- ')) {
          return _ReportBlock(
            _ReportBlockKind.bullet,
            line.replaceFirst(RegExp(r'^[•-]\s*'), ''),
          );
        }
        return _ReportBlock(_ReportBlockKind.paragraph, line);
      })
      .toList();
}

class _ReportBlockView extends StatelessWidget {
  const _ReportBlockView({required this.block});
  final _ReportBlock block;

  @override
  Widget build(BuildContext context) {
    if (block.kind == _ReportBlockKind.heading) {
      return Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(
          block.text.toUpperCase(),
          style: GoogleFonts.inter(
            fontSize: 11,
            letterSpacing: 1.15,
            fontWeight: FontWeight.w700,
            color: AppColors.secondaryText,
          ),
        ),
      );
    }
    if (block.kind == _ReportBlockKind.bullet) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 9, right: 11),
              decoration: const BoxDecoration(
                color: AppColors.secondaryText,
                shape: BoxShape.circle,
              ),
            ),
            Expanded(child: _ReportText(block.text, size: 15.5)),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: _ReportText(block.text, size: 17),
    );
  }
}

class _ReportText extends StatelessWidget {
  const _ReportText(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: GoogleFonts.inter(
      fontSize: size,
      height: 1.58,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryText.withValues(alpha: .91),
    ),
  );
}

class _ReportActionBar extends StatelessWidget {
  const _ReportActionBar({
    required this.copied,
    required this.saved,
    required this.onListen,
    required this.onCopy,
    required this.onSave,
  });

  final bool copied;
  final bool saved;
  final VoidCallback onListen;
  final VoidCallback onCopy;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF0D0E12),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: FilledButton.icon(
              key: const ValueKey('replay_detailed_report_button'),
              onPressed: onListen,
              icon: const Icon(Icons.replay_rounded, size: 18),
              label: const Text('Replay'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filledTonal(
            tooltip: saved ? 'Saved' : 'Save report',
            onPressed: saved ? null : onSave,
            icon: Icon(
              saved ? Icons.check_rounded : Icons.bookmark_border_rounded,
            ),
          ),
          const SizedBox(width: 4),
          IconButton.filledTonal(
            key: const ValueKey('copy_detailed_report_button'),
            tooltip: copied ? 'Copied' : 'Copy report',
            onPressed: onCopy,
            icon: Icon(copied ? Icons.check_rounded : Icons.copy_rounded),
          ),
        ],
      ),
    );
  }
}

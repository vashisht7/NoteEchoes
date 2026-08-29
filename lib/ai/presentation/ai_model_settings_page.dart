// ai_model_settings_page.dart
// Settings page for managing local AI model downloads, verification
// and device tier information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/ai_runtime_config.dart';
import '../config/action_model_identity.dart';
import '../infrastructure/qwen_llama_provider.dart';
import '../infrastructure/model_availability_service.dart';
import '../infrastructure/e5_embedding_service.dart';
import '../infrastructure/semantic_knowledge_service.dart';
import '../infrastructure/offline_speech_bridge.dart';
import '../../services/note_service.dart';

class AiModelSettingsPage extends StatefulWidget {
  const AiModelSettingsPage({super.key});

  @override
  State<AiModelSettingsPage> createState() => _AiModelSettingsPageState();
}

class _AiModelSettingsPageState extends State<AiModelSettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final _runtime = AiRuntimeConfig.instance;
  final _models = ModelAvailabilityService.instance;
  final _embedder = E5EmbeddingService.instance;
  final _semantic = SemanticKnowledgeService.instance;
  final _speechBridge = OfflineSpeechBridge.instance;

  // Live state tracking for models
  bool _qwenDownloading = false;
  double _qwenProgress = 0.0;
  String _qwenStatusText = '';
  StreamSubscription<WhisperDownloadProgress>? _whisperProgressSub;
  StreamSubscription<Map<String, dynamic>>? _qwenProgressSub;
  bool _whisperInstalled = false;
  bool _whisperDownloading = false;
  double _whisperProgress = 0.0;
  String _whisperStatusText = '';
  bool _qwenInstalled = false;
  String? _qwenWarning;
  String? _whisperWarning;
  bool _embeddingInstalled = false;
  String? _embeddingWarning;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
    _embedder.addListener(_onEmbeddingProgress);
    _semantic.addListener(_onEmbeddingProgress);
    _setupSpeechChannelListener();
    _syncModelStatus();
  }

  void _setupSpeechChannelListener() {
    _whisperProgressSub?.cancel();
    _whisperProgressSub = _speechBridge.progressStream.listen((event) {
      if (mounted) {
        setState(() {
          _whisperDownloading = true;
          _whisperProgress = event.progress;
          _whisperStatusText = event.statusText;
        });
      }
    });

    _qwenProgressSub?.cancel();
    _qwenProgressSub = QwenLlamaProvider.instance.progressStream.listen((
      event,
    ) {
      if (mounted) {
        setState(() {
          _qwenDownloading = true;
          _qwenProgress =
              (event['progress'] as num?)?.toDouble() ?? _qwenProgress;
          _qwenStatusText = (event['statusText'] as String?) ?? _qwenStatusText;
        });
      }
    });
  }

  @override
  void dispose() {
    _whisperProgressSub?.cancel();
    _qwenProgressSub?.cancel();
    _embedder.removeListener(_onEmbeddingProgress);
    _semantic.removeListener(_onEmbeddingProgress);
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _fadeCtrl.stop();
      _fadeCtrl.value = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A0C),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          color: Colors.white70,
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Local AI Models & Downloads',
          style: GoogleFonts.inter(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _DeviceTierCard(tier: _runtime.tier),
            const SizedBox(height: 20),
            const _SectionHeader('Available Without Downloads'),
            const SizedBox(height: 8),
            const _ModelCard(
              name: 'Core Notes & Keyword Search',
              description:
                  'Writing, tables, checklists, automatic basic categories, tags, and exact keyword search always work.',
              size: '0 MB added',
              languages: ['No model required', 'Always available'],
              isInstalled: true,
              isDownloading: false,
              downloadProgress: 1,
              statusText: '',
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Offline Speech Recognition'),
            const SizedBox(height: 8),
            _ModelCard(
              name: 'Apple / Shortcut Transcription',
              description:
                  'Your Action Button Shortcut transcribes the recording and sends Unicode text. '
                  'The app saves that text in any language without another bundled speech model.',
              size: '0 MB added',
              languages: ['Multilingual', 'Uses selected Shortcut language'],
              isInstalled: true,
              isDownloading: false,
              downloadProgress: 1,
              statusText: '',
            ),
            const SizedBox(height: 10),
            _ModelCard(
              name: 'Whisper Base Multilingual',
              description:
                  'Multilingual Whisper Base; accuracy varies by language and audio quality. '
                  'Recognizes Telugu, English, Hindi and code-mixed speech fully on-device.',
              size: '147 MB download',
              languages: [
                'Telugu',
                'English',
                'Hindi',
                'Multilingual (Telugu & English Mixed)',
              ],
              isInstalled: _whisperInstalled,
              isDownloading: _whisperDownloading,
              downloadProgress: _whisperDownloading
                  ? (_whisperProgress > 0 ? _whisperProgress : 0.05)
                  : 0,
              statusText: _whisperStatusText,
              warningText: _whisperWarning,
              onDownload: _whisperDownloading ? null : _startWhisperDownload,
              onDelete: _whisperInstalled ? _disableWhisper : null,
            ),
            const SizedBox(height: 20),
            const _SectionHeader('Semantic Topics & Related Notes'),
            const SizedBox(height: 8),
            _ModelCard(
              name: 'Multilingual E5 Small (8-bit)',
              description:
                  'Creates private meaning fingerprints so related notes can be linked and grouped into suggested topics, even across different wording.',
              size: '123 MB download',
              languages: ['94 languages', 'English', 'Telugu', 'Hindi'],
              isInstalled: _embeddingInstalled,
              isDownloading: _embedder.isDownloading,
              downloadProgress: _embedder.downloadProgress,
              statusText: _embedder.isDownloading
                  ? 'Downloading and verifying semantic model…'
                  : SemanticKnowledgeService.instance.isIndexing
                  ? 'Organizing notes ${(SemanticKnowledgeService.instance.progress * 100).round()}%'
                  : '',
              warningText: _embeddingWarning,
              onDownload: _embedder.isDownloading
                  ? null
                  : _startEmbeddingDownload,
              onDelete: _embeddingInstalled ? _deleteEmbedding : null,
            ),
            const SizedBox(height: 20),
            const _SectionHeader('On-Device NoteEchoes Intelligence'),
            const SizedBox(height: 8),
            _ModelCard(
              name: NoteEchoesActionModelIdentity.displayName,
              description:
                  'One verified action engine for clean voice notes, tasks, reminders, '
                  'checklists, grocery lists, grounded memory routing, and safe confirmations.',
              size: NoteEchoesActionModelIdentity.downloadSize,
              languages: [
                'English',
                'Telugu',
                'Hindi',
                'Telugu-English & Hindi-English',
              ],
              isInstalled: _qwenInstalled,
              isDownloading: _qwenDownloading,
              downloadProgress: _qwenProgress,
              statusText: _qwenStatusText,
              warningText: _qwenWarning,
              onDownload: _runtime.llmSupported ? _startQwenDownload : null,
              onCancel: _qwenDownloading ? _cancelQwenDownload : null,
              onDelete: _qwenInstalled ? _deleteQwen : null,
              notAvailableReason: _runtime.llmSupported
                  ? null
                  : 'Requires 4 GB RAM or more',
            ),
            const SizedBox(height: 24),
            const _SectionHeader('Security & Privacy Guarantee'),
            const SizedBox(height: 8),
            _PrivacyInfoCard(),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  // ── Download & Lifecycle Orchestration ─────────────────────────────────

  Future<void> _syncModelStatus() async {
    await _models.refresh();
    if (!mounted) return;
    setState(() {
      _qwenInstalled = _models.qwen.isReady;
      _whisperInstalled = _models.whisper.isReady;
      _embeddingInstalled = _models.embedding.isReady;
      _qwenWarning = _models.qwen.health == ModelHealth.needsRepair
          ? _models.qwen.reason
          : null;
      _whisperWarning = _models.whisper.health == ModelHealth.needsRepair
          ? _models.whisper.reason
          : null;
      _embeddingWarning = _models.embedding.health == ModelHealth.needsRepair
          ? _models.embedding.reason
          : null;
    });
  }

  void _onEmbeddingProgress() {
    if (mounted) setState(() {});
  }

  void _startEmbeddingDownload() {
    _showDownloadSheet(
      modelName: 'Multilingual E5 Small (8-bit)',
      modelSize: '123 MB',
      details:
          'Downloads an MIT-licensed multilingual embedding model. It runs fully on-device to find related notes and suggest topic sections. Notes are never uploaded.',
      onConfirm: () async {
        try {
          await _embedder.download();
          await _syncModelStatus();
          await SemanticKnowledgeService.instance.indexAll(
            NoteService().allNotes,
          );
          if (mounted) {
            _showToast('Semantic Topics and Related Notes are ready.');
          }
        } catch (error) {
          if (mounted) _showToast('Semantic model download failed: $error');
        }
      },
    );
  }

  Future<void> _deleteEmbedding() async {
    final confirmed = await _showDeleteDialog(
      'Multilingual E5 Small',
      'This removes the semantic model. Your notes remain safe; topic suggestions pause until it is downloaded again.',
    );
    if (confirmed == true) {
      await _models.removeEmbedding();
      if (!mounted) return;
      await _syncModelStatus();
      _showToast('Semantic model files were removed.');
    }
  }

  void _startWhisperDownload() {
    _showDownloadSheet(
      modelName: 'Whisper Base Multilingual',
      modelSize: '147 MB',
      details:
          'Downloads the Apple Core ML Whisper Base model. It recognizes Telugu, '
          'English and Hindi locally and transcribes the complete recorded file.',
      onConfirm: () async {
        setState(() {
          _whisperDownloading = true;
          _whisperProgress = 0.05;
          _whisperStatusText = 'Connecting to Hugging Face model repository…';
        });
        try {
          await _speechBridge.downloadWhisperBase();
          if (!mounted) return;
          await _syncModelStatus();
          final isReady = _models.whisper.isReady;
          setState(() {
            _whisperDownloading = false;
            _whisperProgress = isReady ? 1.0 : 0.0;
            _whisperStatusText = '';
            _whisperInstalled = isReady;
          });
          _showToast(
            isReady
                ? 'Whisper Multilingual is ready! Telugu, English & mixed speech enabled.'
                : 'Download completed — verified status: ${_models.whisper.reason.isNotEmpty ? _models.whisper.reason : "Ready"}',
          );
        } catch (error) {
          if (!mounted) return;
          await _syncModelStatus();
          setState(() {
            _whisperDownloading = false;
            _whisperProgress = 0;
            _whisperStatusText = '';
          });
          _showToast('Speech model download failed: $error');
        }
      },
    );
  }

  Future<void> _disableWhisper() async {
    final confirmed = await _showDeleteDialog(
      'Whisper Base Multilingual',
      'This removes the offline model files. Apple Speech transcription will continue to work.',
    );
    if (confirmed == true) {
      await _models.removeWhisper();
      if (!mounted) return;
      await _syncModelStatus();
      _showToast('Whisper model files were removed.');
    }
  }

  void _startQwenDownload() {
    _showDownloadSheet(
      modelName: NoteEchoesActionModelIdentity.displayName,
      modelSize: '649 MB',
      details:
          'Downloads the exact evaluated NoteEchoes model from Hugging Face, then verifies '
          'every runtime file before enabling it. Keep NoteEchoes open during this one-time '
          'download and allow at least 2 GB of free storage during installation.',
      onConfirm: () async {
        setState(() {
          _qwenDownloading = true;
          _qwenProgress = 0.0;
          _qwenStatusText = 'Connecting to model repository…';
        });

        try {
          await QwenLlamaProvider.instance.load();
          await _syncModelStatus();
          // Re-organize, analyze and index all existing notes with the newly installed brain
          final allNotes = NoteService().allNotes;
          if (allNotes.isNotEmpty) {
            await SemanticKnowledgeService.instance.indexAll(allNotes);
          }
          if (!mounted) return;
          setState(() {
            _qwenDownloading = false;
            _qwenProgress = 1.0;
            _qwenStatusText = '';
          });
          _showToast(
            'NoteEchoes multilingual action model is verified and ready. Reindexed ${allNotes.length} notes.',
          );
        } catch (error) {
          if (!mounted) return;
          setState(() {
            _qwenDownloading = false;
            _qwenProgress = 0;
            _qwenStatusText = '';
          });
          _showToast('Model download failed: $error');
        }
      },
    );
  }

  Future<void> _cancelQwenDownload() async {
    await QwenLlamaProvider.instance.cancelDownload();
    if (!mounted) return;
    setState(() {
      _qwenDownloading = false;
      _qwenProgress = 0;
      _qwenStatusText = 'Download cancelled. Tap Download to retry.';
    });
    _showToast('Model download cancelled. Tap Download to retry.');
  }

  Future<void> _deleteQwen() async {
    final confirmed = await _showDeleteDialog(
      NoteEchoesActionModelIdentity.displayName,
      'This removes the downloaded model files. Basic keyword search and Apple transcription will continue to work.',
    );
    if (confirmed == true) {
      await _models.removeQwen();
      if (!mounted) return;
      await _syncModelStatus();
      _showToast('NoteEchoes multilingual action model files were removed.');
    }
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF1E1E24),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text(
          msg,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  Future<bool?> _showDeleteDialog(String title, String message) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF151518),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete $title?',
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        content: Text(
          message,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: GoogleFonts.inter(color: Colors.white60),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF4D4D),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDownloadSheet({
    required String modelName,
    required String modelSize,
    required String details,
    required Future<void> Function() onConfirm,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF151518),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.cloud_download_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Download $modelName',
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Size: $modelSize (One-time download)',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Colors.white38,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              details,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: Colors.white70,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.white24),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.inter(color: Colors.white70),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onConfirm();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Download & Enable',
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: Colors.white38,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DeviceTierCard extends StatelessWidget {
  final DeviceTier tier;
  const _DeviceTierCard({required this.tier});

  String get _tierLabel {
    switch (tier) {
      case DeviceTier.tierA:
        return 'Tier A — Full Local AI';
      case DeviceTier.tierB:
        return 'Tier B — Standard AI';
      case DeviceTier.tierC:
        return 'Tier C — Speech Mode';
    }
  }

  String get _tierDescription {
    switch (tier) {
      case DeviceTier.tierA:
        return 'Your device has ≥ 6 GB RAM and supports local Qwen3 MLX acceleration.';
      case DeviceTier.tierB:
        return 'Your device supports the local Qwen3 model with sequential job execution.';
      case DeviceTier.tierC:
        return 'Speech mode active. Basic features work without any downloaded models.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.memory_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tierLabel,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tierDescription,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: Colors.white54,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelCard extends StatelessWidget {
  final String name;
  final String description;
  final String size;
  final List<String> languages;
  final bool isInstalled;
  final bool isDownloading;
  final double downloadProgress;
  final String statusText;
  final String? warningText;
  final VoidCallback? onDownload;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;
  final String? notAvailableReason;

  const _ModelCard({
    required this.name,
    required this.description,
    required this.size,
    required this.languages,
    required this.isInstalled,
    required this.isDownloading,
    required this.downloadProgress,
    required this.statusText,
    this.warningText,
    this.onDownload,
    this.onCancel,
    this.onDelete,
    this.notAvailableReason,
  });

  @override
  Widget build(BuildContext context) {
    final isUnavailable = onDownload == null && !isInstalled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isUnavailable ? Colors.white38 : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      size,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: Colors.white38,
                      ),
                    ),
                  ],
                ),
              ),
              if (isInstalled)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_rounded,
                        color: Colors.white70,
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Ready',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            description,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: isUnavailable ? Colors.white24 : Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: languages
                .map(
                  (l) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      l,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: Colors.white54,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          if (notAvailableReason != null) ...[
            const SizedBox(height: 10),
            Text(
              '⚠ $notAvailableReason',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFFF9F0A),
              ),
            ),
          ],
          if (warningText != null) ...[
            const SizedBox(height: 10),
            Text(
              'Needs repair • $warningText',
              style: GoogleFonts.inter(
                fontSize: 12,
                color: const Color(0xFFFF9F0A),
                height: 1.4,
              ),
            ),
          ],

          // Download Progress Bar
          if (isDownloading) ...[
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: downloadProgress > 0 ? downloadProgress : null,
                backgroundColor: Colors.white12,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.primary,
                ),
                minHeight: 4,
              ),
            ),
            if (statusText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                statusText,
                style: GoogleFonts.inter(fontSize: 11, color: Colors.white54),
              ),
            ],
            if (onCancel != null) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onCancel,
                  icon: const Icon(Icons.pause_rounded, size: 16),
                  label: Text(
                    'Pause Download',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ],

          // Action Buttons
          if (!isUnavailable && !isInstalled && !isDownloading) ...[
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onDownload,
                icon: const Icon(Icons.download_rounded, size: 16),
                label: Text(
                  warningText == null ? 'Download ($size)' : 'Repair Model',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],

          if (isInstalled && onDelete != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 15,
                    color: Color(0xFFFF453A),
                  ),
                  label: Text(
                    'Delete Model',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFF453A),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _PrivacyInfoCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF2C2C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: Colors.white70,
              ),
              const SizedBox(width: 8),
              Text(
                '100% On-Device AI',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Your notes, audio recordings, and transcripts are never sent to any external server. '
            'Models run locally on your device neural engine / GPU and are excluded from iCloud backups.',
            style: GoogleFonts.inter(
              fontSize: 13,
              color: Colors.white54,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

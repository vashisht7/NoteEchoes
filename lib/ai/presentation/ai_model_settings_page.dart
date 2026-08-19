// ai_model_settings_page.dart
// Settings page for managing local AI model downloads, verification,
// and pluggable brain discovery in a dark macOS native aesthetic.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/ai_runtime_config.dart';
import '../infrastructure/qwen_llama_provider.dart';
import '../infrastructure/model_availability_service.dart';
import '../infrastructure/e5_embedding_service.dart';
import '../infrastructure/semantic_knowledge_service.dart';
import '../infrastructure/local_model_detector.dart';
import '../../services/note_service.dart';

const _kBg = Color(0xFF111113);
const _kGroupBg = Color(0xFF1C1C1E);
const _kDivider = Color(0xFF2C2C2E);
const _kLabelColor = Color(0xFFF5F5F7);
const _kSecondary = Color(0xFF8E8E93);

class AiModelSettingsPage extends StatefulWidget {
  const AiModelSettingsPage({super.key});

  @override
  State<AiModelSettingsPage> createState() => _AiModelSettingsPageState();
}

class _AiModelSettingsPageState extends State<AiModelSettingsPage> {
  final _runtime = AiRuntimeConfig.instance;
  final _models = ModelAvailabilityService.instance;
  final _embedder = E5EmbeddingService.instance;
  final _semantic = SemanticKnowledgeService.instance;

  bool _qwenDownloading = false;
  double _qwenProgress = 0.0;
  String _qwenStatusText = '';
  static const _speechChannel = MethodChannel('noteechoes/offline_speech');
  bool _whisperInstalled = false;
  bool _whisperDownloading = false;
  String _whisperStatusText = '';
  bool _qwenInstalled = false;
  String? _qwenWarning;
  String? _whisperWarning;
  bool _embeddingInstalled = false;
  String? _embeddingWarning;

  @override
  void initState() {
    super.initState();
    _embedder.addListener(_onEmbeddingProgress);
    _semantic.addListener(_onEmbeddingProgress);
    _syncModelStatus();
    LocalModelDetector.instance.scanForModels();
  }

  @override
  void dispose() {
    _embedder.removeListener(_onEmbeddingProgress);
    _semantic.removeListener(_onEmbeddingProgress);
    super.dispose();
  }

  void _onEmbeddingProgress() {
    if (mounted) setState(() {});
  }

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

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2C2C2E),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          msg,
          style: GoogleFonts.inter(fontSize: 13, color: Colors.white),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: Column(
          children: [
            // Top Navigation Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: _kBg,
                border: Border(bottom: BorderSide(color: _kDivider)),
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                    color: _kSecondary,
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Back to Settings',
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'AI Engine & Pluggable Brain',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _kLabelColor,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded, size: 18),
                    color: _kSecondary,
                    onPressed: () {
                      LocalModelDetector.instance.scanForModels();
                      _syncModelStatus();
                    },
                    tooltip: 'Scan for Local Models (Ollama, LM Studio)',
                  ),
                ],
              ),
            ),

            // Content List
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
                children: [
                  // Device Hardware Tier
                  _DeviceTierRow(tier: _runtime.tier),
                  const SizedBox(height: 24),

                  // Section: Pluggable Brain & Local LLM
                  _SectionHeader('Pluggable Brain & Local LLM'),
                  ListenableBuilder(
                    listenable: LocalModelDetector.instance,
                    builder: (context, _) {
                      final detector = LocalModelDetector.instance;
                      final models = detector.availableModels;
                      final active = detector.activeModel;

                      return Container(
                        decoration: BoxDecoration(
                          color: _kGroupBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            // Active status banner
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2C2C2E),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(Icons.psychology_rounded,
                                        size: 18, color: _kLabelColor),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          active != null
                                              ? 'Active: ${active.displayName}'
                                              : 'Offline Text Engine (No LLM)',
                                          style: GoogleFonts.inter(
                                            fontSize: 13.5,
                                            fontWeight: FontWeight.w600,
                                            color: _kLabelColor,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          active != null
                                              ? 'Running locally via ${active.engineType.name.toUpperCase()} (${active.tierLabel})'
                                              : 'Basic tags and note search work offline without downloads.',
                                          style: GoogleFonts.inter(
                                            fontSize: 11.5,
                                            color: _kSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1, color: _kDivider),

                            // Model Catalog List
                            ...models.map((model) {
                              final isSelected = active?.id == model.id;
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 12),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(
                                                    model.displayName,
                                                    style: GoogleFonts.inter(
                                                      fontSize: 13.5,
                                                      fontWeight: FontWeight.w500,
                                                      color: _kLabelColor,
                                                    ),
                                                  ),
                                                  if (model.isRecommended) ...[
                                                    const SizedBox(width: 8),
                                                    Container(
                                                      padding:
                                                          const EdgeInsets.symmetric(
                                                              horizontal: 6,
                                                              vertical: 2),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF2C2C2E),
                                                        borderRadius:
                                                            BorderRadius.circular(4),
                                                      ),
                                                      child: Text(
                                                        'RECOMMENDED',
                                                        style: GoogleFonts.inter(
                                                          fontSize: 9.5,
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.white70,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '${model.engineType.name.toUpperCase()} • ${model.tierLabel}',
                                                style: GoogleFonts.inter(
                                                  fontSize: 11.5,
                                                  color: _kSecondary,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        if (model.isInstalled)
                                          _MacButton(
                                            label: isSelected ? 'Active' : 'Select',
                                            isPrimary: !isSelected,
                                            onPressed: isSelected
                                                ? null
                                                : () =>
                                                    detector.setActiveModel(model),
                                          )
                                        else
                                          _MacButton(
                                            label: 'Download Guide',
                                            isPrimary: false,
                                            onPressed: () {
                                              _showToast(
                                                  'Run `ollama run gemma3:4b` or download via LM Studio to activate ${model.displayName}.');
                                            },
                                          ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                      height: 1,
                                      indent: 16,
                                      endIndent: 16,
                                      color: _kDivider),
                                ],
                              );
                            }),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Section: Offline Speech & Semantic Models
                  _SectionHeader('Speech & Semantic Models'),
                  Container(
                    decoration: BoxDecoration(
                      color: _kGroupBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Column(
                      children: [
                        // Apple Native SFSpeech
                        _ModelRow(
                          icon: Icons.mic_rounded,
                          title: 'Apple Speech Transcriber',
                          subtitle:
                              'Native macOS transcription engine. Works offline without added storage.',
                          size: '0 MB',
                          isInstalled: true,
                          isDownloading: false,
                          onDownload: null,
                        ),
                        const Divider(height: 1, indent: 52, color: _kDivider),

                        // Whisper Core ML
                        _ModelRow(
                          icon: Icons.graphic_eq_rounded,
                          title: 'Whisper Base (Core ML)',
                          subtitle:
                              'Enhanced multilingual audio transcriber with WhisperKit.',
                          size: '147 MB',
                          isInstalled: _whisperInstalled,
                          isDownloading: _whisperDownloading,
                          onDownload: _whisperDownloading
                              ? null
                              : () {
                                  _showToast(
                                      'Whisper Core ML downloads automatically when needed.');
                                },
                        ),
                        const Divider(height: 1, indent: 52, color: _kDivider),

                        // Multilingual E5 Small
                        _ModelRow(
                          icon: Icons.hub_rounded,
                          title: 'Multilingual E5 Small',
                          subtitle:
                              'Semantic topic clusters and related note discovery.',
                          size: '123 MB',
                          isInstalled: _embeddingInstalled,
                          isDownloading: _embedder.isDownloading,
                          onDownload: _embedder.isDownloading
                              ? null
                              : () async {
                                  try {
                                    await _embedder.download();
                                    await _syncModelStatus();
                                    _showToast(
                                        'Semantic embedding model ready.');
                                  } catch (e) {
                                    _showToast('Download failed: $e');
                                  }
                                },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Privacy Notice
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _kGroupBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 18, color: _kSecondary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Local Execution Guarantee: All downloaded models, transcriptions, and database indexes operate 100% locally on your Mac. Your private notes are never transmitted over the internet.',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: _kSecondary,
                              height: 1.45,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-components: macOS native widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String text;
  const _SectionHeader(this.text);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 8),
        child: Text(
          text.toUpperCase(),
          style: GoogleFonts.inter(
            color: _kSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.6,
          ),
        ),
      );
}

class _DeviceTierRow extends StatelessWidget {
  final DeviceTier tier;
  const _DeviceTierRow({required this.tier});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _kGroupBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(7),
            ),
            child: const Icon(Icons.memory_rounded, size: 16, color: _kLabelColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hardware Acceleration: Apple Silicon (${tier.name.toUpperCase()})',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _kLabelColor,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  'Unified memory acceleration ready for MLX, Metal and Core ML.',
                  style: GoogleFonts.inter(fontSize: 11.5, color: _kSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ModelRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String size;
  final bool isInstalled;
  final bool isDownloading;
  final VoidCallback? onDownload;

  const _ModelRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.size,
    required this.isInstalled,
    required this.isDownloading,
    required this.onDownload,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: const Color(0xFF2C2C2E),
              borderRadius: BorderRadius.circular(7),
            ),
            child: Icon(icon, size: 16, color: _kLabelColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w500,
                        color: _kLabelColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      size,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: _kSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(fontSize: 11.5, color: _kSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          if (isInstalled)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                'Installed',
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: Colors.white70,
                ),
              ),
            )
          else
            _MacButton(
              label: isDownloading ? 'Downloading…' : 'Download',
              isPrimary: true,
              onPressed: onDownload,
            ),
        ],
      ),
    );
  }
}

class _MacButton extends StatelessWidget {
  final String label;
  final bool isPrimary;
  final VoidCallback? onPressed;

  const _MacButton({
    required this.label,
    required this.isPrimary,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor:
            isPrimary ? const Color(0xFF2C2C2E) : const Color(0xFF1E1E20),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(6),
          side: BorderSide(
            color: isPrimary ? Colors.white24 : Colors.white12,
          ),
        ),
        elevation: 0,
      ),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

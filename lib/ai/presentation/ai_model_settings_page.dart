// ai_model_settings_page.dart
// Settings page for managing local AI model downloads, verification
// and device tier information.

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../config/ai_feature_flags.dart';
import '../config/ai_runtime_config.dart';
import '../infrastructure/qwen_llama_provider.dart';

class AiModelSettingsPage extends StatefulWidget {
  const AiModelSettingsPage({super.key});

  @override
  State<AiModelSettingsPage> createState() => _AiModelSettingsPageState();
}

class _AiModelSettingsPageState extends State<AiModelSettingsPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fadeAnim;

  final _flags = AiFeatureFlags.instance;
  final _runtime = AiRuntimeConfig.instance;

  // Live state tracking for models
  bool _qwenDownloading = false;
  double _qwenProgress = 0.0;
  String _qwenStatusText = '';

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  bool get _qwenInstalled => _flags.localLlmEnabled;

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
            const SizedBox(height: 20),
            const _SectionHeader('On-Device LLM (Summaries & Chat)'),
            const SizedBox(height: 8),
            _ModelCard(
              name: 'Qwen3-0.6B MLX 4-bit',
              description:
                  'Quantized neural model for instant structured note summaries, '
                  'calendar/event extraction, journal reflections, and grounded document Q&A.',
              size: '351 MB download',
              languages: ['Multilingual', 'English', 'Telugu', 'Hindi'],
              isInstalled: _qwenInstalled,
              isDownloading: _qwenDownloading,
              downloadProgress: _qwenProgress,
              statusText: _qwenStatusText,
              onDownload: _runtime.llmSupported ? _startQwenDownload : null,
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

  void _startQwenDownload() {
    _showDownloadSheet(
      modelName: 'Qwen3-0.6B MLX 4-bit',
      modelSize: '351 MB',
      details:
          'Downloads the local LLM weights for smart note summaries, auto-titling, '
          'action extraction, and offline document chat. Stored in Application Support.',
      onConfirm: () async {
        setState(() {
          _qwenDownloading = true;
          _qwenProgress = 0.0;
          _qwenStatusText = 'Connecting to model repository…';
        });

        try {
          await QwenLlamaProvider.instance.load();
          await _flags.setLocalLlmEnabled(true);
          await _flags.setNoteAnalysisEnabled(true);
          await _flags.setReminderExtractionEnabled(true);
          await _flags.setPdfIngestionEnabled(true);
          await _flags.setCrossNoteSearchEnabled(true);
          await _flags.setDocumentChatEnabled(true);
          if (!mounted) return;
          setState(() {
            _qwenDownloading = false;
            _qwenProgress = 1.0;
            _qwenStatusText = '';
          });
          _showToast(
            'Qwen3 MLX is ready for multilingual notes and document chat.',
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

  Future<void> _deleteQwen() async {
    final confirmed = await _showDeleteDialog(
      'Qwen3-0.6B MLX 4-bit',
      'This disables and unloads the local model. Its cached files remain available for a fast re-enable.',
    );
    if (confirmed == true) {
      await _flags.setLocalLlmEnabled(false);
      await QwenLlamaProvider.instance.unload();
      setState(() {});
      _showToast('Qwen MLX disabled and unloaded.');
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
                    color: const Color(0xFF6B5CFF).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.cloud_download_rounded,
                    color: Color(0xFF6B5CFF),
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
                      backgroundColor: const Color(0xFF6B5CFF),
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

  Color get _tierColor {
    switch (tier) {
      case DeviceTier.tierA:
        return const Color(0xFF4ADE80);
      case DeviceTier.tierB:
        return const Color(0xFFFBBF24);
      case DeviceTier.tierC:
        return const Color(0xFFFF6B6B);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: _tierColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _tierColor.withOpacity(0.5), blurRadius: 8),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _tierLabel,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _tierDescription,
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
  final VoidCallback? onDownload;
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
    this.onDownload,
    this.onDelete,
    this.notAvailableReason,
  });

  @override
  Widget build(BuildContext context) {
    final isUnavailable = onDownload == null && !isInstalled;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isInstalled
              ? const Color(0xFF4ADE80).withOpacity(0.4)
              : Colors.white10,
        ),
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
                    color: const Color(0xFF4ADE80).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: Color(0xFF4ADE80),
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Installed',
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF4ADE80),
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
                      color: Colors.white.withOpacity(0.06),
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
                color: const Color(0xFFFBBF24),
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
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF6B5CFF),
                ),
                minHeight: 6,
              ),
            ),
            if (statusText.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                statusText,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: const Color(0xFF6B5CFF),
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
                  'Download ($size)',
                  style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                ),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6B5CFF),
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
                    color: Color(0xFFFF6B6B),
                  ),
                  label: Text(
                    'Delete Model',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: const Color(0xFFFF6B6B),
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
        color: const Color(0xFF151518),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lock_outline_rounded,
                size: 16,
                color: Color(0xFF4ADE80),
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  int _lastActiveIndex = -1;

  @override
  void initState() {
    super.initState();
    _ownsScrollController = widget.scrollController == null;
    _scrollController = widget.scrollController ?? ScrollController();
    _voiceService.addListener(_handleSpeechUpdate);
    _lastActiveIndex = _voiceService.activeLyricIndex;
  }

  void _handleSpeechUpdate() {
    if (!mounted) return;
    final activeIndex = _voiceService.activeLyricIndex;
    setState(() {});
    if (activeIndex != _lastActiveIndex) {
      _lastActiveIndex = activeIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) => _followSpeech());
    }
  }

  void _followSpeech() {
    if (!_scrollController.hasClients) return;
    final target = (_voiceService.activeLyricIndex * 112.0).clamp(
      0.0,
      _scrollController.position.maxScrollExtent,
    );
    _scrollController.animateTo(
      target,
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 360),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _copyReport() async {
    await Clipboard.setData(
      ClipboardData(text: _voiceService.fullGeneratedResponse),
    );
    await HapticFeedback.mediumImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _voiceService.removeListener(_handleSpeechUpdate);
    if (_ownsScrollController) _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lines = _voiceService.aiLyricLines;
    final accent = Theme.of(context).colorScheme.primary;

    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      appBar: AppBar(
        backgroundColor: AppColors.deepMatteBlack,
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
          widget.embedded ? 'Report ready' : 'Detailed Report',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        actions: widget.embedded
            ? [
                IconButton(
                  tooltip: 'Open full screen',
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const VoiceDetailedReportScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.open_in_full_rounded),
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
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
                  itemCount: lines.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _voiceService.summaryTitle,
                              style: GoogleFonts.outfit(
                                fontSize: 28,
                                height: 1.1,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryText,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Generated from your notes on this device',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    final lineIndex = index - 1;
                    final line = lines[lineIndex];
                    final isActive =
                        lineIndex == _voiceService.activeLyricIndex;
                    final isPast = lineIndex < _voiceService.activeLyricIndex;
                    return AnimatedContainer(
                      duration: MediaQuery.of(context).disableAnimations
                          ? Duration.zero
                          : const Duration(milliseconds: 280),
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                      decoration: BoxDecoration(
                        color: isActive
                            ? accent.withValues(alpha: 0.12)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        border: Border(
                          left: BorderSide(
                            color: isActive ? accent : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                      child: Text(
                        line.text,
                        style: GoogleFonts.inter(
                          fontSize: 17,
                          height: 1.58,
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.w400,
                          color: isActive
                              ? AppColors.primaryText
                              : isPast
                              ? AppColors.secondaryText
                              : AppColors.primaryText.withValues(alpha: 0.78),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
              decoration: BoxDecoration(
                color: AppColors.deepMatteBlack,
                border: Border(
                  top: BorderSide(color: Colors.white.withValues(alpha: 0.07)),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const ValueKey('copy_detailed_report_button'),
                  onPressed: _copyReport,
                  icon: Icon(
                    _copied ? Icons.check_rounded : Icons.copy_rounded,
                  ),
                  label: Text(_copied ? 'Copied' : 'Copy report'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

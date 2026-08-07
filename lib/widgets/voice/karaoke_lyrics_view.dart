import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/voice_assistant_service.dart';
import '../../theme/app_colors.dart';

class KaraokeLyricsView extends StatefulWidget {
  final List<SpokenLyricLine> lyricLines;
  final int activeIndex;
  final bool isPlaying;
  final VoidCallback? onTogglePlayPause;
  final VoidCallback? onRestart;
  final Function(String)? onSaveAsNote;

  const KaraokeLyricsView({
    super.key,
    required this.lyricLines,
    required this.activeIndex,
    required this.isPlaying,
    this.onTogglePlayPause,
    this.onRestart,
    this.onSaveAsNote,
  });

  @override
  State<KaraokeLyricsView> createState() => _KaraokeLyricsViewState();
}

class _KaraokeLyricsViewState extends State<KaraokeLyricsView> {
  final ScrollController _scrollController = ScrollController();
  bool _isCopied = false;

  @override
  void didUpdateWidget(covariant KaraokeLyricsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.activeIndex != widget.activeIndex) {
      _scrollToActiveLine();
    }
  }

  void _scrollToActiveLine() {
    if (!_scrollController.hasClients || widget.lyricLines.isEmpty) return;
    final itemHeight = 110.0;
    final targetOffset = (widget.activeIndex * itemHeight) - 80.0;
    _scrollController.animateTo(
      targetOffset.clamp(0.0, _scrollController.position.maxScrollExtent),
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _copyFullTranscript() {
    final fullText = widget.lyricLines.map((e) => e.text).join("\n\n");
    Clipboard.setData(ClipboardData(text: fullText));
    HapticFeedback.mediumImpact();
    setState(() => _isCopied = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fullText = widget.lyricLines.map((e) => e.text).join("\n\n");

    return Column(
      children: [
        // 1. Header with Quick Actions: [ 📋 Copy Note ] and Audio Controls
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            children: [
              // Waveform speaker indicator 🔊
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.elevation2,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.isPlaying ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                      color: AppColors.dropletRed,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      widget.isPlaying ? "Speaking..." : "Paused",
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primaryText,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Quick Save as Note Action
              if (widget.onSaveAsNote != null) ...[
                GestureDetector(
                  onTap: () => widget.onSaveAsNote?.call(fullText),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: AppColors.elevation2,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bookmark_add_outlined, size: 14, color: AppColors.accentBlue),
                        const SizedBox(width: 5),
                        Text(
                          "Save Note",
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryText,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],

              // Floating Quick-Action Pill: [ 📋 Copy Note ]
              GestureDetector(
                onTap: _copyFullTranscript,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: _isCopied ? AppColors.accentGreen : AppColors.elevation2,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _isCopied ? AppColors.accentGreen : AppColors.glassBorderBright,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _isCopied
                            ? AppColors.accentGreen.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.4),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                        size: 14,
                        color: _isCopied ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _isCopied ? "Copied!" : "📋 Copy Note",
                        style: GoogleFonts.inter(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _isCopied ? Colors.black : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // 2. Synchronized Apple Music Karaoke Lyric Scroll Area
        Expanded(
          child: ShaderMask(
            shaderCallback: (rect) {
              return const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                  Colors.transparent,
                ],
                stops: [0.0, 0.08, 0.90, 1.0],
              ).createShader(rect);
            },
            blendMode: BlendMode.dstIn,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              itemCount: widget.lyricLines.length,
              itemBuilder: (context, index) {
                final line = widget.lyricLines[index];
                final isActive = index == widget.activeIndex;
                final isPast = index < widget.activeIndex;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: isActive
                          ? AppColors.dropletRed.withValues(alpha: 0.08)
                          : Colors.transparent,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spoken Karaoke Text Line
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOut,
                          style: GoogleFonts.outfit(
                            fontSize: isActive ? 28 : 21,
                            fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                            height: 1.32,
                            letterSpacing: isActive ? -0.5 : -0.2,
                            color: isActive
                                ? AppColors.highlightedLyric
                                : isPast
                                    ? AppColors.secondaryText.withValues(alpha: 0.65)
                                    : AppColors.dimmedLyric,
                            shadows: isActive
                                ? [
                                    Shadow(
                                      color: Colors.white.withValues(alpha: 0.7),
                                      blurRadius: 18,
                                    ),
                                    Shadow(
                                      color: AppColors.dropletRed.withValues(alpha: 0.4),
                                      blurRadius: 28,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Text(line.text),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),

        // 3. Bottom Playback Bar
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.elevation2.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: AppColors.glassBorderBright),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 16,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Replay Button
              IconButton(
                icon: const Icon(Icons.replay_rounded, color: AppColors.primaryText),
                onPressed: widget.onRestart,
                tooltip: "Replay response",
              ),
              const SizedBox(width: 16),

              // Play / Pause Toggle
              GestureDetector(
                onTap: widget.onTogglePlayPause,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.dropletRed,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.dropletRedSoft,
                        blurRadius: 14,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    widget.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 26,
                  ),
                ),
              ),

              const SizedBox(width: 16),

              // Done / Next Query Button
              TextButton.icon(
                icon: const Icon(Icons.mic_rounded, color: AppColors.nebulaCyan, size: 18),
                label: Text(
                  "New Query",
                  style: GoogleFonts.inter(
                    color: AppColors.nebulaCyan,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                onPressed: () {
                  VoiceAssistantService().transitionToListeningState();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

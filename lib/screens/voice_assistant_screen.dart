import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../models/note_node.dart';
import '../services/note_service.dart';
import '../services/voice_assistant_service.dart';
import '../theme/app_colors.dart';
import '../widgets/voice_visualizer_painter.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/presentation/model_feature_gate.dart';

class VoiceAssistantScreen extends StatefulWidget {
  final VoiceState currentState;
  final String? initialPrompt;

  const VoiceAssistantScreen({
    super.key,
    this.currentState = VoiceState.listening,
    this.initialPrompt,
  });

  @override
  State<VoiceAssistantScreen> createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with SingleTickerProviderStateMixin {
  late final VoiceAssistantService _voiceService;
  late final AnimationController _animationController;
  late VoiceState _state;

  // Candidate NoteNodes for Thinking State
  List<NoteNode> _candidateNodes = [];
  int _currentInsideOrbIndex = 0;
  Timer? _orbScanTimer;
  bool _isCopied = false;
  bool _didCheckAudio = false;

  // Thoughts revolving loop dynamically generated from real user notes
  List<String> get _thoughtSuggestions {
    final allNotes = NoteService().allNotes;
    if (allNotes.isEmpty) {
      return [
        "Summarize my recent thoughts",
        "Check my checklist tasks",
        "Review today's notes",
        "Find voice notes with action items",
      ];
    }
    final suggestions = <String>[];
    for (final note in allNotes.take(4)) {
      suggestions.add("Summarize: ${note.title}");
    }
    final allTags = NoteService().allTags.where((t) => t != 'All').toList();
    for (final tag in allTags.take(3)) {
      suggestions.add("Show all notes in #$tag");
    }
    if (suggestions.length < 4) {
      suggestions.add("Summarize all my notes");
      suggestions.add("Find pending checklist tasks");
    }
    return suggestions;
  }

  late final FixedExtentScrollController _wheelScrollController;
  final ScrollController _lyricsScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _state = widget.currentState;
    _voiceService = VoiceAssistantService();
    _voiceService.addListener(_onServiceUpdate);

    _wheelScrollController = FixedExtentScrollController(initialItem: 1000);

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _loadCandidateNodes();

    // Immediately start active listening on open
    _voiceService.startVoiceSession(initialPrompt: widget.initialPrompt);

    if (_state == VoiceState.thinking) {
      _startInsideOrbScanning();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations) {
      _animationController.stop();
      _animationController.value = 0.35;
    } else if (!_animationController.isAnimating) {
      _animationController.repeat();
    }
  }

  void _loadCandidateNodes() {
    final notes = NoteService().allNotes;
    _candidateNodes = notes.map((n) {
      return NoteNode(
        id: n.noteId,
        title: n.title,
        snippet: n.summarySnippet.isNotEmpty ? n.summarySnippet : n.textContent,
      );
    }).toList();
  }

  void _onServiceUpdate() {
    if (mounted) {
      final serviceState = _voiceService.state;
      final mappedState = serviceState == VoiceAssistantState.listening
          ? VoiceState.listening
          : serviceState == VoiceAssistantState.thinking
          ? VoiceState.thinking
          : VoiceState.speaking;

      if (_state != mappedState) {
        setState(() {
          _state = mappedState;
        });

        if (_state == VoiceState.thinking) {
          _startInsideOrbScanning();
        } else {
          _orbScanTimer?.cancel();
        }
        if (_state == VoiceState.speaking && !_didCheckAudio) {
          _didCheckAudio = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkAudio());
        }
      } else {
        setState(() {});
      }
      if (mappedState == VoiceState.speaking) {
        WidgetsBinding.instance.addPostFrameCallback(
          (_) => _scrollToActiveLyric(),
        );
      }
    }
  }

  void _scrollToActiveLyric() {
    if (!_lyricsScrollController.hasClients) return;
    final target = (_voiceService.activeLyricIndex * 86.0).clamp(
      0.0,
      _lyricsScrollController.position.maxScrollExtent,
    );
    _lyricsScrollController.animateTo(
      target,
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  // Inside the Orb note scanner
  void _startInsideOrbScanning() {
    _orbScanTimer?.cancel();
    _currentInsideOrbIndex = 0;
    if (MediaQuery.of(context).disableAnimations) return;

    _orbScanTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_state == VoiceState.thinking &&
          mounted &&
          _candidateNodes.isNotEmpty) {
        setState(() {
          _currentInsideOrbIndex =
              (_currentInsideOrbIndex + 1) % _candidateNodes.length;
        });
      }
    });
  }

  Future<void> _checkAudio({bool alwaysShow = false}) async {
    final status = await _voiceService.audioOutputStatus();
    if (!mounted) return;
    final volume = (status['outputVolume'] as num?)?.toDouble() ?? 1;
    if (!alwaysShow &&
        volume > 0.02 &&
        _voiceService.audioOutputError == null) {
      return;
    }
    final route = status['route'] as String? ?? 'iPhone speaker';
    final voice = status['voice'] as String? ?? 'System voice';
    final voiceQuality = status['voiceQuality'] as String? ?? 'Standard';
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.elevation2,
        title: const Text('Can you hear NoteEchoes?'),
        content: Text(
          '${volume <= 0.02 ? 'Your media volume is currently at zero. Raise it with the iPhone volume buttons, then test the voice.' : 'Audio is being sent to $route. If you cannot hear it, check the media volume or disconnect Bluetooth.'}\n\n'
          'Voice: $voice ($voiceQuality).'
          '${voiceQuality == 'Standard' ? '\n\nFor a more human voice, download an Enhanced or Premium voice in iPhone Settings → Accessibility → Read & Speak or Spoken Content → Voices. iOS stores that voice, so it does not increase the NoteEchoes app size.' : ''}',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () => _voiceService.testSpeechOutput(),
            icon: const Icon(Icons.volume_up_rounded),
            label: const Text('Test voice'),
          ),
        ],
      ),
    );
  }

  void _copySpokenTranscript() {
    final text = _voiceService.fullGeneratedResponse.isNotEmpty
        ? _voiceService.fullGeneratedResponse
        : "No transcript available.";
    Clipboard.setData(ClipboardData(text: text));
    HapticFeedback.mediumImpact();
    setState(() => _isCopied = true);
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) setState(() => _isCopied = false);
    });
  }

  Future<void> _saveAiResponseAsNote() async {
    final text = _voiceService.fullGeneratedResponse.isNotEmpty
        ? _voiceService.fullGeneratedResponse
        : "Voice Assistant Summary";
    final newNote = NoteModel(
      noteId: "echo_${DateTime.now().millisecondsSinceEpoch}",
      title: _voiceService.summaryTitle,
      contentType: NoteContentType.textOnly,
      summarySnippet: text.split("\n\n").first,
      textContent: text,
      createdAt: DateTime.now(),
      tags: ["voice-memo", "ai-summary"],
    );
    await NoteService().addNote(newNote);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.elevation2,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.accentGreen, size: 18),
            SizedBox(width: 8),
            Text("Voice response saved to Notes!"),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _orbScanTimer?.cancel();
    _voiceService.removeListener(_onServiceUpdate);
    _voiceService.stopVoiceSession();
    _animationController.dispose();
    _wheelScrollController.dispose();
    _lyricsScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.deepMatteBlack,
      body: SafeArea(
        child: Stack(
          children: [
            // Layer 1: Water Droplet Ripple Effect (Listening) or Dream Bubble (Thinking)
            if (_state == VoiceState.listening || _state == VoiceState.thinking)
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return CustomPaint(
                      painter: VoiceVisualizerPainter(
                        animationValue: _animationController.value,
                        state: _state,
                        amplitude: _voiceService.micAmplitude,
                        accent: Theme.of(context).colorScheme.primary,
                      ),
                    );
                  },
                ),
              ),

            // Layer 2: Thinking State - Note Cards appearing INSIDE the Dream Bubble Orb one after the other
            if (_state == VoiceState.thinking) _buildInsideOrbNoteScanner(),

            // Layer 3: Main UI Views
            Column(
              children: [
                // Top Minimal Header (Close button & subtle live badge)
                _buildMinimalHeader(),

                // Full-Screen Surface (Listening wheel, Thinking overlay, or Gemini Live Karaoke Highlight)
                Expanded(
                  child: AnimatedSwitcher(
                    duration: MediaQuery.of(context).disableAnimations
                        ? Duration.zero
                        : const Duration(milliseconds: 420),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.018),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_state),
                      child: _state == VoiceState.listening
                          ? _buildListeningScreen()
                          : _state == VoiceState.thinking
                          ? _buildThinkingOverlay()
                          : _buildGeminiLiveKaraokeScreen(),
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

  // ==========================================================
  // TOP MINIMAL HEADER BAR (Close + [ 📋 Copy ] + [ 💾 Save ])
  // ==========================================================
  Widget _buildMinimalHeader() {
    final accent = Theme.of(context).colorScheme.primary;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        children: [
          IconButton(
            tooltip: 'Close conversation',
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
            onPressed: () {
              _voiceService.stopVoiceSession();
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Conversation',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _state == VoiceState.speaking
                            ? AppColors.accentGreen
                            : accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        _state == VoiceState.listening
                            ? 'Listening'
                            : _state == VoiceState.thinking
                            ? 'Gathering context'
                            : 'Responding',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.inter(
                          fontSize: 11,
                          color: AppColors.secondaryText,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_state == VoiceState.speaking)
            IconButton(
              tooltip: 'Save response as a note',
              onPressed: _saveAiResponseAsNote,
              icon: const Icon(
                Icons.bookmark_add_outlined,
                color: AppColors.accentBlue,
                size: 21,
              ),
            ),
          if (_state == VoiceState.speaking)
            IconButton(
              tooltip: _isCopied ? 'Copied' : 'Copy response',
              onPressed: _copySpokenTranscript,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: Icon(
                  _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                  key: ValueKey(_isCopied),
                  color: _isCopied ? AppColors.accentGreen : Colors.white,
                  size: 20,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // STATE 1: LISTENING SCREEN (Water Dropping Ripple + Revolving Thought Wheel at bottom)
  // ==========================================================
  Widget _buildListeningScreen() {
    return Column(
      children: [
        // Center area has the water droplet ripple (no top text!)
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () => _voiceService.transitionToThinkingState(),
            child: Align(
              alignment: const Alignment(0, 0.42),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Speak naturally',
                      style: GoogleFonts.outfit(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _voiceService.currentActiveUserSentence,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        height: 1.4,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Bottom Revolving Thoughts Loop (Cylindrical Wheel Scroll Loop like a date picker)
        Container(
          margin: const EdgeInsets.only(bottom: 28),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!ModelAvailabilityService.instance.qwen.isReady) ...[
                Semantics(
                  button: true,
                  label:
                      'Basic keyword mode. Download the local AI model for deeper conversational answers.',
                  child: TextButton.icon(
                    onPressed: () => requireQwenModel(
                      context,
                      featureName: 'deeper conversational answers',
                      basicAlternative:
                          'Basic keyword matching remains available without the model.',
                    ),
                    icon: const Icon(Icons.info_outline_rounded, size: 15),
                    label: const Text(
                      'Basic mode • Download AI for deeper answers',
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
              Text(
                "Try asking about your notes",
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w500,
                  color: AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 10),

              // Cylindrical Loop Wheel
              SizedBox(
                height: 90,
                child: ListWheelScrollView.useDelegate(
                  controller: _wheelScrollController,
                  itemExtent: 38,
                  perspective: 0.004,
                  diameterRatio: 1.4,
                  physics: const FixedExtentScrollPhysics(),
                  childDelegate: ListWheelChildLoopingListDelegate(
                    children: _thoughtSuggestions.map((thought) {
                      return GestureDetector(
                        onTap: () {
                          _voiceService.setManualQuery(thought);
                        },
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: AppColors.elevation1.withValues(alpha: 0.9),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppColors.glassBorderBright,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.4),
                                blurRadius: 6,
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.arrow_upward_rounded,
                                size: 13,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: Text(
                                  thought,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.inter(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // STATE 2: THINKING - RICH NOTE TILES INSIDE THE DREAM BUBBLE ORB
  // ==========================================================
  Widget _buildInsideOrbNoteScanner() {
    final notes = NoteService().allNotes;
    if (notes.isEmpty) return const SizedBox.shrink();
    final activeNote = notes[_currentInsideOrbIndex % notes.length];
    final hasPdf = activeNote.mediaAssets.any(
      (m) => m.type == MediaAssetType.pdf,
    );
    final accent = Theme.of(context).colorScheme.primary;

    return Align(
      alignment: const Alignment(0, 0.02),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 420),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position:
                Tween<Offset>(
                  begin: const Offset(0, -0.08),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeOut),
                ),
            child: child,
          ),
        ),
        child: Container(
          key: ValueKey("memory_${activeNote.noteId}"),
          width: 250,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
          decoration: BoxDecoration(
            color: AppColors.elevation1.withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    activeNote.contentType == NoteContentType.richMedia
                        ? Icons.auto_awesome_mosaic_rounded
                        : activeNote.checklist.isNotEmpty
                        ? Icons.checklist_rounded
                        : Icons.description_outlined,
                    size: 15,
                    color: accent,
                  ),
                  if (hasPdf) ...[
                    const SizedBox(width: 6),
                    const Text(
                      'PDF',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 8),
              Text(
                activeNote.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                activeNote.summarySnippet.isNotEmpty
                    ? activeNote.summarySnippet
                    : activeNote.textContent,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppColors.secondaryText,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingOverlay() {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Gathering the right memories",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: accent,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Your notes stay on this device',
          style: GoogleFonts.inter(
            fontSize: 11.5,
            color: AppColors.secondaryText,
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ==========================================================
  // STATE 3: SPEAKING - FULL-SCREEN APPLE MUSIC / GEMINI LIVE KARAOKE HIGHLIGHT
  // ==========================================================
  Widget _buildGeminiLiveKaraokeScreen() {
    final lyricLines = _voiceService.aiLyricLines;
    final accent = Theme.of(context).colorScheme.primary;

    return Stack(
      children: [
        // Pure Matte Black Background with Glowing Apple Music Lyrics
        ShaderMask(
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
            controller: _lyricsScrollController,
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
              top: 20,
              bottom: 90,
            ),
            itemCount: lyricLines.length,
            itemBuilder: (context, index) {
              final line = lyricLines[index];
              final isActive = index == _voiceService.activeLyricIndex;
              final isPast = index < _voiceService.activeLyricIndex;

              return Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? accent.withValues(alpha: 0.10)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isActive
                          ? accent.withValues(alpha: 0.22)
                          : Colors.transparent,
                    ),
                  ),
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                    style: GoogleFonts.outfit(
                      fontSize: isActive ? 26 : 20,
                      fontWeight: isActive ? FontWeight.w800 : FontWeight.w500,
                      height: 1.35,
                      letterSpacing: isActive ? -0.5 : -0.2,
                      color: isActive
                          ? Colors.white
                          : isPast
                          ? AppColors.secondaryText.withValues(alpha: 0.45)
                          : AppColors.dimmedLyric,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: 2,
                          height: isActive ? 34 : 0,
                          margin: const EdgeInsets.only(right: 10, top: 2),
                          color: isActive ? accent : Colors.transparent,
                        ),
                        Expanded(child: Text(line.text)),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),

        // Bottom Minimal Audio Controls Pill
        Positioned(
          left: 24,
          right: 24,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.elevation2.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: AppColors.glassBorderBright),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.6),
                  blurRadius: 16,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  tooltip: 'Replay spoken response',
                  icon: const Icon(
                    Icons.replay_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  onPressed: () => _voiceService.restartKaraoke(),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _voiceService.togglePlayPause(),
                  child: Semantics(
                    button: true,
                    label: _voiceService.isPlayingAudio
                        ? 'Pause spoken response'
                        : 'Play spoken response',
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: accent,
                      ),
                      child: Icon(
                        _voiceService.isPlayingAudio
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                IconButton(
                  tooltip: "Can't hear the voice?",
                  icon: const Icon(Icons.hearing_rounded, size: 19),
                  onPressed: () => _checkAudio(alwaysShow: true),
                ),
                IconButton(
                  tooltip: 'Start a new question',
                  icon: Icon(Icons.mic_rounded, color: accent, size: 20),
                  onPressed: () => _voiceService.transitionToListeningState(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

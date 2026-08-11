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
    )..repeat();

    _loadCandidateNodes();

    // Immediately start active listening on open
    _voiceService.startVoiceSession(initialPrompt: widget.initialPrompt);

    if (_state == VoiceState.thinking) {
      _startInsideOrbScanning();
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
      } else {
        setState(() {});
      }
    }
  }

  // Inside the Orb note scanner
  void _startInsideOrbScanning() {
    _orbScanTimer?.cancel();
    _currentInsideOrbIndex = 0;

    _orbScanTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (_state == VoiceState.thinking && mounted && _candidateNodes.isNotEmpty) {
        setState(() {
          _currentInsideOrbIndex = (_currentInsideOrbIndex + 1) % _candidateNodes.length;
        });
      }
    });
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

  void _saveAiResponseAsNote() {
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
    NoteService().addNote(newNote);

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
    _animationController.dispose();
    _wheelScrollController.dispose();
    _voiceService.removeListener(_onServiceUpdate);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0C), // Pure Matte Black Canvas
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
                  child: _state == VoiceState.listening
                      ? _buildListeningScreen()
                      : _state == VoiceState.thinking
                          ? _buildThinkingOverlay()
                          : _buildGeminiLiveKaraokeScreen(),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Row(
        children: [
          // Close button
          IconButton(
            icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
            onPressed: () {
              _voiceService.stopVoiceSession();
              Navigator.of(context).pop();
            },
          ),

          const SizedBox(width: 4),

          // Live State Indicator Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.elevation1,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: _state == VoiceState.listening
                        ? const Color(0xFFFF2D55)
                        : _state == VoiceState.thinking
                            ? const Color(0xFF00F2FE)
                            : AppColors.accentGreen,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_state == VoiceState.listening
                                ? const Color(0xFFFF2D55)
                                : _state == VoiceState.thinking
                                    ? const Color(0xFF00F2FE)
                                    : AppColors.accentGreen)
                            .withValues(alpha: 0.8),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  _state == VoiceState.listening
                      ? "Listening..."
                      : _state == VoiceState.thinking
                          ? "Scanning memory..."
                          : "Gemini Live",
                  style: GoogleFonts.inter(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Sticky [ 💾 Save ] & [ 📋 Copy ] in Speaking State
          if (_state == VoiceState.speaking) ...[
            GestureDetector(
              onTap: _saveAiResponseAsNote,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                margin: const EdgeInsets.only(right: 6),
                decoration: BoxDecoration(
                  color: AppColors.elevation2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.glassBorderBright),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_add_outlined, size: 13, color: AppColors.accentBlue),
                    SizedBox(width: 4),
                    Text("Save", style: TextStyle(fontSize: 11.5, color: Colors.white, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ),

            GestureDetector(
              onTap: _copySpokenTranscript,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _isCopied ? AppColors.accentGreen : AppColors.elevation2,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _isCopied ? AppColors.accentGreen : AppColors.glassBorderBright,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isCopied ? Icons.check_rounded : Icons.copy_rounded,
                      size: 13,
                      color: _isCopied ? Colors.black : Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _isCopied ? "Copied!" : "Copy",
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: _isCopied ? Colors.black : Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
          child: Center(
            child: GestureDetector(
              onTap: () => _voiceService.transitionToThinkingState(),
              child: Container(
                color: Colors.transparent,
                width: double.infinity,
                height: double.infinity,
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
              Text(
                "💭 Revolve thoughts to ask or speak naturally:",
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
                  onSelectedItemChanged: (index) {
                    HapticFeedback.selectionClick();
                  },
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
                            border: Border.all(color: AppColors.glassBorderBright),
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
                              const Text("💭", style: TextStyle(fontSize: 12)),
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
    final hasPdf = activeNote.mediaAssets.any((m) => m.type == MediaAssetType.pdf);

    return Center(
      child: Container(
        width: 190,
        height: 190,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
        ),
        child: ClipOval(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 450),
            transitionBuilder: (child, animation) {
              return FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                  ),
                  child: child,
                ),
              );
            },
            child: Container(
              key: ValueKey("inside_orb_${activeNote.noteId}"),
              width: 175,
              height: 175,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: activeNote.contentType == NoteContentType.richMedia
                      ? [
                          const Color(0xFF1E1030),
                          const Color(0xFF141418),
                          const Color(0xFF0F172A),
                        ]
                      : [
                          const Color(0xFF1A1A24),
                          const Color(0xFF121218),
                          const Color(0xFF0A0A0C),
                        ],
                ),
                border: Border.all(
                  color: const Color(0xFF00F2FE).withValues(alpha: 0.6),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F2FE).withValues(alpha: 0.25),
                    blurRadius: 14,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Mini Artwork / Badge header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00F2FE).withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          activeNote.contentType == NoteContentType.richMedia
                              ? Icons.auto_awesome_mosaic_rounded
                              : activeNote.checklist.isNotEmpty
                                  ? Icons.checklist_rounded
                                  : Icons.description_rounded,
                          size: 16,
                          color: const Color(0xFF00F2FE),
                        ),
                      ),
                      if (hasPdf) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.badgePdf,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            "PDF",
                            style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Note Title
                  Text(
                    activeNote.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.outfit(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 3),

                  // 2-line snippet preview
                  Text(
                    activeNote.summarySnippet.isNotEmpty
                        ? activeNote.summarySnippet
                        : activeNote.textContent,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 9.5,
                      color: AppColors.secondaryText,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 5),

                  // Tags chip
                  if (activeNote.tags.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.elevation2,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        "#${activeNote.tags.first}",
                        style: const TextStyle(fontSize: 8.5, color: Color(0xFF00F2FE), fontWeight: FontWeight.w600),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThinkingOverlay() {
    return Column(
      children: [
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            "Searching memory inside Dream Bubble...",
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF00F2FE),
            ),
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
            padding: const EdgeInsets.only(left: 24, right: 24, top: 20, bottom: 90),
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
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isActive ? Colors.white.withValues(alpha: 0.06) : Colors.transparent,
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
                      shadows: isActive
                          ? [
                              Shadow(
                                color: Colors.white.withValues(alpha: 0.7),
                                blurRadius: 18,
                              ),
                              Shadow(
                                color: AppColors.dropletRed.withValues(alpha: 0.35),
                                blurRadius: 24,
                              ),
                            ]
                          : null,
                    ),
                    child: Text(line.text),
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
                  icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                  onPressed: () => _voiceService.restartKaraoke(),
                ),
                const SizedBox(width: 14),
                GestureDetector(
                  onTap: () => _voiceService.togglePlayPause(),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFFFF2D55),
                    ),
                    child: Icon(
                      _voiceService.isPlayingAudio ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                TextButton.icon(
                  icon: const Icon(Icons.mic_rounded, color: Color(0xFF00F2FE), size: 15),
                  label: const Text("New Query", style: TextStyle(color: Color(0xFF00F2FE), fontSize: 12)),
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

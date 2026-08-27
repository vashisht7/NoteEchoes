import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/note_model.dart';
import '../models/note_node.dart';
import '../services/note_service.dart';
import '../services/voice_assistant_service.dart';
import '../theme/app_colors.dart';
import '../widgets/voice_visualizer_painter.dart';
import 'voice_detailed_report_screen.dart';
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
  bool _didCheckAudio = false;
  bool _reportSheetVisible = false;
  final TextEditingController _questionController = TextEditingController();

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
      value: 0.35,
    );

    _loadCandidateNodes();

    if (widget.currentState == VoiceState.listening) {
      // Immediately start active listening on open
      _voiceService.startVoiceSession(initialPrompt: widget.initialPrompt);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.of(context).disableAnimations ||
        Platform.environment.containsKey('FLUTTER_TEST')) {
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
      final previousState = _state;
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

        if (_state == VoiceState.speaking && !_didCheckAudio) {
          _didCheckAudio = true;
          WidgetsBinding.instance.addPostFrameCallback((_) => _checkAudio());
        }
        if (previousState == VoiceState.thinking &&
            _state == VoiceState.speaking) {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) => _showReportSheet(),
          );
        }
      } else {
        setState(() {});
      }
    }
  }

  Future<void> _showReportSheet() async {
    if (!mounted || _reportSheetVisible) return;
    _reportSheetVisible = true;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.54),
      builder: (sheetContext) => DraggableScrollableSheet(
        key: const ValueKey('voice_report_sheet'),
        expand: false,
        initialChildSize: 0.75,
        minChildSize: 0.50,
        maxChildSize: 0.98,
        snap: true,
        snapSizes: const [0.75, 0.98],
        builder: (context, scrollController) => ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: VoiceDetailedReportScreen(
            embedded: true,
            scrollController: scrollController,
          ),
        ),
      ),
    );
    _reportSheetVisible = false;
  }

  Future<void> _checkAudio({bool alwaysShow = false}) async {
    if (_voiceService.audioOutputError?.contains('running on iPhone') == true) {
      return;
    }
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
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Response copied')));
  }

  void _submitTypedQuestion(String value) {
    final question = value.trim();
    if (question.isEmpty) return;
    FocusScope.of(context).unfocus();
    _questionController.clear();
    _voiceService.setManualQuery(question);
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
    _voiceService.removeListener(_onServiceUpdate);
    _voiceService.stopVoiceSession();
    _animationController.dispose();
    _wheelScrollController.dispose();
    _questionController.dispose();
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
            if (_state == VoiceState.listening)
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

            // Layer 2: Main UI Views
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
                            ? 'Listening automatically'
                            : _state == VoiceState.thinking
                            ? _voiceService.processingStatus
                            : 'Speaking your answer',
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
            PopupMenuButton<String>(
              tooltip: 'Response controls',
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              onSelected: (action) {
                switch (action) {
                  case 'save':
                    _saveAiResponseAsNote();
                    break;
                  case 'copy':
                    _copySpokenTranscript();
                    break;
                  case 'replay':
                    _voiceService.restartKaraoke();
                    break;
                  case 'play_pause':
                    _voiceService.togglePlayPause();
                    break;
                  case 'audio':
                    _checkAudio(alwaysShow: true);
                    break;
                  case 'new_question':
                    _voiceService.transitionToListeningState();
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'save',
                  child: Text('Save response as note'),
                ),
                const PopupMenuItem(
                  value: 'copy',
                  child: Text('Copy response'),
                ),
                const PopupMenuItem(
                  value: 'replay',
                  child: Text('Replay response'),
                ),
                PopupMenuItem(
                  value: 'play_pause',
                  child: Text(
                    _voiceService.isPlayingAudio
                        ? 'Pause response'
                        : 'Continue response',
                  ),
                ),
                const PopupMenuItem(
                  value: 'audio',
                  child: Text("I can't hear the voice"),
                ),
                const PopupMenuItem(
                  value: 'new_question',
                  child: Text('Ask a new question'),
                ),
              ],
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
              Container(
                decoration: BoxDecoration(
                  color: AppColors.elevation1.withValues(alpha: 0.94),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorderBright),
                ),
                child: TextField(
                  key: const ValueKey('conversation_question_field'),
                  controller: _questionController,
                  textInputAction: TextInputAction.send,
                  onSubmitted: _submitTypedQuestion,
                  style: GoogleFonts.inter(color: Colors.white, fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'Or type a question…',
                    hintStyle: GoogleFonts.inter(
                      color: AppColors.secondaryText,
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
                    suffixIcon: IconButton(
                      tooltip: 'Ask question',
                      onPressed: () =>
                          _submitTypedQuestion(_questionController.text),
                      icon: Icon(
                        Icons.arrow_upward_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
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
  Widget _buildThinkingOverlay() {
    return _buildMemoryNetwork(showResult: false);
  }

  // ==========================================================
  // STATE 3: SPEAKING - FULL-SCREEN APPLE MUSIC / GEMINI LIVE KARAOKE HIGHLIGHT
  // ==========================================================
  Widget _buildGeminiLiveKaraokeScreen() {
    return _buildMemoryNetwork(showResult: true);
  }

  Widget _buildMemoryNetwork({required bool showResult}) {
    final accent = Theme.of(context).colorScheme.primary;
    final contextual = _voiceService.contextualNotes;
    final searchingWeb = _voiceService.processingStatus.contains('web');
    final canShowRecentNotes = !searchingWeb && !showResult;
    final nodes = contextual.isNotEmpty
        ? contextual.take(6).map((note) {
            return NoteNode(
              id: note.noteId,
              title: note.title,
              snippet: note.summarySnippet.isNotEmpty
                  ? note.summarySnippet
                  : note.textContent,
            );
          }).toList()
        : canShowRecentNotes
        ? _candidateNodes.take(6).toList()
        : <NoteNode>[];

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.285).clamp(84.0, 116.0);
        final resultSpace = showResult ? 200.0 : 70.0;
        final hubY = (constraints.maxHeight - resultSpace).clamp(
          220.0,
          constraints.maxHeight * 0.76,
        );
        const positions = <Offset>[
          Offset(0.18, 0.06),
          Offset(0.50, 0.02),
          Offset(0.82, 0.07),
          Offset(0.25, 0.34),
          Offset(0.74, 0.35),
          Offset(0.50, 0.61),
        ];

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) => CustomPaint(
                  painter: _MemoryNetworkPainter(
                    progress: _animationController.value,
                    accent: accent,
                    nodePositions: positions.take(nodes.length).toList(),
                    hubY: hubY,
                    reduceMotion: MediaQuery.of(context).disableAnimations,
                  ),
                ),
              ),
            ),
            for (var index = 0; index < nodes.length; index++)
              Positioned(
                left:
                    positions[index].dx * constraints.maxWidth - cardWidth / 2,
                top: positions[index].dy * hubY,
                width: cardWidth,
                child: _MemoryNoteCard(
                  node: nodes[index],
                  index: index,
                  accent: accent,
                  active:
                      !showResult &&
                      index ==
                          _voiceService.activeOrbitNoteIndex % nodes.length,
                ),
              ),
            Positioned(
              left: constraints.maxWidth / 2 - 5,
              top: hubY - 5,
              child: Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.45),
                      blurRadius: 14,
                      spreadRadius: 3,
                    ),
                  ],
                ),
              ),
            ),
            if (!showResult)
              Positioned(
                left: 20,
                right: 20,
                bottom: 22,
                child: Column(
                  children: [
                    Text(
                      _voiceService.processingStatus,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _voiceService.processingStatus.contains('web')
                          ? 'Using an attributed public web source'
                          : 'Your notes stay on this device',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppColors.secondaryText,
                      ),
                    ),
                  ],
                ),
              ),
            if (showResult)
              Positioned(
                left: 20,
                right: 20,
                bottom: 14,
                child: _IntegratedInsightCard(
                  title: _voiceService.summaryTitle,
                  response: _voiceService.fullGeneratedResponse,
                  onOpen: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const VoiceDetailedReportScreen(),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MemoryNoteCard extends StatelessWidget {
  const _MemoryNoteCard({
    required this.node,
    required this.index,
    required this.accent,
    required this.active,
  });

  final NoteNode node;
  final int index;
  final Color accent;
  final bool active;

  @override
  Widget build(BuildContext context) {
    const icons = [
      Icons.description_outlined,
      Icons.location_on_outlined,
      Icons.mail_outline_rounded,
      Icons.checklist_rounded,
      Icons.link_rounded,
      Icons.graphic_eq_rounded,
    ];
    return AnimatedContainer(
      duration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 260),
      height: 78,
      padding: const EdgeInsets.fromLTRB(10, 9, 9, 8),
      decoration: BoxDecoration(
        color: active
            ? AppColors.elevation3.withValues(alpha: 0.98)
            : AppColors.elevation1.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: active
              ? accent.withValues(alpha: 0.45)
              : Colors.white.withValues(alpha: 0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icons[index % icons.length], size: 17, color: Colors.white70),
          const Spacer(),
          Text(
            node.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10.5,
              height: 1.08,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryText,
            ),
          ),
        ],
      ),
    );
  }
}

class _IntegratedInsightCard extends StatelessWidget {
  const _IntegratedInsightCard({
    required this.title,
    required this.response,
    required this.onOpen,
  });

  final String title;
  final String response;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final summary = response.replaceAll(RegExp(r'\s+'), ' ').trim();
    return Container(
      key: const ValueKey('integrated_insight_card'),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 13),
      decoration: BoxDecoration(
        color: AppColors.elevation2.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 18,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Integrated Insight',
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: AppColors.primaryText,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            summary,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 11.5,
              height: 1.35,
              color: AppColors.secondaryText,
            ),
          ),
          const SizedBox(height: 11),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: FilledButton(
              key: const ValueKey('view_detailed_report_button'),
              onPressed: onOpen,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.08),
                foregroundColor: AppColors.primaryText,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Row(
                children: [
                  Expanded(
                    child: Text(
                      'View Detailed Report',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemoryNetworkPainter extends CustomPainter {
  const _MemoryNetworkPainter({
    required this.progress,
    required this.accent,
    required this.nodePositions,
    required this.hubY,
    required this.reduceMotion,
  });

  final double progress;
  final Color accent;
  final List<Offset> nodePositions;
  final double hubY;
  final bool reduceMotion;

  @override
  void paint(Canvas canvas, Size size) {
    final hub = Offset(size.width / 2, hubY);
    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final pulse = reduceMotion ? 0.55 : (0.36 + progress * 0.30);

    for (var i = 0; i < nodePositions.length; i++) {
      final normalized = nodePositions[i];
      final target = Offset(
        normalized.dx * size.width,
        normalized.dy * hubY + 39,
      );
      final path = Path()
        ..moveTo(hub.dx, hub.dy)
        ..quadraticBezierTo(
          hub.dx + (target.dx - hub.dx) * 0.22,
          hub.dy - 34 - i * 2,
          target.dx,
          target.dy,
        );
      linePaint.color = accent.withValues(alpha: pulse);
      canvas.drawPath(path, linePaint);
    }

    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          accent.withValues(alpha: 0.28),
          accent.withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: hub, radius: 72));
    canvas.drawCircle(hub, 72, glow);
  }

  @override
  bool shouldRepaint(covariant _MemoryNetworkPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.hubY != hubY ||
        oldDelegate.nodePositions.length != nodePositions.length ||
        oldDelegate.accent != accent;
  }
}

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/note_model.dart';
import 'note_service.dart';

enum VoiceAssistantState {
  listening, // State 2.1: Droplet Red mic ripple + live lyrics STT
  thinking, // State 2.2: Organic Nebula morph + 360° Orbital Note scanning
  speaking, // State 2.3: Spoken response + synchronized Karaoke lyric glow
}

class SpokenLyricLine {
  final String text;
  final Duration startTime;
  final Duration duration;
  final String? emphasisNote;

  const SpokenLyricLine({
    required this.text,
    required this.startTime,
    required this.duration,
    this.emphasisNote,
  });
}

class VoiceAssistantService extends ChangeNotifier {
  static final VoiceAssistantService _instance = VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal();

  VoiceAssistantState _state = VoiceAssistantState.listening;
  VoiceAssistantState get state => _state;

  // Real-time audio amplitude for ripple (0.0 to 1.0)
  double _micAmplitude = 0.45;
  double get micAmplitude => _micAmplitude;

  // Live streaming user transcript (Listening State)
  final List<String> _userTranscriptLines = [];
  List<String> get userTranscriptLines => List.unmodifiable(_userTranscriptLines);

  String _currentActiveUserSentence = "Summarize my notes about the Gemini API integration...";
  String get currentActiveUserSentence => _currentActiveUserSentence;

  // Context Notes for Thinking State
  List<NoteModel> _contextualNotes = [];
  List<NoteModel> get contextualNotes => _contextualNotes;

  // Orbital Ring scanning index (rotates every 1 second)
  int _activeOrbitNoteIndex = 0;
  int get activeOrbitNoteIndex => _activeOrbitNoteIndex;

  double _orbitalAngleDegrees = 0.0;
  double get orbitalAngleDegrees => _orbitalAngleDegrees;

  // Spoken AI Response & Karaoke Lyrics (Speaking State)
  List<SpokenLyricLine> _aiLyricLines = [];
  List<SpokenLyricLine> get aiLyricLines => _aiLyricLines;

  int _activeLyricIndex = 0;
  int get activeLyricIndex => _activeLyricIndex;

  bool _isPlayingAudio = false;
  bool get isPlayingAudio => _isPlayingAudio;

  String _summaryTitle = "Gemini API Summary & Specs";
  String get summaryTitle => _summaryTitle;

  String _fullGeneratedResponse = "";
  String get fullGeneratedResponse => _fullGeneratedResponse;

  Timer? _amplitudeTimer;
  Timer? _transcriptStreamTimer;
  Timer? _orbitalStepTimer;
  Timer? _karaokeTimer;
  Timer? _stateProgressionTimer;

  final Random _random = Random();

  void startVoiceSession({String? initialPrompt}) {
    _state = VoiceAssistantState.listening;
    _userTranscriptLines.clear();
    _currentActiveUserSentence = initialPrompt ?? "Summarize my notes about the Gemini API integration...";
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    _activeLyricIndex = 0;
    _isPlayingAudio = false;

    // Load initial context notes from repository
    _contextualNotes = NoteService().getContextualNotesForQuery(_currentActiveUserSentence);

    _startSimulatedMicInput();
    _startSimulatedTranscriptStream();

    notifyListeners();
  }

  void stopVoiceSession() {
    _amplitudeTimer?.cancel();
    _transcriptStreamTimer?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _stateProgressionTimer?.cancel();
    _isPlayingAudio = false;
    notifyListeners();
  }

  void transitionToThinkingState([String? customPrompt]) {
    _amplitudeTimer?.cancel();
    _transcriptStreamTimer?.cancel();

    if (customPrompt != null && customPrompt.isNotEmpty) {
      _currentActiveUserSentence = customPrompt;
    }

    _contextualNotes = NoteService().getContextualNotesForQuery(_currentActiveUserSentence);
    if (_contextualNotes.isEmpty) {
      _contextualNotes = NoteService().allNotes.take(4).toList();
    }

    _state = VoiceAssistantState.thinking;
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    notifyListeners();

    // Start 1-second step orbital rotation
    _startOrbitalStepScanner();

    // Auto progress to speaking state after 3.2 seconds of scanning
    _stateProgressionTimer?.cancel();
    _stateProgressionTimer = Timer(const Duration(milliseconds: 3200), () {
      transitionToSpeakingState();
    });
  }

  void transitionToSpeakingState() {
    _orbitalStepTimer?.cancel();
    _stateProgressionTimer?.cancel();

    _state = VoiceAssistantState.speaking;
    _isPlayingAudio = true;
    _activeLyricIndex = 0;

    _setupResponseLyrics();
    _startKaraokePlayback();

    notifyListeners();
  }

  void transitionToListeningState() {
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _stateProgressionTimer?.cancel();

    startVoiceSession();
  }

  void setManualQuery(String query) {
    _currentActiveUserSentence = query;
    transitionToThinkingState(query);
  }

  void togglePlayPause() {
    _isPlayingAudio = !_isPlayingAudio;
    notifyListeners();
  }

  void restartKaraoke() {
    _activeLyricIndex = 0;
    _isPlayingAudio = true;
    _startKaraokePlayback();
    notifyListeners();
  }

  void _startSimulatedMicInput() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_state == VoiceAssistantState.listening) {
        // Natural voice modulation with peaks and valleys
        final base = 0.3 + 0.5 * sin(timer.tick * 0.25).abs();
        final noise = (_random.nextDouble() - 0.5) * 0.2;
        _micAmplitude = (base + noise).clamp(0.15, 0.95);
        notifyListeners();
      }
    });
  }

  void _startSimulatedTranscriptStream() {
    _transcriptStreamTimer?.cancel();
    final phrases = [
      "Listening to your voice...",
      "Analyzing notes about Stage architecture...",
      "Summarize my notes about",
      "Summarize my notes about the Gemini API integration...",
    ];

    int step = 0;
    _transcriptStreamTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (_state == VoiceAssistantState.listening) {
        if (step < phrases.length) {
          _currentActiveUserSentence = phrases[step];
          if (step == 2) {
            _userTranscriptLines.add("Find system architecture specs");
          }
          step++;
          notifyListeners();
        } else {
          // Auto advance or wait for user tap
          timer.cancel();
        }
      }
    });
  }

  void _startOrbitalStepScanner() {
    _orbitalStepTimer?.cancel();
    final n = max(_contextualNotes.length, 1);
    final stepAngle = 360.0 / n;

    _orbitalStepTimer = Timer.periodic(const Duration(milliseconds: 1000), (timer) {
      if (_state == VoiceAssistantState.thinking) {
        _activeOrbitNoteIndex = (_activeOrbitNoteIndex + 1) % n;
        _orbitalAngleDegrees += stepAngle;
        notifyListeners();
      }
    });
  }

  void _setupResponseLyrics() {
    _aiLyricLines = [
      const SpokenLyricLine(
        text: "I found 2 notes matching your query about the Gemini API integration.",
        startTime: Duration.zero,
        duration: Duration(milliseconds: 1600),
      ),
      const SpokenLyricLine(
        text: "Here is the summary of the Gemini API specifications and data structures:",
        startTime: Duration(milliseconds: 1600),
        duration: Duration(milliseconds: 1800),
      ),
      const SpokenLyricLine(
        text: "1. Stage UI architecture leverages low-latency streaming WebSocket transport at 120ms.",
        startTime: Duration(milliseconds: 3400),
        duration: Duration(milliseconds: 2200),
      ),
      const SpokenLyricLine(
        text: "2. The multi-modal pipeline streams raw PCM16 audio directly into context memory embeddings.",
        startTime: Duration(milliseconds: 5600),
        duration: Duration(milliseconds: 2400),
      ),
      const SpokenLyricLine(
        text: "3. Apple Music-style lyrics synchronize with ±50ms real-time audio timestamp cues.",
        startTime: Duration(milliseconds: 8000),
        duration: Duration(milliseconds: 2200),
      ),
      const SpokenLyricLine(
        text: "Would you like me to create a new task list or update the architecture doc?",
        startTime: Duration(milliseconds: 10200),
        duration: Duration(milliseconds: 2000),
      ),
    ];

    _fullGeneratedResponse = _aiLyricLines.map((e) => e.text).join("\n\n");
    _summaryTitle = "Gemini API Architecture Summary";
  }

  void _startKaraokePlayback() {
    _karaokeTimer?.cancel();
    int current = 0;

    void scheduleNext() {
      if (!_isPlayingAudio || _state != VoiceAssistantState.speaking) return;

      if (current < _aiLyricLines.length) {
        _activeLyricIndex = current;
        notifyListeners();

        final duration = _aiLyricLines[current].duration;
        current++;
        _karaokeTimer = Timer(duration, () {
          scheduleNext();
        });
      } else {
        // Finished speaking
        _isPlayingAudio = false;
        notifyListeners();
      }
    }

    scheduleNext();
  }

  @override
  void dispose() {
    _amplitudeTimer?.cancel();
    _transcriptStreamTimer?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _stateProgressionTimer?.cancel();
    super.dispose();
  }
}

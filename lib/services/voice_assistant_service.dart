import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import '../models/note_model.dart';
import '../ai/infrastructure/knowledge_service.dart';
import '../ai/infrastructure/model_availability_service.dart';
import '../theme/app_preferences.dart';
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
  static final VoiceAssistantService _instance =
      VoiceAssistantService._internal();
  factory VoiceAssistantService() => _instance;
  VoiceAssistantService._internal() {
    _speechOutputChannel.setMethodCallHandler(_handleSpeechOutputCallback);
  }

  VoiceAssistantState _state = VoiceAssistantState.listening;
  VoiceAssistantState get state => _state;

  // Real-time audio amplitude for ripple (0.0 to 1.0)
  double _micAmplitude = 0.45;
  double get micAmplitude => _micAmplitude;

  // Live streaming user transcript (Listening State)
  final List<String> _userTranscriptLines = [];
  List<String> get userTranscriptLines =>
      List.unmodifiable(_userTranscriptLines);

  String _currentActiveUserSentence = "Discuss and summarize my notes...";
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
  String? _audioOutputError;
  String? get audioOutputError => _audioOutputError;

  static const _speechOutputChannel = MethodChannel('notechoes/speech_output');

  Future<void> _handleSpeechOutputCallback(MethodCall call) async {
    if (_state != VoiceAssistantState.speaking) return;
    switch (call.method) {
      case 'onSpeechSegment':
        final arguments = call.arguments as Map?;
        final index = arguments?['index'] as int?;
        if (index == null || index < 0 || index >= _aiLyricLines.length) return;
        _karaokeTimer?.cancel();
        _activeLyricIndex = index;
        _isPlayingAudio = true;
        notifyListeners();
        return;
      case 'onSpeechFinished':
        _karaokeTimer?.cancel();
        _isPlayingAudio = false;
        notifyListeners();
        return;
    }
  }

  String _summaryTitle = "Notes Summary & Action Items";
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

    final allNotes = NoteService().allNotes;
    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      _currentActiveUserSentence = initialPrompt;
    } else if (allNotes.isNotEmpty) {
      _currentActiveUserSentence =
          "Summarize my notes: ${allNotes.first.title}...";
    } else {
      _currentActiveUserSentence = "Discuss and summarize my notes...";
    }

    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    _activeLyricIndex = 0;
    _isPlayingAudio = false;
    _audioOutputError = null;

    // Load actual context notes from repository
    _contextualNotes = NoteService().getContextualNotesForQuery(
      _currentActiveUserSentence,
    );

    _startSimulatedMicInput();
    _startDynamicTranscriptStream();

    notifyListeners();
  }

  void stopVoiceSession() {
    _amplitudeTimer?.cancel();
    _transcriptStreamTimer?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _stateProgressionTimer?.cancel();
    _isPlayingAudio = false;
    _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
    notifyListeners();
  }

  void transitionToThinkingState([String? customPrompt]) {
    _amplitudeTimer?.cancel();
    _transcriptStreamTimer?.cancel();

    if (customPrompt != null && customPrompt.isNotEmpty) {
      _currentActiveUserSentence = customPrompt;
    }

    _contextualNotes = NoteService().getContextualNotesForQuery(
      _currentActiveUserSentence,
    );
    if (_contextualNotes.isEmpty) {
      _contextualNotes = NoteService().allNotes.take(4).toList();
    }

    _state = VoiceAssistantState.thinking;
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    notifyListeners();

    // Start 1-second step orbital rotation
    _startOrbitalStepScanner();

    // Auto progress to speaking state after 2.4 seconds of on-device note scanning
    _stateProgressionTimer?.cancel();
    _stateProgressionTimer = Timer(const Duration(milliseconds: 2400), () {
      transitionToSpeakingState();
    });
  }

  Future<void> transitionToSpeakingState() async {
    _orbitalStepTimer?.cancel();
    _stateProgressionTimer?.cancel();

    _state = VoiceAssistantState.speaking;
    _isPlayingAudio = true;
    _activeLyricIndex = 0;

    if (ModelAvailabilityService.instance.qwen.isReady) {
      final generated = await _setupModelResponseLyrics();
      if (!generated) _setupResponseLyrics();
    } else {
      _setupResponseLyrics();
    }
    _startKaraokePlayback();
    _speakRemainingResponse();

    notifyListeners();
  }

  void transitionToListeningState() {
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _stateProgressionTimer?.cancel();
    _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});

    startVoiceSession();
  }

  void setManualQuery(String query) {
    _currentActiveUserSentence = query;
    transitionToThinkingState(query);
  }

  void togglePlayPause() {
    _isPlayingAudio = !_isPlayingAudio;
    if (_isPlayingAudio) {
      _speakRemainingResponse();
      _startKaraokePlayback(startAt: _activeLyricIndex);
    } else {
      _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
      _karaokeTimer?.cancel();
    }
    notifyListeners();
  }

  void restartKaraoke() {
    _activeLyricIndex = 0;
    _isPlayingAudio = true;
    _startKaraokePlayback();
    _speakRemainingResponse();
    notifyListeners();
  }

  Future<Map<Object?, Object?>> audioOutputStatus() async {
    try {
      return await _speechOutputChannel.invokeMapMethod<Object?, Object?>(
            'audioStatus',
          ) ??
          const <Object?, Object?>{};
    } on PlatformException catch (error) {
      _audioOutputError = error.message ?? 'Could not inspect audio output.';
      return const <Object?, Object?>{};
    } on MissingPluginException {
      _audioOutputError = 'Spoken output is available when running on iPhone.';
      return const <Object?, Object?>{};
    }
  }

  Future<void> testSpeechOutput() async {
    _audioOutputError = null;
    try {
      await _speechOutputChannel.invokeMethod<Object?>('speak', {
        'text': 'NoteEchoes voice output is working.',
        'language': _speechLocale,
      });
    } on PlatformException catch (error) {
      _audioOutputError = error.message ?? 'Voice output is unavailable.';
      notifyListeners();
    }
  }

  void _startSimulatedMicInput() {
    _amplitudeTimer?.cancel();
    _amplitudeTimer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (_state == VoiceAssistantState.listening) {
        final base = 0.3 + 0.5 * sin(timer.tick * 0.25).abs();
        final noise = (_random.nextDouble() - 0.5) * 0.2;
        _micAmplitude = (base + noise).clamp(0.15, 0.95);
        notifyListeners();
      }
    });
  }

  void _startDynamicTranscriptStream() {
    _transcriptStreamTimer?.cancel();
    final allNotes = NoteService().allNotes;

    final phrases = <String>[
      "Listening to your voice...",
      allNotes.isNotEmpty
          ? "Analyzing ${allNotes.length} saved notes on-device..."
          : "Ready to capture your thoughts...",
      _currentActiveUserSentence,
    ];

    int step = 0;
    _transcriptStreamTimer = Timer.periodic(const Duration(milliseconds: 650), (
      timer,
    ) {
      if (_state == VoiceAssistantState.listening) {
        if (step < phrases.length) {
          _currentActiveUserSentence = phrases[step];
          step++;
          notifyListeners();
        } else {
          timer.cancel();
        }
      }
    });
  }

  void _startOrbitalStepScanner() {
    _orbitalStepTimer?.cancel();
    final n = max(_contextualNotes.length, 1);
    final stepAngle = 360.0 / n;

    _orbitalStepTimer = Timer.periodic(const Duration(milliseconds: 800), (
      timer,
    ) {
      if (_state == VoiceAssistantState.thinking) {
        _activeOrbitNoteIndex = (_activeOrbitNoteIndex + 1) % n;
        _orbitalAngleDegrees += stepAngle;
        notifyListeners();
      }
    });
  }

  void _setupResponseLyrics() {
    final allNotes = NoteService().allNotes;
    final matching = NoteService().getContextualNotesForQuery(
      _currentActiveUserSentence,
    );

    final List<SpokenLyricLine> lines = [];
    var elapsed = Duration.zero;

    if (allNotes.isEmpty) {
      // 0 notes in app
      lines.add(
        SpokenLyricLine(
          text: "You do not have any saved notes in notechoes yet.",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2000),
        ),
      );
      elapsed += const Duration(milliseconds: 2000);

      lines.add(
        SpokenLyricLine(
          text:
              "Tap the microphone button or use your Action Button to capture your first thought!",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2500),
        ),
      );

      _summaryTitle = "No Notes Found";
    } else {
      final relevantNotes = matching.isNotEmpty
          ? matching
          : allNotes.take(3).toList();

      lines.add(
        SpokenLyricLine(
          text: "I analyzed your saved notes using the on-device AI engine.",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2000),
        ),
      );
      elapsed += const Duration(milliseconds: 2000);

      lines.add(
        SpokenLyricLine(
          text: "Here is what I found in your notes:",
          startTime: elapsed,
          duration: const Duration(milliseconds: 1600),
        ),
      );
      elapsed += const Duration(milliseconds: 1600);

      for (int i = 0; i < min(relevantNotes.length, 3); i++) {
        final note = relevantNotes[i];
        final snippet = note.summarySnippet.isNotEmpty
            ? note.summarySnippet
            : note.textContent;
        final cleanSnippet = snippet.length > 90
            ? "${snippet.substring(0, 90)}..."
            : snippet;

        lines.add(
          SpokenLyricLine(
            text: "${i + 1}. ${note.title}: $cleanSnippet",
            startTime: elapsed,
            duration: const Duration(milliseconds: 2500),
          ),
        );
        elapsed += const Duration(milliseconds: 2500);
      }

      // Check for pending checklist items
      int totalChecklist = 0;
      for (final n in relevantNotes) {
        totalChecklist += n.checklist.where((c) => !c.isCompleted).length;
      }
      if (totalChecklist > 0) {
        lines.add(
          SpokenLyricLine(
            text:
                "You have $totalChecklist pending checklist action items across these notes.",
            startTime: elapsed,
            duration: const Duration(milliseconds: 2200),
          ),
        );
        elapsed += const Duration(milliseconds: 2200);
      }

      lines.add(
        SpokenLyricLine(
          text:
              "Would you like to open any of these notes or create a new one?",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2000),
        ),
      );

      _summaryTitle = relevantNotes.first.title;
    }

    _aiLyricLines = lines;
    _fullGeneratedResponse = _aiLyricLines.map((e) => e.text).join("\n\n");
  }

  Future<bool> _setupModelResponseLyrics() async {
    try {
      final response = await KnowledgeService.instance.askNotes(
        _currentActiveUserSentence,
      );
      final parts = response.displayText
          .split(RegExp(r'(?<=[.!?])\s+|\n+'))
          .map((part) => part.trim())
          .where((part) => part.isNotEmpty)
          .toList();
      if (parts.isEmpty) return false;
      var elapsed = Duration.zero;
      _aiLyricLines = parts.map((text) {
        final duration = Duration(
          milliseconds: (text.length * 48).clamp(1400, 5200),
        );
        final line = SpokenLyricLine(
          text: text,
          startTime: elapsed,
          duration: duration,
        );
        elapsed += duration;
        return line;
      }).toList();
      _fullGeneratedResponse = response.displayText;
      _summaryTitle = 'Conversation about your notes';
      return true;
    } catch (error) {
      debugPrint('Local conversational response failed: $error');
      return false;
    }
  }

  String get _speechLocale =>
      switch (AppPreferences.instance.speechLanguageCode) {
        'te' => 'te-IN',
        'hi' => 'hi-IN',
        _ => 'en-US',
      };

  Future<void> _speakRemainingResponse() async {
    if (_aiLyricLines.isEmpty) return;
    final text = _aiLyricLines
        .skip(_activeLyricIndex)
        .map((line) => line.text)
        .join(' ');
    final segments = _aiLyricLines
        .skip(_activeLyricIndex)
        .map((line) => line.text)
        .toList();
    try {
      await _speechOutputChannel.invokeMethod<Object?>('speak', {
        'text': text,
        'segments': segments,
        'startIndex': _activeLyricIndex,
        'language': _speechLocale,
      });
      _audioOutputError = null;
    } on MissingPluginException {
      _audioOutputError = 'Spoken output is available when running on iPhone.';
    } on PlatformException catch (error) {
      _audioOutputError =
          error.message ?? 'Could not play the spoken response.';
    }
    notifyListeners();
  }

  void _startKaraokePlayback({int startAt = 0}) {
    _karaokeTimer?.cancel();
    int current = startAt;

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
    _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
    super.dispose();
  }
}

// voice_assistant_service.dart
// Real conversational microphone capture, live amplitude HUD driving,
// offline WhisperKit transcription, and hybrid grounded answering.

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../models/note_model.dart';
import '../ai/domain/ai_models.dart';
import '../ai/infrastructure/offline_speech_bridge.dart';
import '../ai/infrastructure/hybrid_retrieval_service.dart';
import '../ai/infrastructure/language_detection_service.dart';
import '../ai/infrastructure/ai_database.dart';
import '../theme/app_preferences.dart';
import 'note_service.dart';
import 'speech_output_service.dart';
import 'checklist_status_service.dart';
import 'voice_capture_validator.dart';

enum VoiceAssistantState {
  listening, // Real mic recording + live amplitude ripple
  thinking, // Orbital Note scanning + Grounded Hybrid Retrieval
  speaking, // Spoken response + synchronized Karaoke lyric glow
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

  final AudioRecorder _audioRecorder = AudioRecorder();
  static const _speechOutputChannel = MethodChannel('noteechoes/speech_output');

  VoiceAssistantState _state = VoiceAssistantState.listening;
  VoiceAssistantState get state => _state;

  // Real-time audio amplitude for ripple (0.0 to 1.0)
  double _micAmplitude = 0.45;
  double get micAmplitude => _micAmplitude;

  // Live streaming user transcript
  final List<String> _userTranscriptLines = [];
  List<String> get userTranscriptLines =>
      List.unmodifiable(_userTranscriptLines);

  String _currentActiveUserSentence = "Listening to your voice…";
  String get currentActiveUserSentence => _currentActiveUserSentence;

  // Context Notes for Thinking State
  List<NoteModel> _contextualNotes = [];
  List<NoteModel> get contextualNotes => _contextualNotes;

  // Orbital Ring scanning index
  int _activeOrbitNoteIndex = 0;
  int get activeOrbitNoteIndex => _activeOrbitNoteIndex;

  double _orbitalAngleDegrees = 0.0;
  double get orbitalAngleDegrees => _orbitalAngleDegrees;

  // Spoken AI Response & Karaoke Lyrics
  List<SpokenLyricLine> _aiLyricLines = [];
  List<SpokenLyricLine> get aiLyricLines => _aiLyricLines;

  int _activeLyricIndex = 0;
  int get activeLyricIndex => _activeLyricIndex;

  bool _isPlayingAudio = false;
  bool get isPlayingAudio => _isPlayingAudio;
  String? _audioOutputError;
  String? get audioOutputError => _audioOutputError;

  String _summaryTitle = "Notes Summary & Grounded Insights";
  String get summaryTitle => _summaryTitle;

  String _fullGeneratedResponse = "";
  String get fullGeneratedResponse => _fullGeneratedResponse;

  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _orbitalStepTimer;
  Timer? _karaokeTimer;
  Timer? _speechStartWatchdog;
  String? _currentRecordingPath;
  bool _isProcessingQuery = false;

  Future<void> _handleSpeechOutputCallback(MethodCall call) async {
    if (_state != VoiceAssistantState.speaking) return;
    switch (call.method) {
      case 'onSpeechSegment':
        final arguments = call.arguments as Map?;
        final index = arguments?['index'] as int?;
        if (index == null || index < 0 || index >= _aiLyricLines.length) return;
        _speechStartWatchdog?.cancel();
        _audioOutputError = null;
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

  /// Starts real conversational microphone session.
  Future<void> startVoiceSession({String? initialPrompt}) async {
    _state = VoiceAssistantState.listening;
    _userTranscriptLines.clear();
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    _activeLyricIndex = 0;
    _isPlayingAudio = false;
    _audioOutputError = null;

    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      _currentActiveUserSentence = initialPrompt;
    } else {
      _currentActiveUserSentence = "Listening to your voice…";
    }

    _contextualNotes = NoteService().allNotes.take(4).toList();
    notifyListeners();

    await _startRealMicrophoneCapture();
  }

  Future<void> _startRealMicrophoneCapture() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _currentActiveUserSentence = "Listening to your voice…";
      notifyListeners();
      return;
    }

    try {
      final hasPermission = await _audioRecorder.hasPermission().timeout(
        const Duration(milliseconds: 250),
        onTimeout: () => false,
      );
      if (!hasPermission) {
        _currentActiveUserSentence = "Microphone ready.";
        notifyListeners();
        return;
      }

      final tempDir = await getTemporaryDirectory().timeout(
        const Duration(milliseconds: 250),
        onTimeout: () => Directory.systemTemp,
      );
      final audioPath =
          '${tempDir.path}/voice_assistant_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = audioPath;

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 16000),
        path: audioPath,
      );

      _amplitudeSub?.cancel();
      _amplitudeSub = _audioRecorder
          .onAmplitudeChanged(const Duration(milliseconds: 60))
          .listen((amp) {
            if (_state == VoiceAssistantState.listening) {
              // Normalize -60dB -> 0dB to 0.0 -> 1.0
              final normalized = ((amp.current + 50.0) / 50.0).clamp(0.08, 1.0);
              _micAmplitude = normalized;
              notifyListeners();
            }
          });
    } catch (e) {
      debugPrint("[VoiceAssistant] Failed to start audio recorder: $e");
      _currentActiveUserSentence = "Ready to discuss your notes.";
      notifyListeners();
    }
  }

  /// Stops voice session and cleans up resources.
  Future<void> stopVoiceSession() async {
    _amplitudeSub?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _speechStartWatchdog?.cancel();
    _isPlayingAudio = false;

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      notifyListeners();
      return;
    }

    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
      _cleanupTempAudio();
    } catch (_) {}

    _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
    notifyListeners();
  }

  /// Transitions to thinking state and executes hybrid grounded retrieval.
  Future<void> transitionToThinkingState([String? customPrompt]) async {
    _amplitudeSub?.cancel();

    if (_isProcessingQuery) return;
    _isProcessingQuery = true;

    String userSpokenText = customPrompt ?? "";

    // If we were recording audio, stop and transcribe via Whisper
    if (userSpokenText.isEmpty && _currentRecordingPath != null) {
      try {
        if (await _audioRecorder.isRecording()) {
          final path = await _audioRecorder.stop();
          if (path != null && File(path).existsSync()) {
            final langCode = AppPreferences.instance.speechLanguageCode;
            final audioLang = AudioLanguageExt.fromBcp47(langCode);
            final provenance = await OfflineSpeechBridge.instance
                .transcribeAudioFile(audioPath: path, language: audioLang);
            if (provenance.text.trim().isNotEmpty) {
              userSpokenText = VoiceCaptureValidator.sanitizeTranscript(
                provenance.text,
              );
            }
          }
        }
      } catch (e) {
        debugPrint("[VoiceAssistant] Transcription error: $e");
      }
    }

    _cleanupTempAudio();

    userSpokenText = VoiceCaptureValidator.sanitizeTranscript(userSpokenText);
    if (!VoiceCaptureValidator.hasMeaningfulSpeech(userSpokenText)) {
      userSpokenText = "Discuss and summarize my notes";
    }

    _currentActiveUserSentence = userSpokenText;
    _userTranscriptLines.add(userSpokenText);

    _state = VoiceAssistantState.thinking;
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    notifyListeners();

    _startOrbitalStepScanner();

    // Perform Grounded Retrieval
    try {
      final checklistAnswer = ChecklistStatusService.answer(
        userSpokenText,
        NoteService().allNotes,
      );
      if (checklistAnswer != null) {
        _fullGeneratedResponse = checklistAnswer.text;
        _summaryTitle = checklistAnswer.note.title;
        _aiLyricLines = [
          SpokenLyricLine(
            text: checklistAnswer.text,
            startTime: Duration.zero,
            duration: Duration(
              milliseconds: (checklistAnswer.text.length * 48).clamp(
                1800,
                6500,
              ),
            ),
          ),
        ];
        return await transitionToSpeakingState();
      }

      final queryLang = LanguageDetectionService.detect(
        userSpokenText,
      ).primaryLanguage;
      var candidates = await HybridRetrievalService.retrieveCandidates(
        query: userSpokenText,
        database: AiDatabase(),
        topK: 6,
      );

      // Broad summary requests are intentionally grounded in the user's most
      // recent notes. They should not depend on FTS matching words such as
      // "summarize", and newly restored notes may not be indexed yet.
      if (_isBroadSummaryRequest(userSpokenText) || candidates.isEmpty) {
        candidates = _fallbackCandidates(
          query: userSpokenText,
          includeRecentNotes: _isBroadSummaryRequest(userSpokenText),
        );
      }
      candidates = _hydrateCandidates(candidates);
      final candidateIds = candidates
          .map((candidate) => candidate.noteId)
          .toSet();
      _contextualNotes = NoteService().allNotes
          .where((note) => candidateIds.contains(note.noteId))
          .toList();

      final answer = await HybridRetrievalService.answerQuery(
        query: userSpokenText,
        candidates: candidates,
        queryLanguage: queryLang,
      );

      _fullGeneratedResponse = answer.displayText;
      _summaryTitle = _isBroadSummaryRequest(userSpokenText)
          ? 'Conversation summary'
          : candidates.isNotEmpty
          ? candidates.first.title
          : 'Notes Summary';

      // Setup lyric lines for Karaoke
      final parts = answer.displayText
          .split(RegExp(r'(?<=[.!?])\s+|\n+'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

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

      if (_aiLyricLines.isEmpty) {
        _aiLyricLines = [
          SpokenLyricLine(
            text: answer.displayText,
            startTime: Duration.zero,
            duration: const Duration(milliseconds: 3000),
          ),
        ];
      }
    } catch (e) {
      debugPrint("[VoiceAssistant] Grounded answer error: $e");
      _setupResponseLyrics();
    } finally {
      _isProcessingQuery = false;
    }

    await transitionToSpeakingState();
  }

  bool _isBroadSummaryRequest(String query) {
    final lower = query.toLowerCase();
    return RegExp(
      r'\b(?:summari[sz]e|summary|overview|recap|discuss|review)\b|'
      r'(?:సారాంశం|సంగ్రహించు|నోట్స్\s+చెప్పు)|'
      r'(?:सारांश|संक्षेप|नोट्स\s+बताओ)',
      caseSensitive: false,
    ).hasMatch(lower);
  }

  List<HybridCandidate> _fallbackCandidates({
    required String query,
    required bool includeRecentNotes,
  }) {
    final notes = NoteService().allNotes;
    final queryTerms = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.length > 2)
        .toSet();
    final ranked =
        notes
            .map((note) {
              final searchable =
                  '${note.title} ${note.summarySnippet} '
                          '${note.textContent} ${note.tags.join(' ')}'
                      .toLowerCase();
              final score = includeRecentNotes
                  ? 1.0
                  : queryTerms.where(searchable.contains).length.toDouble();
              return (note: note, score: score);
            })
            .where((entry) => entry.score > 0)
            .toList()
          ..sort((a, b) {
            final byScore = b.score.compareTo(a.score);
            return byScore != 0
                ? byScore
                : b.note.createdAt.compareTo(a.note.createdAt);
          });

    return ranked.take(6).map((entry) {
      final note = entry.note;
      final passage = _notePassage(note);
      return HybridCandidate(
        noteId: note.noteId,
        title: note.title,
        passageText: passage,
        rrfScore: entry.score,
        isPinned: note.isPinned,
        updatedAt: note.createdAt.millisecondsSinceEpoch,
      );
    }).toList();
  }

  List<HybridCandidate> _hydrateCandidates(List<HybridCandidate> candidates) {
    final notesById = {
      for (final note in NoteService().allNotes) note.noteId: note,
    };
    return candidates
        .map((candidate) {
          final note = notesById[candidate.noteId];
          if (note == null) return candidate;
          final passage = _notePassage(note);
          return HybridCandidate(
            noteId: candidate.noteId,
            title: note.title.trim().isEmpty ? 'Untitled note' : note.title,
            passageText: passage,
            ftsRank: candidate.ftsRank,
            semanticRank: candidate.semanticRank,
            rrfScore: candidate.rrfScore,
            isPinned: note.isPinned,
            updatedAt: note.createdAt.millisecondsSinceEpoch,
          );
        })
        .where((candidate) => candidate.passageText.trim().isNotEmpty)
        .toList();
  }

  String _notePassage(NoteModel note) {
    final parts = <String>[
      if (note.textContent.trim().isNotEmpty) note.textContent.trim(),
      if (note.textContent.trim().isEmpty &&
          note.summarySnippet.trim().isNotEmpty)
        note.summarySnippet.trim(),
      ...note.checklist
          .where((item) => item.text.trim().isNotEmpty)
          .map(
            (item) =>
                '${item.isCompleted ? 'Done' : 'To do'}: ${item.text.trim()}',
          ),
      ...note.contentBlocks
          .map((block) => block.searchableText.trim())
          .where((text) => text.isNotEmpty),
    ];
    return parts.toSet().join('\n');
  }

  Future<void> transitionToSpeakingState() async {
    _orbitalStepTimer?.cancel();
    _state = VoiceAssistantState.speaking;
    _isPlayingAudio = true;
    _activeLyricIndex = 0;

    if (_aiLyricLines.isEmpty) {
      _setupResponseLyrics();
    }

    // Give iOS a moment to release the recording route before activating the
    // speaker. This prevents the first utterance from being silently queued.
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Future<void>.delayed(const Duration(milliseconds: 180));
    }
    await _speakRemainingResponse();

    notifyListeners();
  }

  Future<Map<String, dynamic>> audioOutputStatus() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      return {
        'outputVolume': 1.0,
        'route': 'iPhone speaker',
        'speaking': _isPlayingAudio,
        'voice': 'System voice',
        'voiceQuality': 'Standard',
      };
    }
    try {
      final Map? status = await _speechOutputChannel.invokeMapMethod(
        'audioStatus',
      );
      if (status != null) {
        return status.cast<String, dynamic>();
      }
    } catch (_) {}
    return {
      'outputVolume': 1.0,
      'route': 'iPhone speaker',
      'speaking': _isPlayingAudio,
      'voice': 'System voice',
      'voiceQuality': 'Standard',
    };
  }

  Future<void> testSpeechOutput() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    await SpeechOutputService.instance.speak(
      text: 'NoteEchoes on-device intelligence is ready.',
      language: _speechLocale,
    );
  }

  void transitionToListeningState() {
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _speechStartWatchdog?.cancel();
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
    } else {
      _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
      _karaokeTimer?.cancel();
    }
    notifyListeners();
  }

  void restartKaraoke() {
    _activeLyricIndex = 0;
    _isPlayingAudio = true;
    _speakRemainingResponse();
    notifyListeners();
  }

  @visibleForTesting
  void beginThinkingForTesting() {
    _state = VoiceAssistantState.thinking;
    notifyListeners();
  }

  @visibleForTesting
  void completeReportForTesting({
    String title = 'Test report',
    String response = 'A grounded test report.',
  }) {
    _summaryTitle = title;
    _fullGeneratedResponse = response;
    _aiLyricLines = [
      SpokenLyricLine(
        text: response,
        startTime: Duration.zero,
        duration: const Duration(seconds: 2),
      ),
    ];
    _state = VoiceAssistantState.speaking;
    _isPlayingAudio = false;
    notifyListeners();
  }

  void _startOrbitalStepScanner() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
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
    final List<SpokenLyricLine> lines = [];
    var elapsed = Duration.zero;

    if (allNotes.isEmpty) {
      lines.add(
        SpokenLyricLine(
          text: "You do not have any saved notes in NoteEchoes yet.",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2000),
        ),
      );
      elapsed += const Duration(milliseconds: 2000);
      lines.add(
        SpokenLyricLine(
          text:
              "Tap the microphone button or Action Button to capture your first thought!",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2500),
        ),
      );
    } else {
      lines.add(
        SpokenLyricLine(
          text: "Here is what I found in your notes:",
          startTime: elapsed,
          duration: const Duration(milliseconds: 1600),
        ),
      );
      elapsed += const Duration(milliseconds: 1600);

      for (int i = 0; i < min(allNotes.length, 3); i++) {
        final note = allNotes[i];
        lines.add(
          SpokenLyricLine(
            text: "${i + 1}. ${note.title}",
            startTime: elapsed,
            duration: const Duration(milliseconds: 2000),
          ),
        );
        elapsed += const Duration(milliseconds: 2000);
      }
    }

    _aiLyricLines = lines;
    _fullGeneratedResponse = lines.map((l) => l.text).join('\n\n');
  }

  String get _speechLocale =>
      switch (AppPreferences.instance.speechLanguageCode) {
        'te' => 'te-IN',
        'hi' => 'hi-IN',
        _ => 'en-US',
      };

  Future<void> _speakRemainingResponse() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
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
      _speechStartWatchdog?.cancel();
      final response = await _speechOutputChannel
          .invokeMapMethod<String, dynamic>('speak', {
            'text': text,
            'segments': segments,
            'startIndex': _activeLyricIndex,
            'language': _speechLocale,
          })
          .timeout(const Duration(seconds: 3));
      if (response?['started'] != true) {
        throw PlatformException(
          code: 'SPEECH_NOT_STARTED',
          message: 'The iPhone speaker did not start.',
        );
      }
      _speechStartWatchdog = Timer(
        const Duration(milliseconds: 1400),
        () async {
          if (_state != VoiceAssistantState.speaking || !_isPlayingAudio) {
            return;
          }
          final status = await audioOutputStatus();
          if (status['speaking'] != true) {
            _isPlayingAudio = false;
            _audioOutputError =
                'Voice could not start. Tap Replay and check iPhone volume.';
            notifyListeners();
          }
        },
      );
    } on MissingPluginException {
      _audioOutputError = 'Spoken output is available when running on iPhone.';
    } on PlatformException catch (error) {
      _audioOutputError =
          error.message ?? 'Could not play the spoken response.';
    } on TimeoutException {
      _isPlayingAudio = false;
      _audioOutputError = 'Voice took too long to start. Tap Replay.';
    } catch (_) {
      _isPlayingAudio = false;
      _audioOutputError = 'Could not play the spoken response. Tap Replay.';
    }
    notifyListeners();
  }

  void _cleanupTempAudio() {
    if (_currentRecordingPath != null) {
      try {
        final f = File(_currentRecordingPath!);
        if (f.existsSync()) f.deleteSync();
      } catch (_) {}
      _currentRecordingPath = null;
    }
  }

  @override
  void dispose() {
    _amplitudeSub?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _speechStartWatchdog?.cancel();
    _cleanupTempAudio();
    super.dispose();
  }
}

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
import 'personal_memory_answer_service.dart';
import 'voice_capture_validator.dart';
import 'web_knowledge_service.dart';

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

  AudioRecorder? _audioRecorder;
  AudioRecorder get _recorder => _audioRecorder ??= AudioRecorder();
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

  String _processingStatus = 'Listening…';
  String get processingStatus => _processingStatus;

  String _reportSourceLabel = 'Private • On-device';
  String get reportSourceLabel => _reportSourceLabel;

  String _fullGeneratedResponse = "";
  String get fullGeneratedResponse => _fullGeneratedResponse;

  StreamSubscription<Amplitude>? _amplitudeSub;
  Timer? _orbitalStepTimer;
  Timer? _karaokeTimer;
  Timer? _speechStartWatchdog;
  Timer? _silenceTimer;
  String? _currentRecordingPath;
  bool _isProcessingQuery = false;
  bool _heardVoiceActivity = false;
  bool _autoSubmitTriggered = false;
  double _noiseFloorDb = -55.0;
  int _probableVoiceFrameStreak = 0;
  DateTime? _recordingStartedAt;
  DateTime? _lastVoiceActivityAt;
  int _queryEpoch = 0;
  String _activeResponseLocale = 'en-US';
  WebKnowledgeService? _webKnowledgeService;
  WebKnowledgeService get _webKnowledge =>
      _webKnowledgeService ??= WebKnowledgeService();

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
    _queryEpoch++;
    _isProcessingQuery = false;
    _state = VoiceAssistantState.listening;
    _userTranscriptLines.clear();
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    _activeLyricIndex = 0;
    _isPlayingAudio = false;
    _audioOutputError = null;
    _fullGeneratedResponse = '';
    _aiLyricLines = [];
    _summaryTitle = 'Conversation';
    _reportSourceLabel = 'Private • On-device';
    _processingStatus = 'Listening…';
    _activeResponseLocale = _preferredSpeechLocale;

    if (initialPrompt != null && initialPrompt.isNotEmpty) {
      _currentActiveUserSentence = initialPrompt;
    } else {
      _currentActiveUserSentence = "Listening to your voice…";
    }

    _contextualNotes = NoteService().allNotes.take(4).toList();
    notifyListeners();

    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        await _speechOutputChannel.invokeMethod<void>('stop');
      } catch (_) {}
    }
    await _startRealMicrophoneCapture();
  }

  Future<void> _startRealMicrophoneCapture() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      _currentActiveUserSentence = "Listening to your voice…";
      notifyListeners();
      return;
    }

    try {
      final hasPermission = await _recorder.hasPermission().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      if (!hasPermission) {
        _currentActiveUserSentence =
            "Microphone permission is required to hear your question.";
        notifyListeners();
        return;
      }

      final tempDir = await getTemporaryDirectory().timeout(
        const Duration(seconds: 1),
        onTimeout: () => Directory.systemTemp,
      );
      final audioPath =
          '${tempDir.path}/voice_assistant_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = audioPath;

      await _recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: audioPath,
      );
      // AVAudioRecorder file capture does not enable Apple's voice-processing
      // path by itself. Apply voiceChat mode after the recorder configures its
      // play-and-record session so stationary noise and acoustic echo are
      // reduced before turn detection and transcription.
      try {
        await _speechOutputChannel.invokeMethod<void>('prepareVoiceCapture');
      } catch (error) {
        debugPrint('[VoiceAssistant] Voice processing unavailable: $error');
      }

      _recordingStartedAt = DateTime.now();
      _lastVoiceActivityAt = null;
      _heardVoiceActivity = false;
      _autoSubmitTriggered = false;
      _noiseFloorDb = -55.0;
      _probableVoiceFrameStreak = 0;
      _startSilenceMonitor();

      _amplitudeSub?.cancel();
      _amplitudeSub = _recorder
          .onAmplitudeChanged(const Duration(milliseconds: 60))
          .listen((amp) {
            if (_state == VoiceAssistantState.listening) {
              // Normalize -60dB -> 0dB to 0.0 -> 1.0
              final normalized = ((amp.current + 50.0) / 50.0).clamp(0.08, 1.0);
              _micAmplitude = normalized;
              final probableVoice = _observeAudioFrame(amp.current);
              if (probableVoice) {
                _lastVoiceActivityAt = DateTime.now();
                if (!_heardVoiceActivity) {
                  _heardVoiceActivity = true;
                  _currentActiveUserSentence =
                      "I hear you — pause when your question is finished.";
                }
              }
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
    _queryEpoch++;
    _isProcessingQuery = false;
    _amplitudeSub?.cancel();
    _orbitalStepTimer?.cancel();
    _karaokeTimer?.cancel();
    _speechStartWatchdog?.cancel();
    _silenceTimer?.cancel();
    _isPlayingAudio = false;

    if (Platform.environment.containsKey('FLUTTER_TEST')) {
      notifyListeners();
      return;
    }

    try {
      if (await _recorder.isRecording()) {
        await _recorder.stop();
      }
      _cleanupTempAudio();
    } catch (_) {}

    _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
    notifyListeners();
  }

  void _startSilenceMonitor() {
    _silenceTimer?.cancel();
    _silenceTimer = Timer.periodic(const Duration(milliseconds: 220), (_) {
      if (_state != VoiceAssistantState.listening || _autoSubmitTriggered) {
        return;
      }
      final now = DateTime.now();
      final startedAt = _recordingStartedAt;
      if (startedAt == null) return;
      final listeningFor = now.difference(startedAt);
      final lastVoice = _lastVoiceActivityAt;
      if (_shouldAutoSubmit(
        heardVoice: _heardVoiceActivity,
        listeningFor: listeningFor,
        silenceFor: lastVoice == null
            ? Duration.zero
            : now.difference(lastVoice),
      )) {
        _autoSubmitTriggered = true;
        _silenceTimer?.cancel();
        unawaited(transitionToThinkingState());
      } else if (!_heardVoiceActivity &&
          listeningFor >= const Duration(seconds: 20)) {
        _recordingStartedAt = now;
        _currentActiveUserSentence =
            "Still listening — ask whenever you are ready.";
        notifyListeners();
      }
    });
  }

  static bool _shouldAutoSubmit({
    required bool heardVoice,
    required Duration listeningFor,
    required Duration silenceFor,
  }) =>
      heardVoice &&
      listeningFor >= const Duration(milliseconds: 1400) &&
      (silenceFor >= const Duration(milliseconds: 900) ||
          listeningFor >= const Duration(seconds: 25));

  bool _observeAudioFrame(double decibels) {
    if (!decibels.isFinite || decibels <= -100) {
      _probableVoiceFrameStreak = 0;
      return false;
    }

    final startedAt = _recordingStartedAt;
    final calibrating =
        startedAt != null &&
        DateTime.now().difference(startedAt) <
            const Duration(milliseconds: 450);
    final voiceThreshold = _voiceThresholdForNoiseFloor(_noiseFloorDb);
    final aboveVoiceThreshold = decibels >= voiceThreshold;

    // Learn the room floor only from frames that are not probable speech.
    // This adapts to a fan or road noise without allowing that sound to keep a
    // turn open forever.
    if (!aboveVoiceThreshold || calibrating) {
      final capped = decibels.clamp(-75.0, -28.0);
      final weight = calibrating ? 0.18 : 0.035;
      _noiseFloorDb = (_noiseFloorDb * (1 - weight)) + (capped * weight);
    }

    if (calibrating) {
      _probableVoiceFrameStreak = 0;
      return false;
    }

    if (decibels >= _voiceThresholdForNoiseFloor(_noiseFloorDb)) {
      _probableVoiceFrameStreak++;
    } else {
      _probableVoiceFrameStreak = 0;
    }

    // Four 60 ms frames reject taps, gasps, and brief environmental sounds.
    return _probableVoiceFrameStreak >= 4;
  }

  static double _voiceThresholdForNoiseFloor(double noiseFloorDb) =>
      max(-50.0, noiseFloorDb + 8.0);

  @visibleForTesting
  static bool isProbableVoiceLevelForTesting({
    required double noiseFloorDb,
    required double levelDb,
  }) => levelDb >= _voiceThresholdForNoiseFloor(noiseFloorDb);

  @visibleForTesting
  static bool shouldAutoSubmitForTesting({
    required bool heardVoice,
    required Duration listeningFor,
    required Duration silenceFor,
  }) => _shouldAutoSubmit(
    heardVoice: heardVoice,
    listeningFor: listeningFor,
    silenceFor: silenceFor,
  );

  /// Transitions to thinking state and executes hybrid grounded retrieval.
  Future<void> transitionToThinkingState([String? customPrompt]) async {
    _amplitudeSub?.cancel();
    _silenceTimer?.cancel();

    if (_isProcessingQuery) return;
    _isProcessingQuery = true;
    final queryEpoch = ++_queryEpoch;

    _state = VoiceAssistantState.thinking;
    _processingStatus = customPrompt?.trim().isNotEmpty == true
        ? 'Understanding your question…'
        : 'Transcribing your question…';
    _activeOrbitNoteIndex = 0;
    _orbitalAngleDegrees = 0.0;
    _fullGeneratedResponse = '';
    _aiLyricLines = [];
    _summaryTitle = 'Working on your question';
    _contextualNotes = [];
    _reportSourceLabel = 'Private • On-device';
    _audioOutputError = null;
    notifyListeners();
    _startOrbitalStepScanner();

    String userSpokenText = customPrompt ?? "";
    String? stoppedRecordingPath;

    // Always release the microphone before retrieval or playback. A typed
    // question must not leave the recorder holding the iOS audio session.
    if (_currentRecordingPath != null) {
      try {
        if (await _recorder.isRecording()) {
          stoppedRecordingPath = await _recorder.stop();
        }
        if (userSpokenText.isEmpty) {
          final path = stoppedRecordingPath ?? _currentRecordingPath;
          if (path != null && File(path).existsSync()) {
            final langCode = AppPreferences.instance.speechLanguageCode;
            final audioLang = AudioLanguageExt.fromBcp47(langCode);
            final provenance = await OfflineSpeechBridge.instance
                .transcribeAudioFile(audioPath: path, language: audioLang)
                .timeout(const Duration(seconds: 10));
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
    if (queryEpoch != _queryEpoch) return;

    userSpokenText = VoiceCaptureValidator.sanitizeTranscript(userSpokenText);
    if (!VoiceCaptureValidator.hasMeaningfulSpeech(userSpokenText)) {
      _isProcessingQuery = false;
      _state = VoiceAssistantState.listening;
      _processingStatus = 'Listening…';
      _currentActiveUserSentence =
          "I didn't catch a complete question. Please try again.";
      _orbitalStepTimer?.cancel();
      notifyListeners();
      if (!Platform.environment.containsKey('FLUTTER_TEST')) {
        await Future<void>.delayed(const Duration(milliseconds: 450));
        if (queryEpoch == _queryEpoch) await _startRealMicrophoneCapture();
      }
      return;
    }

    _currentActiveUserSentence = userSpokenText;
    _userTranscriptLines.add(userSpokenText);
    final queryDetection = LanguageDetectionService.detect(userSpokenText);
    final queryLang = queryDetection.primaryLanguage;
    _activeResponseLocale = _speechLocaleForDetection(queryDetection);
    _processingStatus = 'Searching your notes…';
    notifyListeners();

    // Perform Grounded Retrieval
    try {
      final memoryAnswer = PersonalMemoryAnswerService.answer(
        userSpokenText,
        NoteService().allNotes,
      );
      if (memoryAnswer != null) {
        if (queryEpoch != _queryEpoch) return;
        _contextualNotes = memoryAnswer.sourceNotes;
        _reportSourceLabel = 'Your notes • Private • On-device';
        _setGeneratedResponse(memoryAnswer.title, memoryAnswer.text);
        _processingStatus = 'Report ready';
        return await transitionToSpeakingState();
      }

      final checklistAnswer = ChecklistStatusService.answer(
        userSpokenText,
        NoteService().allNotes,
      );
      if (checklistAnswer != null) {
        if (queryEpoch != _queryEpoch) return;
        _contextualNotes = [checklistAnswer.note];
        _reportSourceLabel = 'Your notes • Private • On-device';
        _setGeneratedResponse(checklistAnswer.note.title, checklistAnswer.text);
        _processingStatus = 'Report ready';
        return await transitionToSpeakingState();
      }

      List<HybridCandidate> candidates;
      try {
        candidates = await HybridRetrievalService.retrieveCandidates(
          query: userSpokenText,
          database: AiDatabase(),
          topK: 6,
        ).timeout(const Duration(seconds: 8));
      } on TimeoutException {
        candidates = _fallbackCandidates(
          query: userSpokenText,
          includeRecentNotes: _isBroadSummaryRequest(userSpokenText),
        );
      }

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
      candidates = _relevantCandidates(userSpokenText, candidates);

      if (candidates.isEmpty) {
        if (queryEpoch != _queryEpoch) return;
        await _answerFromWeb(
          question: userSpokenText,
          queryLanguage: queryLang,
          queryEpoch: queryEpoch,
        );
        if (queryEpoch != _queryEpoch) return;
        _processingStatus = 'Report ready';
        return await transitionToSpeakingState();
      }

      final candidateIds = candidates
          .map((candidate) => candidate.noteId)
          .toSet();
      _contextualNotes = NoteService().allNotes
          .where((note) => candidateIds.contains(note.noteId))
          .toList();
      _reportSourceLabel = 'Your notes • Private • On-device';
      _processingStatus = 'Preparing a grounded answer…';
      notifyListeners();

      GroundedAnswerResult answer;
      try {
        answer = await HybridRetrievalService.answerQuery(
          query: userSpokenText,
          candidates: candidates,
          queryLanguage: queryLang,
        ).timeout(const Duration(seconds: 12));
      } on TimeoutException {
        answer = await HybridRetrievalService.answerQuery(
          query: userSpokenText,
          candidates: candidates,
          queryLanguage: queryLang,
          forceExtractive: true,
        );
      }
      if (queryEpoch != _queryEpoch) return;

      final title = _isBroadSummaryRequest(userSpokenText)
          ? 'Conversation summary'
          : candidates.isNotEmpty
          ? candidates.first.title
          : 'Notes Summary';

      _setGeneratedResponse(title, answer.displayText);
      _processingStatus = 'Report ready';
    } catch (e) {
      debugPrint("[VoiceAssistant] Grounded answer error: $e");
      _contextualNotes = [];
      _reportSourceLabel = 'No source used';
      _setGeneratedResponse(
        'I couldn’t complete that answer',
        'I could not reliably answer that question. Please try again in a moment.',
      );
      _processingStatus = 'Report ready';
    } finally {
      if (queryEpoch == _queryEpoch) _isProcessingQuery = false;
    }

    if (queryEpoch == _queryEpoch) await transitionToSpeakingState();
  }

  void _setGeneratedResponse(String title, String text) {
    _fullGeneratedResponse = text;
    _summaryTitle = title;
    final parts = text
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
          text: text,
          startTime: Duration.zero,
          duration: const Duration(milliseconds: 3000),
        ),
      ];
    }
  }

  Future<void> _answerFromWeb({
    required String question,
    required String queryLanguage,
    required int queryEpoch,
  }) async {
    _processingStatus = 'Not found in notes • Searching the web…';
    _contextualNotes = [];
    notifyListeners();

    final result = await _webKnowledge.answer(
      question,
      languageCode: queryLanguage,
    );
    if (queryEpoch != _queryEpoch) return;
    switch (result.status) {
      case WebKnowledgeStatus.answered:
        _reportSourceLabel = 'Web • Wikipedia';
        final sourceUrl = result.sourceUrl?.toString() ?? '';
        _setGeneratedResponse(
          result.sourceTitle,
          '${result.answer}\n\nSources\n\n• ${result.sourceTitle}'
          '${sourceUrl.isEmpty ? '' : '\n$sourceUrl'}',
        );
        return;
      case WebKnowledgeStatus.offline:
        _reportSourceLabel = 'No source used';
        _setGeneratedResponse(
          'Not found in your notes',
          'There is nothing about that in your notes, and the web is not available right now. Connect to the internet and ask me again if you want me to search the web.',
        );
        return;
      case WebKnowledgeStatus.noReliableResult:
        _reportSourceLabel = 'No reliable source found';
        _setGeneratedResponse(
          'I need a little more detail',
          'There is nothing about that in your notes, and I could not find a reliable web answer. Try asking again with a more specific name or topic.',
        );
        return;
    }
  }

  List<HybridCandidate> _relevantCandidates(
    String query,
    List<HybridCandidate> candidates,
  ) {
    if (_isBroadSummaryRequest(query)) return candidates;
    final terms = query
        .toLowerCase()
        .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
        .split(RegExp(r'\s+'))
        .where((term) => term.length >= 2 && !_queryStopWords.contains(term))
        .toSet();
    if (terms.isEmpty) return const [];
    return candidates.where((candidate) {
      final candidateTerms = '${candidate.title} ${candidate.passageText}'
          .toLowerCase();
      final tokens = candidateTerms
          .replaceAll(RegExp(r'[^\p{L}\p{N}\s]+', unicode: true), ' ')
          .split(RegExp(r'\s+'))
          .where((term) => term.isNotEmpty)
          .toSet();
      return terms.any(tokens.contains);
    }).toList();
  }

  @visibleForTesting
  bool hasRelevantEvidenceForTesting({
    required String query,
    required String title,
    required String text,
  }) => _relevantCandidates(query, [
    HybridCandidate(
      noteId: 'test-note',
      title: title,
      passageText: text,
      rrfScore: 1,
    ),
  ]).isNotEmpty;

  static const _queryStopWords = <String>{
    'about',
    'and',
    'answer',
    'calculate',
    'could',
    'explain',
    'for',
    'find',
    'from',
    'give',
    'have',
    'how',
    'in',
    'is',
    'it',
    'know',
    'me',
    'my',
    'notes',
    'of',
    'on',
    'or',
    'please',
    'show',
    'tell',
    'to',
    'that',
    'the',
    'their',
    'there',
    'these',
    'this',
    'value',
    'what',
    'when',
    'where',
    'which',
    'who',
    'why',
    'with',
    'would',
    'your',
  };

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
    _isPlayingAudio = false;
    _activeLyricIndex = 0;

    if (_aiLyricLines.isEmpty) {
      _setupResponseLyrics();
    }

    // Publish the finished report first. The screen opens the 3/4-height
    // report sheet from this notification; speech starts only after that frame
    // is visible, matching the user's expectation and avoiding route races.
    notifyListeners();
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
    await _speakRemainingResponse();
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

  Future<void> handleRecognitionLanguageChanged() async {
    _queryEpoch++;
    _silenceTimer?.cancel();
    _amplitudeSub?.cancel();
    _isProcessingQuery = false;
    _isPlayingAudio = false;
    _audioOutputError = null;
    _activeResponseLocale = _preferredSpeechLocale;
    if (!Platform.environment.containsKey('FLUTTER_TEST')) {
      try {
        if (await _recorder.isRecording()) {
          await _recorder.stop();
        }
      } catch (_) {}
      try {
        await _speechOutputChannel.invokeMethod<void>('stop');
      } catch (_) {}
    }
    _cleanupTempAudio();
    notifyListeners();
  }

  void setManualQuery(String query) {
    _currentActiveUserSentence = query;
    transitionToThinkingState(query);
  }

  void togglePlayPause() {
    if (_isPlayingAudio) {
      _isPlayingAudio = false;
      _speechOutputChannel.invokeMethod<void>('stop').catchError((_) {});
      _karaokeTimer?.cancel();
      notifyListeners();
    } else {
      _speakRemainingResponse();
    }
  }

  void restartKaraoke() {
    _activeLyricIndex = 0;
    _speakRemainingResponse();
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

  String get _preferredSpeechLocale =>
      switch (AppPreferences.instance.speechLanguageCode) {
        'te' => 'te-IN',
        'te-en-mixed' => 'te-IN',
        'hi' => 'hi-IN',
        _ => 'en-US',
      };

  String _speechLocaleForDetection(LanguageDetectionResult detection) =>
      switch (detection.primaryLanguage) {
        'te' => 'te-IN',
        'mixed' when detection.mixedLanguages.contains('te') => 'te-IN',
        'mixed' when detection.mixedLanguages.contains('hi') => 'hi-IN',
        'hi' => 'hi-IN',
        _ => 'en-US',
      };

  String get _speechLocale => _activeResponseLocale;

  Future<void> _speakRemainingResponse() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (_aiLyricLines.isEmpty) return;
    final text = _aiLyricLines
        .skip(_activeLyricIndex)
        .map((line) => line.text)
        .join(' ');
    final segments = _aiLyricLines
        .skip(_activeLyricIndex)
        .map((line) => SpeechOutputService.cleanSpeechText(line.text))
        .where((line) => line.isNotEmpty)
        .toList();

    try {
      _speechStartWatchdog?.cancel();
      _isPlayingAudio = false;
      _audioOutputError = null;
      notifyListeners();
      final response = await _speechOutputChannel
          .invokeMapMethod<String, dynamic>('speak', {
            'text': text,
            'segments': segments,
            'startIndex': _activeLyricIndex,
            'language': _speechLocale,
          })
          .timeout(const Duration(seconds: 8));
      if (response?['started'] != true) {
        throw PlatformException(
          code: 'SPEECH_NOT_STARTED',
          message: 'The iPhone speaker did not start.',
        );
      }
      _speechStartWatchdog = Timer(
        const Duration(milliseconds: 2500),
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
      _isPlayingAudio = false;
      _audioOutputError =
          'The iPhone speech bridge did not load. Close and reopen NoteEchoes.';
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
    _silenceTimer?.cancel();
    _cleanupTempAudio();
    super.dispose();
  }
}

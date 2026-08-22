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
import '../ai/infrastructure/model_availability_service.dart';
import '../ai/infrastructure/ai_database.dart';
import '../theme/app_preferences.dart';
import 'note_service.dart';
import 'speech_output_service.dart';

enum VoiceAssistantState {
  listening, // Real mic recording + live amplitude ripple
  thinking,  // Orbital Note scanning + Grounded Hybrid Retrieval
  speaking,  // Spoken response + synchronized Karaoke lyric glow
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

  VoiceAssistantService._internal() {
    _speechOutputChannel.setMethodCallHandler(_handleSpeechOutputCallback);
  }

  final AudioRecorder _audioRecorder = AudioRecorder();
  static const _speechOutputChannel = MethodChannel('noteechoes/speech_output');
  static const _offlineSpeechChannel = MethodChannel('noteechoes/offline_speech');

  VoiceAssistantState _state = VoiceAssistantState.listening;
  VoiceAssistantState get state => _state;

  // Real-time audio amplitude for ripple (0.0 to 1.0)
  double _micAmplitude = 0.45;
  double get micAmplitude => _micAmplitude;

  // Live streaming user transcript
  final List<String> _userTranscriptLines = [];
  List<String> get userTranscriptLines => List.unmodifiable(_userTranscriptLines);

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
  String? _currentRecordingPath;
  bool _isProcessingQuery = false;

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
      final audioPath = '${tempDir.path}/voice_assistant_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentRecordingPath = audioPath;

      await _audioRecorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc, sampleRate: 16000),
        path: audioPath,
      );

      _amplitudeSub?.cancel();
      _amplitudeSub = _audioRecorder.onAmplitudeChanged(const Duration(milliseconds: 60)).listen((amp) {
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
    _isPlayingAudio = false;

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
            final provenance = await OfflineSpeechBridge.instance.transcribeAudioFile(
              audioPath: path,
              language: audioLang,
            );
            if (provenance.text.trim().isNotEmpty) {
              userSpokenText = provenance.text.trim();
            }
          }
        }
      } catch (e) {
        debugPrint("[VoiceAssistant] Transcription error: $e");
      }
    }

    _cleanupTempAudio();

    if (userSpokenText.isEmpty) {
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
      final queryLang = LanguageDetectionService.detect(userSpokenText).primaryLanguage;
      final candidates = await HybridRetrievalService.retrieveCandidates(
        query: userSpokenText,
        database: AiDatabase(),
        topK: 6,
      );

      final answer = await HybridRetrievalService.answerQuery(
        query: userSpokenText,
        candidates: candidates,
        queryLanguage: queryLang,
      );

      _fullGeneratedResponse = answer.displayText;
      _summaryTitle = candidates.isNotEmpty ? candidates.first.title : "Notes Summary";

      // Setup lyric lines for Karaoke
      final parts = answer.displayText
          .split(RegExp(r'(?<=[.!?])\s+|\n+'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();

      var elapsed = Duration.zero;
      _aiLyricLines = parts.map((text) {
        final duration = Duration(milliseconds: (text.length * 48).clamp(1400, 5200));
        final line = SpokenLyricLine(text: text, startTime: elapsed, duration: duration);
        elapsed += duration;
        return line;
      }).toList();

      if (_aiLyricLines.isEmpty) {
        _aiLyricLines = [
          SpokenLyricLine(
            text: answer.displayText,
            startTime: Duration.zero,
            duration: const Duration(milliseconds: 3000),
          )
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

  Future<void> transitionToSpeakingState() async {
    _orbitalStepTimer?.cancel();
    _state = VoiceAssistantState.speaking;
    _isPlayingAudio = true;
    _activeLyricIndex = 0;

    if (_aiLyricLines.isEmpty) {
      _setupResponseLyrics();
    }

    _startKaraokePlayback();
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
      final Map? status = await _speechOutputChannel.invokeMapMethod('audioStatus');
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

  void _startOrbitalStepScanner() {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _orbitalStepTimer?.cancel();
    final n = max(_contextualNotes.length, 1);
    final stepAngle = 360.0 / n;

    _orbitalStepTimer = Timer.periodic(const Duration(milliseconds: 800), (timer) {
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
      lines.add(SpokenLyricLine(
        text: "You do not have any saved notes in NoteEchoes yet.",
        startTime: elapsed,
        duration: const Duration(milliseconds: 2000),
      ));
      elapsed += const Duration(milliseconds: 2000);
      lines.add(SpokenLyricLine(
        text: "Tap the microphone button or Action Button to capture your first thought!",
        startTime: elapsed,
        duration: const Duration(milliseconds: 2500),
      ));
    } else {
      lines.add(SpokenLyricLine(
        text: "Here is what I found in your notes:",
        startTime: elapsed,
        duration: const Duration(milliseconds: 1600),
      ));
      elapsed += const Duration(milliseconds: 1600);

      for (int i = 0; i < min(allNotes.length, 3); i++) {
        final note = allNotes[i];
        lines.add(SpokenLyricLine(
          text: "${i + 1}. ${note.title}",
          startTime: elapsed,
          duration: const Duration(milliseconds: 2000),
        ));
        elapsed += const Duration(milliseconds: 2000);
      }
    }

    _aiLyricLines = lines;
    _fullGeneratedResponse = lines.map((l) => l.text).join('\n\n');
  }

  String get _speechLocale => switch (AppPreferences.instance.speechLanguageCode) {
    'te' => 'te-IN',
    'hi' => 'hi-IN',
    _ => 'en-US',
  };

  Future<void> _speakRemainingResponse() async {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    if (_aiLyricLines.isEmpty) return;
    final text = _aiLyricLines.skip(_activeLyricIndex).map((line) => line.text).join(' ');
    final segments = _aiLyricLines.skip(_activeLyricIndex).map((line) => line.text).toList();

    try {
      await _speechOutputChannel.invokeMethod<Object?>('speak', {
        'text': text,
        'segments': segments,
        'startIndex': _activeLyricIndex,
        'language': _speechLocale,
      }).timeout(const Duration(milliseconds: 200), onTimeout: () => null);
      _audioOutputError = null;
    } on MissingPluginException {
      _audioOutputError = 'Spoken output is available when running on iPhone.';
    } on PlatformException catch (error) {
      _audioOutputError = error.message ?? 'Could not play the spoken response.';
    } catch (_) {}
    notifyListeners();
  }

  void _startKaraokePlayback({int startAt = 0}) {
    if (Platform.environment.containsKey('FLUTTER_TEST')) return;
    _karaokeTimer?.cancel();
    _karaokeTimer = null;
    int current = startAt;

    void scheduleNext() {
      if (!_isPlayingAudio || _state != VoiceAssistantState.speaking) {
        _karaokeTimer?.cancel();
        _karaokeTimer = null;
        return;
      }

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
        _karaokeTimer?.cancel();
        _karaokeTimer = null;
        notifyListeners();
      }
    }

    scheduleNext();
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
    _cleanupTempAudio();
    super.dispose();
  }
}

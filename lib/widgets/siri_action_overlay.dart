import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/note_model.dart';
import '../ai/domain/ai_models.dart';
import '../ai/infrastructure/offline_speech_bridge.dart';
import '../services/ai_categorization_engine.dart';
import '../services/note_service.dart';
import '../services/voice_capture_validator.dart';
import '../theme/app_colors.dart';
import '../theme/app_preferences.dart';

class SiriActionOverlay extends StatefulWidget {
  final VoidCallback? onDismiss;
  final bool autoStartRecording;

  const SiriActionOverlay({
    super.key,
    this.onDismiss,
    this.autoStartRecording = true,
  });

  /// Shows the sleek, real-time bottom recording sheet inspired by Google/Apple Notes & Antigravity.
  static Future<NoteModel?> show(
    BuildContext context, {
    bool autoStart = true,
  }) {
    return showModalBottomSheet<NoteModel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.7),
      builder: (context) {
        return SiriActionOverlay(
          autoStartRecording: autoStart,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  @override
  State<SiriActionOverlay> createState() => _SiriActionOverlayState();
}

class _SiriActionOverlayState extends State<SiriActionOverlay>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  static const MethodChannel _offlineSpeechChannel = MethodChannel(
    'noteechoes/offline_speech',
  );

  bool _isSpeechAvailable = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;

  String _accumulatedText = "";
  String _currentSessionText = "";
  int _recordingSeconds = 0;
  Timer? _durationTimer;
  NoteAnalysisResult? _completedAnalysis;
  String? _recordingPath;

  String get _spokenText {
    final combined = "$_accumulatedText $_currentSessionText".trim();
    return combined;
  }

  @override
  void initState() {
    super.initState();
    _initSpeechAndStart();
  }

  Future<void> _initSpeechAndStart() async {
    try {
      _isSpeechAvailable = await _speech.initialize(
        onStatus: (status) {
          debugPrint("Live Speech Status: $status");
          if (_isRecording &&
              (status == 'done' || status == 'notListening') &&
              mounted) {
            _restartLiveDictation();
          }
        },
        onError: (error) {
          debugPrint("Live Speech Error: ${error.errorMsg}");
          if (_isRecording && mounted) {
            _restartLiveDictation();
          }
        },
      );
    } catch (e) {
      debugPrint("Speech recognition init exception: $e");
      _isSpeechAvailable = false;
    }

    if (mounted) {
      setState(() {});
      if (widget.autoStartRecording) {
        _startRecording();
      }
    }
  }

  void _startLiveDictation() {
    if (!_isSpeechAvailable || !_isRecording) return;
    // Determine the locale to use for live dictation
    final localeId = _appleLocaleId;

    try {
      _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              _currentSessionText = result.recognizedWords;
              if (result.finalResult && _currentSessionText.trim().isNotEmpty) {
                _accumulatedText = "$_accumulatedText $_currentSessionText"
                    .trim();
                _currentSessionText = "";
              }
            });
          }
        },
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          pauseFor: const Duration(seconds: 4),
          partialResults: true,
          onDevice: false,
          // Use null for auto detection (en-US default on iOS when no te-IN is installed).
          // Whisper will handle the full-file Telugu/Hindi transcription offline.
          localeId: localeId,
        ),
      );
    } catch (e) {
      debugPrint("Error starting live dictation ($localeId): $e");
      // If te-IN / hi-IN dictation fails, continue — Whisper will transcribe the full audio.
    }
  }

  void _restartLiveDictation() {
    if (!_isRecording) return;
    if (_currentSessionText.trim().isNotEmpty) {
      _accumulatedText = "$_accumulatedText $_currentSessionText".trim();
      _currentSessionText = "";
    }
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _isRecording) {
        _startLiveDictation();
      }
    });
  }

  String? get _appleLocaleId =>
      switch (AppPreferences.instance.speechLanguageCode) {
        'te' => 'te-IN',
        'hi' => 'hi-IN',
        'en' => 'en-US',
        _ => null,
      };

  Future<void> _startRecording() async {
    if (_isRecording) return;
    if (!await _audioRecorder.hasPermission()) {
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    _recordingPath =
        '${tempDirectory.path}/noteechoes_${DateTime.now().microsecondsSinceEpoch}.m4a';

    try {
      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 64000,
          sampleRate: 16000,
          numChannels: 1,
          autoGain: true,
          echoCancel: true,
          noiseSuppress: true,
        ),
        path: _recordingPath!,
      );
    } catch (e) {
      debugPrint("Error starting audio recorder: $e");
    }

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isAnalyzing = false;
      _accumulatedText = "";
      _currentSessionText = "";
      _recordingSeconds = 0;
      _completedAnalysis = null;
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    // Start live speech-to-text so words appear instantly as spoken
    _startLiveDictation();
  }

  Future<void> _stopRecordingAndSave({bool userCancelled = false}) async {
    if (!_isRecording && !_isAnalyzing) {
      Navigator.of(context).pop();
      return;
    }

    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    try {
      if (_isSpeechAvailable) {
        await _speech.stop();
      }
    } catch (_) {}

    String? recordedPath;
    try {
      recordedPath = await _audioRecorder.stop() ?? _recordingPath;
    } catch (_) {}

    var cleanText = _spokenText.trim();

    // Verify audio transcription with offline/multilingual Whisper if available
    if (recordedPath != null && await File(recordedPath).exists()) {
      try {
        final langCode = AppPreferences.instance.speechLanguageCode;
        final audioLang = AudioLanguageExt.fromBcp47(langCode);
        final provenance = await OfflineSpeechBridge.instance
            .transcribeAudioFile(audioPath: recordedPath, language: audioLang);
        if (provenance.text.trim().isNotEmpty) {
          cleanText = provenance.text.trim();
        }
      } catch (error) {
        debugPrint('Full-file transcription fallback to live text: $error');
      } finally {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }
    }

    if (!VoiceCaptureValidator.hasMeaningfulSpeech(cleanText)) {
      if (mounted) Navigator.of(context).pop();
      return;
    }

    // Categorize and create note
    final analysis = AiCategorizationEngine().analyzeNote(cleanText);
    final note = await NoteService().createFromVoiceTranscription(cleanText);

    if (mounted) {
      setState(() {
        _isAnalyzing = false;
        _completedAnalysis = analysis;
      });
      HapticFeedback.heavyImpact();
      // Auto close and return created note
      Future.delayed(const Duration(milliseconds: 600), () {
        if (mounted) {
          Navigator.of(context).pop(note);
        }
      });
    }
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    if (_isSpeechAvailable) {
      _speech.stop();
    }
    _audioRecorder.dispose();
    super.dispose();
  }

  String _formatTime(int sec) {
    final m = sec ~/ 60;
    final s = sec % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(12, 0, 12, 24 + bottomInset),
      decoration: BoxDecoration(
        color: const Color(0xFF1C1C1E),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFF2C2C2E), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.65),
            blurRadius: 28,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 10, bottom: 4),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header Row: Status & Live Timer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording
                        ? accent
                        : _isAnalyzing
                        ? const Color(0xFFFF9F0A)
                        : AppColors.accentGreen,
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _isRecording
                      ? 'Dictating • ${_formatTime(_recordingSeconds)}'
                      : _isAnalyzing
                      ? 'Saving to Home Notes…'
                      : 'Note Saved',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const Spacer(),
                // Language badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    AppPreferences.instance.speechLanguageLabel,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: Colors.white54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Color(0xFF2C2C2E), height: 1),

          // Real-time spoken transcript display
          Container(
            constraints: const BoxConstraints(minHeight: 110, maxHeight: 220),
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: SingleChildScrollView(
              reverse: true,
              child: _completedAnalysis != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _completedAnalysis!.title,
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _completedAnalysis!.categories.map((t) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: accent.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                '#$t',
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    )
                  : Text(
                      _spokenText.isNotEmpty
                          ? _spokenText
                          : 'Speak now — your words will appear here in real time…',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        height: 1.45,
                        color: _spokenText.isNotEmpty
                            ? Colors.white
                            : Colors.white38,
                        fontWeight: _spokenText.isNotEmpty
                            ? FontWeight.w500
                            : FontWeight.w400,
                      ),
                    ),
            ),
          ),

          const Divider(color: Color(0xFF2C2C2E), height: 1),

          // Action Buttons: Cancel & Done (Save)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _stopRecordingAndSave(userCancelled: true);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Color(0xFF3A3A3C)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      _stopRecordingAndSave();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: accent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(
                      'Save Note',
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

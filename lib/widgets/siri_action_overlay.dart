import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/note_model.dart';
import '../services/ai_categorization_engine.dart';
import '../services/note_service.dart';
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

  /// Static helper to trigger the Siri overlay modal from anywhere
  static Future<NoteModel?> show(
    BuildContext context, {
    bool autoStart = true,
  }) {
    return showGeneralDialog<NoteModel>(
      context: context,
      barrierDismissible: true,
      barrierLabel: "SiriActionOverlay",
      barrierColor: Colors.black.withValues(alpha: 0.78),
      transitionDuration: MediaQuery.of(context).disableAnimations
          ? Duration.zero
          : const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return SiriActionOverlay(
          autoStartRecording: autoStart,
          onDismiss: () => Navigator.of(context).pop(),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOutCubic),
          child: child,
        );
      },
    );
  }

  @override
  State<SiriActionOverlay> createState() => _SiriActionOverlayState();
}

class _SiriActionOverlayState extends State<SiriActionOverlay> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final AudioRecorder _audioRecorder = AudioRecorder();
  static const MethodChannel _offlineSpeechChannel = MethodChannel(
    'noteechoes/offline_speech',
  );
  bool _isSpeechAvailable = false;
  bool _isRecording = false;
  bool _isAnalyzing = false;
  bool _isRestartingListening = false;

  String _accumulatedText = "";
  String _currentSessionText = "";

  int _recordingSeconds = 0;
  Timer? _durationTimer;
  Timer? _watchdogTimer;
  NoteAnalysisResult? _completedAnalysis;
  String _statusMessage = "";
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
          debugPrint("SpeechToText Status: $status");
          if (_isRecording &&
              (status == 'done' || status == 'notListening') &&
              mounted) {
            _handleSessionEndAndRestart();
          }
        },
        onError: (error) {
          debugPrint("Speech recognition error: ${error.errorMsg}");
          if (_isRecording && mounted) {
            _handleSessionEndAndRestart();
          }
        },
      );
      if (mounted) {
        setState(() {});
        if (widget.autoStartRecording) {
          _startRecording();
        }
      }
    } catch (e) {
      debugPrint("Speech recognition init exception: $e");
      _isSpeechAvailable = false;
    }
  }

  void _handleSessionEndAndRestart() {
    if (!_isRecording || _isRestartingListening) return;
    _isRestartingListening = true;

    // Flush current session text to master accumulator
    if (_currentSessionText.trim().isNotEmpty) {
      _accumulatedText = "$_accumulatedText $_currentSessionText".trim();
      _currentSessionText = "";
    }

    // Brief delay to allow iOS SFSpeechRecognizer audio hardware to release before re-subscribing
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted && _isRecording) {
        _restartListeningSession();
      }
      _isRestartingListening = false;
    });
  }

  void _restartListeningSession() {
    if (!_isRecording || !_isSpeechAvailable) return;
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
          pauseFor: const Duration(hours: 2),
          partialResults: true,
          onDevice: false,
          localeId: _appleLocaleId,
        ),
      );
    } catch (e) {
      debugPrint("Error restarting listening session: $e");
    }
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
      if (mounted) {
        setState(
          () => _statusMessage =
              'Microphone permission is required to record a note.',
        );
      }
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    _recordingPath =
        '${tempDirectory.path}/noteechoes_${DateTime.now().microsecondsSinceEpoch}.m4a';
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

    HapticFeedback.heavyImpact();
    setState(() {
      _isRecording = true;
      _isAnalyzing = false;
      _accumulatedText = "";
      _currentSessionText = "";
      _recordingSeconds = 0;
      _completedAnalysis = null;
      _statusMessage = "";
    });

    _durationTimer?.cancel();
    _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _recordingSeconds++);
      }
    });

    // Do not run two microphone engines at once. The previous implementation
    // kept restarting Apple's live recognizer, which could drop words between
    // sessions and could conflict with the durable audio recorder.
    _watchdogTimer?.cancel();
    setState(
      () => _statusMessage =
          'Recording full audio • ${AppPreferences.instance.speechLanguageLabel}',
    );
  }

  Future<void> _stopRecordingAndSave() async {
    if (!_isRecording && !_isAnalyzing) return;

    HapticFeedback.mediumImpact();
    _durationTimer?.cancel();
    _watchdogTimer?.cancel();

    // Set this first so the Speech callbacks cannot restart themselves while
    // the full audio file is being finalized.
    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
      _statusMessage = 'Finalizing the complete recording…';
    });

    final recordedPath = await _audioRecorder.stop() ?? _recordingPath;
    if (_isSpeechAvailable) {
      await _speech.stop();
    }

    var cleanText = _spokenText.trim();

    // The recorded file is the source of truth. Unlike a live recognition
    // session it is not truncated when iOS ends or restarts SFSpeechRecognizer.
    if (recordedPath != null && await File(recordedPath).exists()) {
      try {
        final completeTranscript = await _offlineSpeechChannel
            .invokeMethod<String>('transcribeAudioFile', {
              'path': recordedPath,
              'language': AppPreferences.instance.speechLanguageCode,
            });
        if (completeTranscript != null &&
            completeTranscript.trim().isNotEmpty) {
          cleanText = completeTranscript.trim();
        }
      } catch (error) {
        debugPrint(
          'Full-file transcription failed; using live preview: $error',
        );
      } finally {
        try {
          await File(recordedPath).delete();
        } catch (_) {}
      }
    }

    if (cleanText.isEmpty) {
      setState(() {
        _isAnalyzing = false;
        _statusMessage = "No speech detected.";
      });
      Future.delayed(const Duration(milliseconds: 1000), () {
        if (mounted) Navigator.of(context).pop();
      });
      return;
    }

    setState(() => _statusMessage = 'Saving note…');

    // Deep semantic categorization on user's real spoken words
    final analysis = AiCategorizationEngine().analyzeNote(cleanText);

    await Future.delayed(const Duration(milliseconds: 300));

    if (!mounted) return;

    final note = await NoteService().createFromVoiceTranscription(cleanText);

    setState(() {
      _isAnalyzing = false;
      _completedAnalysis = analysis;
    });

    HapticFeedback.heavyImpact();

    // Auto dismiss after displaying categorized tags
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        Navigator.of(context).pop(note);
      }
    });
  }

  @override
  void dispose() {
    _durationTimer?.cancel();
    _watchdogTimer?.cancel();
    if (_isSpeechAvailable) {
      _speech.stop();
    }
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Only dismiss on background tap when NOT actively recording
        if (!_isRecording && !_isAnalyzing) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Calm, legible recording surface. The previous neon perimeter
            // competed with the note content and made the app feel synthetic.
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    // Top Status Pill
                    _buildTopStatusPill(),

                    const Spacer(),

                    // Floating Glass Card for Spoken Speech & Categorization
                    _buildFloatingTranscriptionCard(),

                    const SizedBox(height: 16),

                    // Bottom Action Button / Hold-to-Talk Touch Target
                    _buildBottomActionControl(),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // TOP STATUS BADGE (Apple Intelligence Siri Mode)
  // ==========================================================
  Widget _buildTopStatusPill() {
    final accent = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.glassBorderBright.withValues(alpha: 0.6),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 12,
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording
                      ? accent
                      : _isAnalyzing
                      ? accent
                      : AppColors.accentGreen,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.28),
                      blurRadius: 5,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _isRecording
                    ? "Recording Voice Note (${_recordingSeconds}s)..."
                    : _isAnalyzing
                    ? "Transcribing complete recording…"
                    : "Note Saved!",
                style: GoogleFonts.inter(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FLOATING TRANSCRIPTION CARD (Transparent Frosted Glass)
  // ==========================================================
  Widget _buildFloatingTranscriptionCard() {
    final accent = Theme.of(context).colorScheme.primary;
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.glassBorderBright.withValues(alpha: 0.5),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 16,
              ),
            ],
          ),
          child: _completedAnalysis != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Saved Note Title
                    Text(
                      _completedAnalysis!.title,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.outfit(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // Snippet
                    Text(
                      _completedAnalysis!.summarySnippet,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.inter(
                        fontSize: 12.5,
                        color: AppColors.secondaryText,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Categorized Tag Badges
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: _completedAnalysis!.categories.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: accent.withValues(alpha: 0.28),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.tag_rounded, size: 11, color: accent),
                              const SizedBox(width: 4),
                              Text(
                                "#$tag",
                                style: GoogleFonts.inter(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
              : Text(
                  _statusMessage.isNotEmpty
                      ? _statusMessage
                      : _spokenText.isNotEmpty
                      ? _spokenText
                      : "Listening to your voice...\nSpeak your note now.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: _spokenText.isNotEmpty ? 20 : 15,
                    fontWeight: FontWeight.w600,
                    color: _spokenText.isNotEmpty
                        ? Colors.white
                        : AppColors.secondaryText,
                  ),
                ),
        ),
      ),
    );
  }

  // ==========================================================
  // BOTTOM ACTION BUTTON — TOGGLE: TAP TO START / TAP TO STOP
  // ==========================================================
  Widget _buildBottomActionControl() {
    final accent = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: () {
        if (_isRecording) {
          _stopRecordingAndSave();
        } else if (!_isAnalyzing) {
          _startRecording();
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _isRecording ? accent : AppColors.elevation2,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(
            color: _isRecording ? Colors.white : AppColors.glassBorderBright,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _isRecording ? Icons.stop_rounded : Icons.mic_rounded,
              color: Colors.white,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              _isRecording ? "Listening..." : "Tap to Record",
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
